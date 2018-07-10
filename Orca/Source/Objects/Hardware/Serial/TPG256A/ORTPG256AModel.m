//--------------------------------------------------------
// ORTPG256AModel
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
//  Created by Mark Howe on Mon Apr 16 2012.
//  Copyright 2012  University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files

#import "ORTPG256AModel.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"

#pragma mark •••External Strings
NSString* ORTPG256AModelUnitsChanged             = @"ORTPG256AModelUnitsChanged";
NSString* ORTPG256AModelPressureScaleChanged     = @"ORTPG256AModelPressureScaleChanged";
NSString* ORTPG256AModelShipPressuresChanged     = @"ORTPG256AModelShipPressuresChanged";
NSString* ORTPG256AModelPollTimeChanged          = @"ORTPG256AModelPollTimeChanged";
NSString* ORTPG256APressureChanged               = @"ORTPG256APressureChanged";
NSString* ORTPG256AModelHighLimitChanged         = @"ORTPG256AModelHighLimitChanged";
NSString* ORTPG256AModelHighAlarmChanged         = @"ORTPG256AModelHighAlarmChanged";
NSString* ORTPG256AModelLowLimitChanged          = @"ORTPG256AModelLowLimitChanged";
NSString* ORTPG256AModelLowAlarmChanged          = @"ORTPG256AModelLowAlarmChanged";

NSString* ORTPG256ALock = @"ORTPG256ALock";

#define kACK			0x06
#define kNAK			0x15
#define kENQ			0x05
#define kEXT			0x03
#define kWaitingForACK	1
#define kProcessData	2

@interface ORTPG256AModel (private)
- (void) processOneCommandFromQueue;
- (void) process_response:(NSString*)theResponse;
- (void) pollPressures;
- (void) postCouchDBRecord;
@end

@implementation ORTPG256AModel
- (id) init
{
	self = [super init];
	int i;
	for(i=0;i<6;i++){
		lowLimit[i]  = 0; 
		highLimit[i] = 1.0; 
		lowAlarm[i]  = 0; 
		highAlarm[i] = 1.0; 
	}
	
	return self;
}

- (void) dealloc
{
    [buffer release];
	int i;
	for(i=0;i<6;i++){
		[timeRates[i] release];
	}

	[super dealloc];
}

- (void) wakeUp
{
    [super wakeUp];
	[self pollPressures];
}

- (void) sleep
{
    [super sleep];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"TPG256A.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORTPG256AController"];
}

- (NSString*) helpURL
{
	return @"RS232/TPG256A.html";
}

- (void) dataReceived:(NSNotification*)note
{
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
        NSString* theString = [[[[NSString alloc] initWithData:[[note userInfo] objectForKey:@"data"] 
												      encoding:NSASCIIStringEncoding] autorelease] uppercaseString];

 		//the serial port may break the data up into small chunks, so we have to accumulate the chunks until
		//we get a full piece.       
		if(!buffer)buffer = [[NSMutableString string] retain];
        [buffer appendString:theString];	
		
		if([buffer hasSuffix:@"\r\n"]){
			//got a full chunk ... process according to the port data state
			if(portDataState == kWaitingForACK){
				if([buffer characterAtIndex:0] == kNAK){
					//error in transimission
					//flush and go to next command
					NSLogError(@"Transmission Error",@"TGP256A",nil);
					[cmdQueue removeAllObjects];
					[self setLastRequest:nil];			 //clear the last request
					[self processOneCommandFromQueue];	 //do the next command in the queue
				}
				else if([buffer characterAtIndex:0] == kACK){
					//device has sent us a positive aknowledgement of the command
					//respond with a request to transmit data and enter new state
					[serialPort writeString:[NSString stringWithFormat:@"%c",kENQ]];
					portDataState = kProcessData;
				}
			}
			else if(portDataState == kProcessData){
				//OK, should be valid data. Process and continue with the que
				[self process_response:buffer];
				[self cancelTimeout];
				[self setLastRequest:nil];			 //clear the last request
				[self processOneCommandFromQueue];	 //do the next command in the queue
			}
			//flush the accumulation buffer
			[buffer release];
			buffer = nil;
		}
	}
}


- (void) shipPressureValues
{
	if(shipPressures) {
		if([[ORGlobal sharedGlobal] runInProgress]){
			
			unsigned long data[kTPG256ARecordLength];
			data[0] = dataId | kTPG256ARecordLength;
			data[1] = [self uniqueIdNumber]&0xfff;
			
			union {
				float asFloat;
				unsigned long asLong;
			}theData;
			int index = 2;
			int i;
			for(i=0;i<6;i++){
				theData.asFloat = pressure[i];
				data[index] = theData.asLong;
				index++;
				
				data[index] = timeMeasured[i];
				index++;
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification 
																object:[NSData dataWithBytes:data length:sizeof(long)*kTPG256ARecordLength]];
		}
	}
}

- (BOOL) acceptsGuardian: (OrcaObject *)aGuardian
{
	return	[super acceptsGuardian:aGuardian] || 
			[aGuardian isMemberOfClass:NSClassFromString(@"ORMJDVacuumModel")] || 
			[aGuardian isMemberOfClass:NSClassFromString(@"ORMJDPumpCartModel")];
}

#pragma mark •••Accessors

- (int) units
{
    return units;
}

- (void) setUnits:(int)aUnits
{
	if(aUnits>=0 && aUnits<=2){
		[[[self undoManager] prepareWithInvocationTarget:self] setUnits:units];
		units = aUnits;
		[[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelUnitsChanged object:self];
	}
}

- (int) measurementState:(int)index
{
	if(index>=0 && index<6)return measurementState[index];
	else return kTPG256AMeasurementNoSensor;
}

- (void) setMeasurementState:(int)index value:(int)aMeasurementState
{
	if(index>=0 && index<6) measurementState[index] = aMeasurementState;
}

- (float) pressureScaleValue
{
	return pressureScaleValue;
}

- (int) pressureScale
{
    return pressureScale;
}

- (void) setPressureScale:(int)aPressureScale
{
	if(aPressureScale<0)aPressureScale=0;
	else if(aPressureScale>11)aPressureScale=11;
	
    [[[self undoManager] prepareWithInvocationTarget:self] setPressureScale:pressureScale];
    
    pressureScale = aPressureScale;
	
	pressureScaleValue = powf(10.,(float)pressureScale);

    [[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelPressureScaleChanged object:self];
}

- (ORTimeRate*)timeRate:(int)index
{
	return timeRates[index];
}

- (BOOL) shipPressures
{
    return shipPressures;
}

- (void) setShipPressures:(BOOL)aShipPressures
{
    [[[self undoManager] prepareWithInvocationTarget:self] setShipPressures:shipPressures];
    
    shipPressures = aShipPressures;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelShipPressuresChanged object:self];
}

- (int) pollTime
{
    return pollTime;
}

- (void) setPollTime:(int)aPollTime
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollTime:pollTime];
    pollTime = aPollTime;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelPollTimeChanged object:self];

	if(pollTime)	[self performSelector:@selector(pollPressures) withObject:nil afterDelay:2];
	else			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollPressures) object:nil];
}


- (float) pressure:(int)index
{
	if(index>=0 && index<6)return pressure[index];
	else return 0.0;
}

- (unsigned long) timeMeasured:(int)index
{
	if(index>=0 && index<6)return timeMeasured[index];
	else return 0;
}

- (void) setPressure:(int)index value:(float)aValue;
{
	if(index>=0 && index<6){
		
		//if(aValue == 0) aValue = 1.0E3;
		
		pressure[index] = aValue * 0.750061683; //convert the value from mBar to Torr.
		
		//get the time(UT!)
		time_t	ut_Time;
		time(&ut_Time);
		timeMeasured[index] = ut_Time;

		[[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256APressureChanged 
															object:self 
														userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"Channel"]];

		if(timeRates[index] == nil) timeRates[index] = [[ORTimeRate alloc] init];
		[timeRates[index] addDataToTimeAverage:pressure[index]];

	}
}


- (void) setUpPort
{
	[serialPort setSpeed:9600];
	[serialPort setParityNone];
	[serialPort setStopBits2:0];
	[serialPort setDataBits:8];
}

- (double) lowLimit:(int)aChan
{
	if(aChan>=0 && aChan<6)return lowLimit[aChan];
	else return 1;
}

- (void) setLowLimit:(int)aChan value:(double)aValue
{
	if(aChan>=0 && aChan<6){
		[[[self undoManager] prepareWithInvocationTarget:self] setLowLimit:aChan value:lowLimit[aChan]];
		lowLimit[aChan] = aValue;
		[[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelLowLimitChanged object:self];
	}
}
- (double) highLimit:(int)aChan
{
	if(aChan>=0 && aChan<6)return highLimit[aChan];
	else return 1;
}

- (void) setHighLimit:(int)aChan value:(double)aValue
{
	if(aChan>=0 && aChan<6){
		[[[self undoManager] prepareWithInvocationTarget:self] setHighLimit:aChan value:highLimit[aChan]];
		highLimit[aChan] = aValue;
		[[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelHighLimitChanged object:self];
	}
}
- (double) lowAlarm:(int)aChan
{
	if(aChan>=0 && aChan<6)return lowAlarm[aChan];
	else return 1;
}

- (void) setLowAlarm:(int)aChan value:(double)aValue
{
	if(aChan>=0 && aChan<6){
		[[[self undoManager] prepareWithInvocationTarget:self] setHighAlarm:aChan value:lowAlarm[aChan]];
		lowAlarm[aChan] = aValue;
		[[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelLowAlarmChanged object:self];
	}
}

- (double) highAlarm:(int)aChan
{
	if(aChan>=0 && aChan<6)return highAlarm[aChan];
	else return 1;
}

- (void) setHighAlarm:(int)aChan value:(double)aValue
{
	if(aChan>=0 && aChan<6){
		[[[self undoManager] prepareWithInvocationTarget:self] setHighAlarm:aChan value:highAlarm[aChan]];
		highAlarm[aChan] = aValue;
		[[NSNotificationCenter defaultCenter] postNotificationName:ORTPG256AModelHighAlarmChanged object:self];
	}
}

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setUnits:			[decoder decodeIntForKey:	 @"units"]];
	[self setPressureScale:	[decoder decodeIntForKey:	 @"pressureScale"]];
	[self setShipPressures:	[decoder decodeBoolForKey:	 @"shipPressures"]];
	[self setPollTime:		[decoder decodeIntForKey:	 @"pollTime"]];
	
	int i;
	for(i=0;i<6;i++){
		timeRates[i] = [[ORTimeRate alloc] init];
		[self setLowAlarm:i value:[decoder decodeDoubleForKey: [NSString stringWithFormat:@"lowAlarm%d",i]]];
		[self setHighAlarm:i value:[decoder decodeDoubleForKey: [NSString stringWithFormat:@"highAlarm%d",i]]];
		[self setLowLimit:i value:[decoder decodeDoubleForKey: [NSString stringWithFormat:@"lowLimit%d",i]]];
		[self setHighLimit:i value:[decoder decodeDoubleForKey: [NSString stringWithFormat:@"highLimit%d",i]]];
	}
	[[self undoManager] enableUndoRegistration];

	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:units			forKey: @"units"];
    [encoder encodeInt:pressureScale	forKey: @"pressureScale"];
    [encoder encodeBool:shipPressures	forKey: @"shipPressures"];
    [encoder encodeInt:pollTime			forKey: @"pollTime"];
	
	int i;
	for(i=0;i<6;i++){
		[encoder encodeDouble:lowAlarm[i] forKey: [NSString stringWithFormat:@"lowAlarm%d",i]];
		[encoder encodeDouble:lowLimit[i] forKey: [NSString stringWithFormat:@"lowLimit%d",i]];
		[encoder encodeDouble:highAlarm[i] forKey: [NSString stringWithFormat:@"highAlarm%d",i]];
		[encoder encodeDouble:highLimit[i] forKey: [NSString stringWithFormat:@"highLimit%d",i]];
	}
}

#pragma mark ••• Commands
- (void) addCmdToQueue:(NSString*)aCmd
{
    if([serialPort isOpen]){ 
		[self enqueueCmd:aCmd];
		if(!lastRequest){
			[self processOneCommandFromQueue];
		}
	}
}

- (void) readPressures
{
	@synchronized(self){
		int i;
		for(i=0;i<6;i++){
			[self addCmdToQueue:[NSString stringWithFormat:@"PR%d",i+1]];
		}
		[self addCmdToQueue:@"++ShipRecords"];
	}
}

- (void) sendUnits
{
	[self addCmdToQueue:[NSString stringWithFormat:@"UNI,%d",units]];
}

#pragma mark •••Data Records
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherTPG256A
{
    [self setDataId:[anotherTPG256A dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(NSDictionary*)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"TPG256AModel"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORTPG256ADecoderForPressure",					@"decoder",
        [NSNumber numberWithLong:dataId],				@"dataId",
        [NSNumber numberWithBool:NO],					@"variable",
        [NSNumber numberWithLong:kTPG256ARecordLength], @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Pressures"];
    
    return dataDictionary;
}
#pragma mark •••Adc Processing Protocol
- (void) processIsStarting { }
- (void) processIsStopping { }
- (void) startProcessCycle { }
- (void) endProcessCycle   { }

- (NSString*) identifier
{
	NSString* s;
 	@synchronized(self){
		s= [NSString stringWithFormat:@"TPG256A,%lu",[self uniqueIdNumber]];
	}
	return s;
}

- (NSString*) processingTitle
{
	NSString* s;
 	@synchronized(self){
		s= [self identifier];
	}
	return s;
}

- (double) convertedValue:(int)aChan
{
	double theValue = 0;
	@synchronized(self){
		if(aChan>=0 && aChan<6)theValue =  pressure[aChan];
 	}
	return theValue;
}

- (double) maxValueForChan:(int)aChan
{
	double theValue;
	@synchronized(self){
        if(aChan>=0 && aChan<6) theValue = highLimit[aChan];
		else         theValue = 1.0;
	}
	return theValue;
}

- (double) minValueForChan:(int)aChan
{
	double theValue;
	@synchronized(self){
        if(aChan>=0 && aChan<6) theValue = lowLimit[aChan];
		else         theValue = 1.0;
	}
	return theValue;
}

- (void) getAlarmRangeLow:(double*)theLowAlarm high:(double*)theHighAlarm channel:(int)aChan
{
	@synchronized(self){
        if(aChan>=0 && aChan<6) {
            *theLowAlarm   = lowAlarm[aChan];
            *theHighAlarm = highAlarm[aChan];
        }
        else {
			*theLowAlarm = 0;
            *theHighAlarm = 1E-4;
        }
	}		
}

- (BOOL) processValue:(int)aChan
{
	BOOL r = 0;
	@synchronized(self){
		if(aChan>=0 && aChan<6)r =  pressure[aChan];
    }
	return r;
}

- (void) setProcessOutput:(int)channel value:(int)value { }

@end

@implementation ORTPG256AModel (private)

- (void) processOneCommandFromQueue
{
	NSString* aCmd = [self nextCmd];
	if(aCmd){
		if([aCmd isEqualToString:@"++ShipRecords"])[self shipPressureValues];
		else {
			if(![aCmd hasSuffix:@"\r\n"]) aCmd = [aCmd stringByAppendingString:@"\r\n"];
			
			[self setLastRequest:aCmd];
			[self startTimeout:3];
			//just sent a command so the first thing received should be an ACK
			//enter that state and send the command
			portDataState = kWaitingForACK;
			[serialPort writeString:aCmd];
		}
	}
}

- (void) process_response:(NSString*)theResponse
{
    [self setIsValid:YES];
	if([lastRequest hasPrefix:@"PR"]){
		int channel = [[lastRequest substringWithRange:NSMakeRange(2,1)] intValue]-1;
		if(channel>=0 && channel<6){
			NSArray* parts = [theResponse componentsSeparatedByString:@","];
			int n = [parts count];
			if(n == 2){
				[self setMeasurementState:channel value:[[parts objectAtIndex:0] intValue]];
				float thePressure = 0;
				if(measurementState[channel] == kTPG256AMeasurementOK){
					thePressure = [[parts objectAtIndex:1] floatValue];
				}
                else if(measurementState[channel] == kTPG256AMeasurementUnderRange){
                    thePressure = 0;
                }
                else thePressure = 1.0E3;
                
				[self setPressure:channel value:thePressure];
			}
		}
	}
	else if([lastRequest hasPrefix:@"UNI"]){
		//for now just ignore and let the select by the user stand....
	}
}

- (void) pollPressures
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollPressures) object:nil];
	if(pollTime){
		[self readPressures];
        [self postCouchDBRecord];
		[self performSelector:@selector(pollPressures) withObject:nil afterDelay:pollTime];
	}
}

- (void) postCouchDBRecord
{
    NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%.2E",pressure[0]], @"chan 0",
                             [NSString stringWithFormat:@"%.2E",pressure[1]], @"chan 1",
                             [NSString stringWithFormat:@"%.2E",pressure[2]], @"chan 2",
                             [NSString stringWithFormat:@"%.2E",pressure[3]], @"chan 3",
                             [NSString stringWithFormat:@"%.2E",pressure[4]], @"chan 4",
                             [NSString stringWithFormat:@"%.2E",pressure[5]], @"chan 5",
                             [NSNumber numberWithInt:    pollTime],           @"pollTime",
                            nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ORCouchDBAddObjectRecord" object:self userInfo:values];
}

@end
//--------------------------------------------------------
// ORWG1220PulserModel
// Created by Mark  A. Howe on Fri Jul 22 2005 / Julius Hartmann, KIT, Mai 2017
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of
//Washington at the Center for Experimental Nuclear Physics and
//Astrophysics (CENPA) sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020.
//The University has certain rights in the program pursuant to
//the contract and the program should not be copied or distributed
//outside your organization.  The DOE and the University of
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty,
//express or implied, or assume any liability or responsibility
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORAuxHw.h"
#import "ORSafeQueue.h"

@class ORSerialPort;

#define kWGRemoteCmd	'R'
#define kWGFreqCmd 'F'
#define kWGAttCmd 'Q'
#define kWGAmpltCmd 'A'
#define kWGDutyCCmd 'D'
#define kWGFormCmd 'K'
#define kWGProgModCmd 'C'
#define kWGStartProgCmd 'B'
#define kWGRdyPrgrmCmd 'b'
#define kWGStopPrgrmCmd 'U'
#define kWGFinPrgrmCmd 'u'

#define VMax 19.93  // maximum Voltage; tests with an available device showed,
// that the 20V from the datasheet could not be reached.
#define dampedMax (VMax / 10)  // maximum voltage when damping is set
#define VMin 0.02  // minimum voltage (with damping)

@interface ORWG1220PulserModel : ORAuxHw
{
    @private
        NSString*        portName;
        BOOL             portWasOpen;
        ORSerialPort*    serialPort;

    enum SignalForms { Sine, Rectangular, Triangular, Arbitrary} signalForm;
		//SignalForms signalForm;
		float				amplitude;
		int				dutyCycle;
		float			frequency;
    int reTxCount;  // in case of errors or timeout retransmit; if retransmit
    // is required, put last command to cmdQueue and dequeueFromBottom

    NSMutableArray* arbWaveform;
    unsigned char arbWaveBytes[65536];

    NSData*				lastRequest;
    NSMutableData*		inComingData;
    ORSafeQueue*		cmdQueue;
    NSString* waveformFile;
    BOOL verbose;
}

#pragma mark ***Initialization
- (void) dealloc;
- (void) dataReceived:(NSNotification*)note;

#pragma mark ***Accessors
- (BOOL) verbose;
- (void) setVerbose:(BOOL)aVerbose;
- (float) frequency;
- (void) setFrequency:(float)aFrequency;
- (int) dutyCycle;
- (void) setDutyCycle:(int)aDutyCycle;
- (float) amplitude;
- (void) setAmplitude:(float)aAmplitude;
- (void) commitAmplitude;
- (int) signalForm;
- (void) setSignalForm:(int)aSignalForm;
- (ORSerialPort*) serialPort;
- (void) setSerialPort:(ORSerialPort*)aSerialPort;
- (BOOL) portWasOpen;
- (void) setPortWasOpen:(BOOL)aPortWasOpen;
- (NSString*) portName;
- (void) setPortName:(NSString*)aPortName;
- (void) openPort:(BOOL)state;
- (void) setLastRequest:(NSData*)aRequest;
- (NSString*) waveformFile;
- (void) setWaveformFile:(NSString*)aFile;
- (void) loadValuesFromFile;
- (void) commitWaveform;


#pragma mark ***Commands
- (void) writeData:(NSData*)someData;
- (NSData*) amplitudeCommand:(float) acommand;
- (NSData*) dutyCycleCommand;
- (NSData*) frequencyCommand:(float) afrequency;
- (NSData*) signalFormCommand:(enum SignalForms) aCommand;

- (void) serialPortWriteProgress:(NSDictionary *)dataDictionary;

- (void) setRemote;
- (void) setLocal;
- (NSData*) progModeCommand;
- (NSData*) startProgCommand;
- (NSData*) checkReadyForProg:(int) nPoints;
- (NSData*) isReadyForProgReturned;
- (NSData*) WGBytesFromFloat;
- (NSData*) stopProgCommand;
- (NSData*) checkStoppedProg:(int) nPoints;
- (NSData*) isStoppedProgReturned;

#pragma mark ***Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

extern NSString* ORWG1220PulserModelFrequencyChanged;
extern NSString* ORWG1220PulserModelDutyCycleChanged;
extern NSString* ORWG1220PulserModelAmplitudeChanged;
extern NSString* ORWG1220PulserModelSignalFormChanged;
extern NSString* ORWG1220PulserModelSignalFormArbitrary;
extern NSString* ORWG1220PulserModelSerialPortChanged;
extern NSString* ORWG1220PulserLock;
extern NSString* ORWG1220PulserModelPortNameChanged;
extern NSString* ORWG1220PulserModelPortStateChanged;
extern NSString* ORWG1220PulserModelVerboseChanged;
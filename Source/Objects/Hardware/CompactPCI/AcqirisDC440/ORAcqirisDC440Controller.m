//--------------------------------------------------------
// ORAcqirisDC440Controller
// Created by Mark A. Howe on Fri Jun 22 2007
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2007 CENPA, University of Washington. All rights reserved.
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

#import "ORAcqirisDC440Controller.h"
#import "ORAcqirisDC440Model.h"
#import "ORPlot.h"
#import "ORPlotView.h"
#import "ORAxis.h"
#import "SBC_Link.h"
#import "ORRate.h"
#import "ORRateGroup.h"
#import "ORValueBar.h"
#import "ORCompositePlotView.h"
#import "ORValueBarGroupView.h"

@interface ORAcqirisDC440Controller (private)
- (void) _doItSheetDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(NSDictionary*)userInfo;
@end

@implementation ORAcqirisDC440Controller

#pragma mark •••Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"AcqirisDC440"];
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) awakeFromNib
{
	[super awakeFromNib];
	[[plotter yAxis] setRngLimitsLow:-32768 withHigh:32768 withMinRng:128];

	ORPlot* aPlot;
	aPlot = [[ORPlot alloc] initWithTag:0 andDataSource:self];
	[plotter addPlot: aPlot];
	[aPlot setLineColor:[NSColor redColor]];
	[aPlot release];

	aPlot = [[ORPlot alloc] initWithTag:1 andDataSource:self];
	[plotter addPlot: aPlot];
	[aPlot setLineColor:[NSColor blueColor]];
	[aPlot release];
	
	[rate0 setNumber:2 height:10 spacing:10];
	[[rate0 xAxis] setLog:YES];
}

#pragma mark •••Notifications
- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
	[super registerNotificationObservers];
	
    [notifyCenter addObserver : self
					 selector : @selector(slotChanged:)
						 name : ORcPCICardSlotChangedNotification
					   object : model];

    [notifyCenter addObserver : self
					 selector : @selector(numberSamplesChanged:)
						 name : ORAcqirisDC440NumberSamplesChanged
						object: nil];

    [notifyCenter addObserver : self
					 selector : @selector(sampleIntervalChanged:)
						 name : ORAcqirisDC440SampleIntervalChanged
						object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(delayTimeChanged:)
                         name : ORAcqirisDC440DelayTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(fullScaleChanged:)
                         name : ORAcqirisDC440FullScaleChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(verticalOffsetChanged:)
                         name : ORAcqirisDC440VerticalOffsetChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(couplingChanged:)
                         name : ORAcqirisDC440CouplingChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(triggerSourceChanged:)
                         name : ORAcqirisDC440TriggerSourceChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(triggerCouplingChanged:)
                         name : ORAcqirisDC440TriggerCouplingChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(triggerLevelChanged:)
                         name : ORAcqirisDC440TriggerLevelChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(triggerSlopeChanged:)
                         name : ORAcqirisDC440TriggerSlopeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(baseAddressChanged:)
                         name : ORcPCIBaseAddressChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(dataChanged:)
                         name : ORAcqirisDC440DataChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(connectionChanged:)
                         name : SBC_LinkConnectionChanged
						object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(readContinouslyChanged:)
                         name : ORAcqirisDC440ReadContinouslyChanged
						object: model];

    [notifyCenter addObserver : self
					 selector : @selector(sampleRateGroupChanged:)
						 name : ORAcqirisDC440RateGroupChangedNotification
					   object : model];


    [notifyCenter addObserver : self
					 selector : @selector(scaleAction:)
						 name : ORAxisRangeChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(miscAttributesChanged:)
						 name : ORMiscAttributesChanged
					   object : model];

    [notifyCenter addObserver : self
                     selector : @selector(enableMaskChanged:)
                         name : ORAcqirisDC440ModelEnableMaskChanged
						object: model];

	[notifyCenter addObserver : self
					 selector : @selector(settingsLockChanged:)
						 name : ORRunStatusChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(settingsLockChanged:)
						 name : ORAcqirisDC440SettingsLock
						object: nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(samplingWaveformsChanged:)
						 name : ORAcqirisDC440SamplingWaveforms
						object: nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(boardIDChanged:)
						 name : ORAcqirisDC440BoardIDChanged
						object: nil];


    [self registerRates];
}

- (void) registerRates
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
	
	[notifyCenter removeObserver:self name:ORRateChangedNotification object:nil];
	
	NSEnumerator* e = [[[model sampleRateGroup] rates] objectEnumerator];
	id obj;
	while(obj = [e nextObject]){
		[notifyCenter addObserver : self
						 selector : @selector(sampleRateChanged:)
							 name : ORRateChangedNotification
						   object : obj];
	}
}


- (void) updateWindow
{
	[super updateWindow];
	[self slotChanged:nil];
	[self sampleIntervalChanged:nil];
	[self numberSamplesChanged:nil];
	[self delayTimeChanged:nil];
	[self fullScaleChanged:nil];
	[self verticalOffsetChanged:nil];
	[self couplingChanged:nil];
	[self triggerSourceChanged:nil];
	[self triggerCouplingChanged:nil];
	[self triggerLevelChanged:nil];
	[self triggerSlopeChanged:nil];
	[self baseAddressChanged:nil];
	[self connectionChanged:nil];
	[self readContinouslyChanged:nil];
    [self sampleRateChanged:nil];
	[self enableMaskChanged:nil];
    [self settingsLockChanged:nil];
    [self samplingWaveformsChanged:nil];
	[self boardIDChanged:nil];
	
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORAcqirisDC440SettingsLock to:secure];
    [settingLockButton setEnabled:secure];
}

- (void) samplingWaveformsChanged:(NSNotification*)aNote
{	
	[self updateButtons];
}

- (void) settingsLockChanged:(NSNotification*)aNote
{	
    BOOL locked = [gSecurity isLocked:ORAcqirisDC440SettingsLock];
    [settingLockButton setState: locked];
	[self updateButtons];
}

- (void) boardIDChanged:(NSNotification*)aNote
{
	[boardIdField setIntegerValue: [model boardID]];
}

- (void) enableMaskChanged:(NSNotification*)aNote
{
	short i;
	unsigned char theMask = [model enableMask];
	for(i=0;i<2;i++){
		BOOL bitSet = (theMask&(1<<i))>0;
		if(bitSet != [[enableMaskMatrix cellWithTag:i] intValue]){
			[[enableMaskMatrix cellWithTag:i] setState:bitSet];
		}
	}
}

- (void) scaleAction:(NSNotification*)aNotification
{
	if(aNotification == nil || [aNotification object] == [rate0 xAxis]){
		[model setMiscAttributes:[[rate0 xAxis]attributes] forKey:@"RateXAttributes"];
	};
}

- (void) miscAttributesChanged:(NSNotification*)aNote
{
	NSString*				key = [[aNote userInfo] objectForKey:ORMiscAttributeKey];
	NSMutableDictionary* attrib = [model miscAttributesForKey:key];
	
	if(aNote == nil || [key isEqualToString:@"RateXAttributes"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"RateXAttributes"];
		if(attrib){
			[[rate0 xAxis] setAttributes:attrib];
			[rate0 setNeedsDisplay:YES];
			[[rate0 xAxis] setNeedsDisplay:YES];
			//[rateLogCB setState:[[attrib objectForKey:ORAxisUseLog] boolValue]];
		}
	}
}

- (void) sampleRateChanged:(NSNotification*)aNote
{
	ORRate* theRateObj = [aNote object];		
	[[sampleRateTextFields cellWithTag:[theRateObj tag]] setFloatValue: [theRateObj rate]];
	[rate0 setNeedsDisplay:YES];
}

- (void) sampleRateGroupChanged:(NSNotification*)aNotification
{
	[self registerRates];
}

- (void) readContinouslyChanged:(NSNotification*)aNote
{
	[readContinouslyButton setIntValue: [model readContinously]];
}

- (void) connectionChanged:(NSNotification*)aNote
{
	if(([aNote object] == [model adapter]) || !aNote){
		[self updateButtons];
	}
}

- (void) slotChanged:(NSNotification*)aNote
{
	//[slotField setIntValue: [model slot]];
	[[self window] setTitle:[NSString stringWithFormat:@"Acqiris DC440 (Station %ld)",[model stationNumber]]];
}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"Acqiris DC440 (Station %ld)",[model stationNumber]]];
}

- (void) baseAddressChanged:(NSNotification*)aNote
{
	[baseAddressField setIntegerValue: [model baseAddress]];
}

- (void) triggerSlopeChanged:(NSNotification*)aNote
{
	[triggerSlopePU selectItemAtIndex: [model triggerSlope]];
}

- (void) triggerLevelChanged:(NSNotification*)aNote
{
	[triggerLevel1Field setDoubleValue: [model triggerLevel:0]];
	[triggerLevel2Field setDoubleValue: [model triggerLevel:1]];
}

- (void) triggerCouplingChanged:(NSNotification*)aNote
{
	[triggerCouplingPU selectItemAtIndex: [model triggerCoupling]];
}

- (void) triggerSourceChanged:(NSNotification*)aNote
{
	[triggerSourcePU selectItemAtIndex: [model triggerSource]];

	if([model triggerSource] == 0){
		[triggerLablel1Field setStringValue:@"mV"];
		[triggerLablel2Field setStringValue:@"mV"];
	}
	else {
		[triggerLablel1Field setStringValue:@"%"];
		[triggerLablel2Field setStringValue:@"%"];
	}
}

- (void) couplingChanged:(NSNotification*)aNote
{
	[couplingPU selectItemAtIndex: [model coupling]];
}

- (void) verticalOffsetChanged:(NSNotification*)aNote
{
	[verticalOffsetField setDoubleValue: [model verticalOffset]];
}

- (void) fullScaleChanged:(NSNotification*)aNote
{
	[fullScalePU selectItemAtIndex: [model fullScale]];
}

- (void) delayTimeChanged:(NSNotification*)aNote
{
	[delayTimeField setDoubleValue: [model delayTime]];
}

- (void)  sampleIntervalChanged:(NSNotification*)aNote
{
	[sampleIntervalField setDoubleValue:[model sampleInterval]];
}

- (void)  numberSamplesChanged:(NSNotification*)aNote
{
	[numberSamplesField setIntegerValue:[model numberSamples]];
}

- (void)  dataChanged:(NSNotification*)aNote
{
	[plotter setNeedsDisplay:YES];
}

- (void) updateButtons
{
    BOOL locked = [gSecurity isLocked:ORAcqirisDC440SettingsLock];
	BOOL isConnected = [[model adapter] isConnected];
    BOOL runInProgress = [gOrcaGlobals runInProgress];
	BOOL connectedAndNotRunning = isConnected & !runInProgress ;
	BOOL connectedAndNotRunningAndNotLocked = connectedAndNotRunning & !locked;
	[loadDialogButton setEnabled:connectedAndNotRunningAndNotLocked];
	[reportButton setEnabled:connectedAndNotRunningAndNotLocked];
	[initButton setEnabled:connectedAndNotRunningAndNotLocked];
	[enableMaskMatrix setEnabled:connectedAndNotRunningAndNotLocked];
	[readContinouslyButton setEnabled:connectedAndNotRunning];
	[numberSamplesField setEnabled:connectedAndNotRunningAndNotLocked];
	[enableMaskMatrix setEnabled:connectedAndNotRunningAndNotLocked];
	[triggerLevel2Field setEnabled:connectedAndNotRunningAndNotLocked];
	[triggerLevel1Field setEnabled:connectedAndNotRunningAndNotLocked];
	[triggerCouplingPU setEnabled:connectedAndNotRunningAndNotLocked];
	[triggerSourcePU setEnabled:connectedAndNotRunningAndNotLocked];
	[triggerSlopePU setEnabled:connectedAndNotRunningAndNotLocked];
	[couplingPU setEnabled:connectedAndNotRunningAndNotLocked];
	[verticalOffsetField setEnabled:connectedAndNotRunningAndNotLocked];
	[fullScalePU setEnabled:connectedAndNotRunningAndNotLocked];
	[delayTimeField setEnabled:connectedAndNotRunningAndNotLocked];
	[sampleIntervalField setEnabled:connectedAndNotRunningAndNotLocked];
	[baseAddressField setEnabled:connectedAndNotRunningAndNotLocked];
	[sampleIntervalField setEnabled:connectedAndNotRunningAndNotLocked];
	[probeButton setEnabled:connectedAndNotRunningAndNotLocked];
	[readOneButton setEnabled:connectedAndNotRunningAndNotLocked];
	if([model samplingWaveforms]){
		[readOneButton setTitle:@"Stop"];
	}
	else {
		if([model readContinously]){
			[readOneButton setTitle:@"Sample"];
		}
		else {
			[readOneButton setTitle:@"Read One"];
		}
	}
}


#pragma mark •••Actions
- (IBAction) settingLockAction:(id) sender
{
    [gSecurity tryToSetLock:ORAcqirisDC440SettingsLock to:[sender intValue] forWindow:[self window]];
}

- (void) enableMaskAction:(id)sender
{
	[model setEnableMaskBit:(int)[[sender selectedCell] tag] withValue:[sender intValue]];
}

- (void) readContinouslyAction:(id)sender
{
	[model setReadContinously:[sender intValue]];	
	[self updateButtons];
}

- (IBAction) triggerSlopeAction:(id)sender
{
	[model setTriggerSlope:(int)[sender indexOfSelectedItem]];
}

- (IBAction) triggerLevel2FieldAction:(id)sender
{
	[model setTriggerLevel:1 withValue:[sender floatValue]];	
}

- (IBAction) triggerLevel1FieldAction:(id)sender
{
	[model setTriggerLevel:0 withValue:[sender floatValue]];	
}

- (IBAction) triggerCouplingAction:(id)sender
{
	[model setTriggerCoupling:(int)[sender indexOfSelectedItem]];
}

- (IBAction) triggerSourceAction:(id)sender
{
	[model setTriggerSource:(int)[sender indexOfSelectedItem]];
}

- (IBAction) couplingAction:(id)sender
{
	[model setCoupling:(int)[sender indexOfSelectedItem]];
}

- (IBAction) verticalOffsetAction:(id)sender
{
	[model setVerticalOffset:[sender floatValue]];	
}

- (IBAction) fullScalePUAction:(id)sender
{
	[model setFullScale:(int)[sender indexOfSelectedItem]];
}

- (IBAction) delayTimeFieldAction:(id)sender
{
	[model setDelayTime:[sender floatValue]];	
}

- (IBAction) numberSamplesAction:(id)sender
{
	[model setNumberSamples:[sender intValue]];
}

- (IBAction) sampleIntervalAction:(id)sender
{
	[model setSampleInterval:[sender floatValue]];
}

- (IBAction) baseAddressAction:(id)sender
{
	[model setBaseAddress:[sender intValue]];
}

- (IBAction) probeAction:(id)sender
{
	[model probe:YES];
}

- (IBAction) initAction:(id)sender
{
	[self endEditing];
	[model initBoard];
	NSLog(@"Acqiris Board (slot %d) inited\n",[model stationNumber]);
}

- (IBAction) get1Waveform:(id)sender
{
	[self endEditing];
	[model getOneWaveform:![model samplingWaveforms]];
}

- (IBAction) report:(id)sender
{
	[model reportAll];
}

- (IBAction) loadDialogAction:(id)sender
{
#if defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Replace these dialog values with values read from hardware!"];
    [alert setInformativeText:@"Really replace all values? This can not be undone!"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result){
        if (result == NSAlertFirstButtonReturn){
            [model loadDialog];
         }
    }];
#else
    NSBeginAlertSheet(@"Replace these dialog values with values read from hardware!",
                      @"Yes",
                      @"Cancel",
                      nil,[self window],
                      self,
                      @selector(_doItSheetDidEnd:returnCode:contextInfo:),
                      nil,
                      nil,@"Really replace all values? This can not be undone!");
#endif
	
}

- (double) getBarValue:(int)tag
{
	
	return [[[[model sampleRateGroup] rates] objectAtIndex:tag] rate];
}

- (int) numberPointsInPlot:(id)aPlotter;
{
	int set = (int)[aPlotter tag];
	int len =  [model lengthBuffer:set];
	if(len<0)return 0;
	else return len;
}

- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue;
{
	int set = (int)[aPlotter tag];
	*yValue =  [model buffer:i set:set];
	*xValue = i;
}
@end

#if !defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
@implementation ORAcqirisDC440Controller (private)
- (void) _doItSheetDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(NSDictionary*)userInfo
{
    if(returnCode == NSAlertFirstButtonReturn){
		[model loadDialog];
	}
}
@end
#endif


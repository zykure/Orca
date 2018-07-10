//--------------------------------------------------------
// ORRad7Controller
// Created by Mark  A. Howe on Fri Jul 22 2005
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

#import "ORRad7Controller.h"
#import "ORRad7Model.h"
#import "ORTimeLinePlot.h"
#import "ORTimeAxis.h"
#import "ORSerialPortController.h"

#if !defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
@interface ORRad7Controller (private)
- (void) saveUserSettingPanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(id)info;
- (void) loadDialogFromHWPanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(id)info;
- (void) eraseAllDataPanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(id)info;
@end
#endif

@implementation ORRad7Controller

#pragma mark ***Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"Rad7"];
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [blankView release];
	[super dealloc];
}

- (void) awakeFromNib
{
    [[plotter0 yAxis] setRngLow:0.0 withHigh:300.];
	[[plotter0 yAxis] setRngLimitsLow:-300.0 withHigh:500 withMinRng:4];
	
    [[plotter0 xAxis] setRngLow:0.0 withHigh:10000];
	[[plotter0 xAxis] setRngLimitsLow:0.0 withHigh:200000. withMinRng:200];
	
	
	ORTimeLinePlot* aPlot1;
	aPlot1= [[ORTimeLinePlot alloc] initWithTag:0 andDataSource:self];
	[aPlot1 setLineColor:[NSColor redColor]];
	[plotter0 addPlot: aPlot1];
	[aPlot1 setName:@"Radon"];
	[aPlot1 release];
	
	ORTimeLinePlot* aPlot2;
	aPlot2 = [[ORTimeLinePlot alloc] initWithTag:1 andDataSource:self];
	[aPlot2 setLineColor:[NSColor blueColor]];
	[plotter0 addPlot: aPlot2];
	[aPlot2 setName:@"RH"];
	[aPlot2 release];
	
	[plotter0 setShowLegend:YES];
	
	int i;
	for(i=0;i<2;i++){
		[[plotter0 plot:i] setRoi: [[model rois:i] objectAtIndex:0]];
	}
	
	[(ORTimeAxis*)[plotter0 xAxis] setStartTime: [[NSDate date] timeIntervalSince1970]];
	
	blankView = [[NSView alloc] init];
    basicOpsSize	= NSMakeSize(440,685);
    processOpsSize	= NSMakeSize(410,205);
    historyOpsSize	= NSMakeSize(435,280);
    summaryOpsSize	= NSMakeSize(400,230);
	NSString* key = [NSString stringWithFormat: @"orca.ORRad7%lu.selectedtab",[model uniqueIdNumber]];
    int index = [[NSUserDefaults standardUserDefaults] integerForKey: key];
	if((index<0) || (index>[tabView numberOfTabViewItems]))index = 0;
	[tabView selectTabViewItemAtIndex: index];
	
	NSUInteger style = [[self window] styleMask];
	if(index == 2){
		[[self window] setStyleMask: style | NSResizableWindowMask];
	}
	else {
		[[self window] setStyleMask: style & ~NSResizableWindowMask];
	}
	
	
	[super awakeFromNib];
}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"Rad7 (Unit %lu)",[model uniqueIdNumber]]];
}

#pragma mark ***Notifications

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
	
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORRad7Lock
                        object: nil];
	
    [notifyCenter addObserver : self
                     selector : @selector(pollTimeChanged:)
                         name : ORRad7ModelPollTimeChanged
                       object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(scaleAction:)
						 name : ORAxisRangeChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(miscAttributesChanged:)
						 name : ORMiscAttributesChanged
					   object : model];
	
    [notifyCenter addObserver : self
                     selector : @selector(protocolChanged:)
                         name : ORRad7ModelProtocolChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(cycleTimeChanged:)
                         name : ORRad7ModelCycleTimeChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(recycleChanged:)
                         name : ORRad7ModelRecycleChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(modeChanged:)
                         name : ORRad7ModelModeChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(thoronChanged:)
                         name : ORRad7ModelThoronChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(pumpModeChanged:)
                         name : ORRad7ModelPumpModeChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(toneChanged:)
                         name : ORRad7ModelToneChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(formatChanged:)
                         name : ORRad7ModelFormatChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(tUnitsChanged:)
                         name : ORRad7ModelTUnitsChanged
						object: model];
	
	
    [notifyCenter addObserver : self
                     selector : @selector(rUnitsChanged:)
                         name : ORRad7ModelRUnitsChanged
						object: model];
		
    [notifyCenter addObserver : self
                     selector : @selector(statusChanged:)
                         name : ORRad7ModelStatusChanged
						object: model];	
	
    [notifyCenter addObserver : self
                     selector : @selector(runStateChanged:)
                         name : ORRad7ModelRunStateChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(updatePlot:)
                         name : ORRad7ModelUpdatePlot
						object: model];	
	
    [notifyCenter addObserver : self
                     selector : @selector(updatePlot:)
                         name : ORRad7ModelDataPointArrayChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(runToPrintChanged:)
                         name : ORRad7ModelRunToPrintChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(deleteDataOnStartChanged:)
                         name : ORRad7ModelDeleteDataOnStartChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(verboseChanged:)
                         name : ORRad7ModelVerboseChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(makeFileChanged:)
                         name : ORRad7ModelMakeFileChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(maxRadonChanged:)
                         name : ORRad7ModelMaxRadonChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(alarmLimitChanged:)
                         name : ORRad7ModelAlarmLimitChanged
						object: model];
	
	
    [notifyCenter addObserver : self
                     selector : @selector(humidityAlarmChanged:)
                         name : ORRad7ModelHumidityAlarmChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(pumpCurrentAlarmChanged:)
                         name : ORRad7ModelPumpCurrentAlarmChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(pumpCurrentMaxLimitChanged:)
                         name : ORRad7ModelPumpCurrentMaxLimitChanged
						object: model];
	
    [notifyCenter addObserver : self
                     selector : @selector(humidityMaxLimitChanged:)
                         name : ORRad7ModelHumidityMaxLimitChanged
						object: model];
	

    [notifyCenter addObserver : self
                     selector : @selector(statusStringChanged:)
                         name : ORRad7ModelStatusStringChanged
                        object: model];

    
	[serialPortController registerNotificationObservers];
	
    [notifyCenter addObserver : self
                     selector : @selector(radLinkLoadingChanged:)
                         name : ORRad7ModelRadLinkLoadingChanged
						object: model];

}

- (void) updateWindow
{
    [super updateWindow];
    [self lockChanged:nil];
	[self pollTimeChanged:nil];
    [self miscAttributesChanged:nil];
	[self protocolChanged:nil];
	[self cycleTimeChanged:nil];
	[self recycleChanged:nil];
	[self modeChanged:nil];
	[self thoronChanged:nil];
	[self pumpModeChanged:nil];
	[self toneChanged:nil];
	[self formatChanged:nil];
	[self tUnitsChanged:nil];
	[self rUnitsChanged:nil];
	[self statusChanged:nil];
	[self runStateChanged:nil];
	[self updatePlot:nil];
	[self runToPrintChanged:nil];
	[self deleteDataOnStartChanged:nil];
	[self verboseChanged:nil];
	[self makeFileChanged:nil];
	[self maxRadonChanged:nil];
	[self alarmLimitChanged:nil];
	[self humidityAlarmChanged:nil];
	[self pumpCurrentAlarmChanged:nil];
	[self pumpCurrentMaxLimitChanged:nil];
    [self humidityMaxLimitChanged:nil];
    [self statusStringChanged:nil];
	[serialPortController updateWindow];
	[self radLinkLoadingChanged:nil];
}

- (void) radLinkLoadingChanged:(NSNotification*)aNote
{
	[radLinkLoadingField setStringValue: [model radLinkLoading]?@"Busy":@""];
	[self updateButtons];
}

- (BOOL) portLocked
{
	return [gSecurity isLocked:ORRad7Lock];;
}
- (void) humidityMaxLimitChanged:(NSNotification*)aNote
{
	[humidityMaxLimitTextField setFloatValue: [model humidityMaxLimit]];
}

- (void) pumpCurrentMaxLimitChanged:(NSNotification*)aNote
{
	[pumpCurrentMaxLimitTextField setFloatValue: [model pumpCurrentMaxLimit]];
}

- (void) pumpCurrentAlarmChanged:(NSNotification*)aNote
{
	[pumpCurrentAlarmTextField setFloatValue: [model pumpCurrentAlarm]];
}

- (void) humidityAlarmChanged:(NSNotification*)aNote
{
	[humidityAlarmTextField setFloatValue: [model humidityAlarm]];
}

- (void) alarmLimitChanged:(NSNotification*)aNote
{
	[alarmLimitTextField setIntValue: [model alarmLimit]];
}

- (void) maxRadonChanged:(NSNotification*)aNote
{
	[maxRadonTextField setIntValue: [model maxRadon]];
}

- (void) makeFileChanged:(NSNotification*)aNote
{
	[makeFileCB setIntValue: [model makeFile]];
}

- (void) verboseChanged:(NSNotification*)aNote
{
	[verboseCB setIntValue: [model verbose]];
}

- (void) deleteDataOnStartChanged:(NSNotification*)aNote
{
	[deleteDataOnStartCB setIntValue: [model deleteDataOnStart]];
}

- (void) runToPrintChanged:(NSNotification*)aNote
{
	[runToPrintTextField setIntValue: [model runToPrint]];
}

- (void) updatePlot:(NSNotification*)aNote
{
	[plotter0 setNeedsDisplay:YES];
}

- (void) runStateChanged:(NSNotification*)aNote
{
	[self updateButtons];
}

- (void) statusChanged:(NSNotification*)aNote
{	
	[stateField setObjectValue:      [model statusForKey:kRad7RunStatus]];
	[runNumberField setObjectValue:  [model statusForKey:kRad7RunNumber]];
	[cycleNumberField setObjectValue:[model statusForKey:kRad7CycleNumber]];
	[pumpModeField setObjectValue:	 [model statusForKey:kRad7RunPumpStatus]];
	[countDownField setObjectValue:	 [model statusForKey:kRad7RunCountDown]];
	[countsField setObjectValue:	 [model statusForKey:kRad7NumberCounts]];
	[freeCyclesField setObjectValue: [model statusForKey:kRad7FreeCycles]];
	[lastRunNumberField setObjectValue:  [model statusForKey:kRad7LastRunNumber]];
	[lastCycleNumberField setObjectValue:[model statusForKey:kRad7LastCycleNumber]];
	[lastRadonField setObjectValue:[model statusForKey:kRad7LastRadon]];
	[lastRadonUnitsField setObjectValue:[model statusForKey:kRad7LastRadonUnits]];
	[processUnitsField setObjectValue:[model statusForKey:kRad7LastRadonUnits]];
	[lastRadonUncertaintyField setObjectValue:[model statusForKey:kRad7LastRadonUncertainty]];
	
	
	[temperatureField setObjectValue:[model statusForKey:kRad7Temp]];
	[temperatureUnitsField setObjectValue:[model statusForKey:kRad7TempUnits]];
	[rhField setObjectValue:[model statusForKey:kRad7RH]];
	[batteryField setObjectValue:[model statusForKey:kRad7Battery]];
	[pumpCurrentField setObjectValue:[model statusForKey:kRad7PumpCurrent]];
	[hvField setObjectValue:[model statusForKey:kRad7HV]];
	[signalField setObjectValue:[model statusForKey:kRad7SignalVoltage]];
	
	[countDown2Field setObjectValue:	 [model statusForKey:kRad7RunCountDown]];
	[state2Field setObjectValue:      [model statusForKey:kRad7RunStatus]];
	[lastRadonUnits2Field setObjectValue:[model statusForKey:kRad7LastRadonUnits]];
	[temperature2Field setObjectValue:[model statusForKey:kRad7Temp]];
	[temperatureUnits2Field setObjectValue:[model statusForKey:kRad7TempUnits]];
	[rh2Field setObjectValue:[model statusForKey:kRad7RH]];
	[battery2Field setObjectValue:[model statusForKey:kRad7Battery]];
	[pumpCurrent2Field setObjectValue:[model statusForKey:kRad7PumpCurrent]];
	[hv2Field setObjectValue:[model statusForKey:kRad7HV]];
	[signal2Field setObjectValue:[model statusForKey:kRad7SignalVoltage]];
	[lastRadon2Field setObjectValue:[model statusForKey:kRad7LastRadon]];
	[lastRadonUncertainty2Field setObjectValue:[model statusForKey:kRad7LastRadonUncertainty]];
	
}


- (void) statusStringChanged:(NSNotification *)aNote
{
	[statusStateField setStringValue: [model statusString]];
	[self updateButtons];
}

- (void) tUnitsChanged:(NSNotification*)aNote
{
	[tUnitsPU selectItemAtIndex: [model tUnits]];
}

- (void) rUnitsChanged:(NSNotification*)aNote
{
	[rUnitsPU selectItemAtIndex: [model rUnits]];
}

- (void) formatChanged:(NSNotification*)aNote
{
	[formatPU selectItemAtIndex: [model formatSetting]];
}

- (void) toneChanged:(NSNotification*)aNote
{
	[tonePU selectItemAtIndex: [model tone]];
}

- (void) pumpModeChanged:(NSNotification*)aNote
{
	[pumpModePU selectItemAtIndex: [model pumpMode]];
}

- (void) thoronChanged:(NSNotification*)aNote
{
	[thoronPU selectItemAtIndex: [model thoron]];
}

- (void) modeChanged:(NSNotification*)aNote
{
	[modePU selectItemAtIndex: [model mode]];
}

- (void) recycleChanged:(NSNotification*)aNote
{
	[recycleTextField setIntValue: [model recycle]];
}

- (void) cycleTimeChanged:(NSNotification*)aNote
{
	[cycleTimeTextField setIntValue: [model cycleTime]];
}

- (void) protocolChanged:(NSNotification*)aNote
{
	[protocolPU selectItemAtIndex: [(ORRad7Model*)model protocol]];
	if([(ORRad7Model*)model protocol] == kRad7ProtocolNone)		[protocolTabView selectTabViewItemAtIndex:0];
	else if([(ORRad7Model*)model protocol] == kRad7ProtocolUser)	[protocolTabView selectTabViewItemAtIndex:1];
	else											[protocolTabView selectTabViewItemAtIndex:2];
	[self updateButtons];
}

- (void) scaleAction:(NSNotification*)aNotification
{
	if(aNotification == nil || [aNotification object] == [plotter0 xAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 xAxis]attributes] forKey:@"XAttributes0"];
	};
	
	if(aNotification == nil || [aNotification object] == [plotter0 yAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter0 yAxis]attributes] forKey:@"YAttributes0"];
	};
}

- (void) miscAttributesChanged:(NSNotification*)aNote
{
	
	NSString*				key = [[aNote userInfo] objectForKey:ORMiscAttributeKey];
	NSMutableDictionary* attrib = [model miscAttributesForKey:key];
	
	if(aNote == nil || [key isEqualToString:@"XAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"XAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter0 xAxis] setAttributes:attrib];
			[plotter0 setNeedsDisplay:YES];
			[[plotter0 xAxis] setNeedsDisplay:YES];
		}
	}
	if(aNote == nil || [key isEqualToString:@"YAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"YAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter0 yAxis] setAttributes:attrib];
			[plotter0 setNeedsDisplay:YES];
			[[plotter0 yAxis] setNeedsDisplay:YES];
		}
	}
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORRad7Lock to:secure];
    [lockButton setEnabled:secure];
}

- (void) lockChanged:(NSNotification*)aNotification
{
	[self updateButtons];
}

- (void) updateButtons
{
    BOOL locked = [gSecurity isLocked:ORRad7Lock];
	BOOL radLinkLoading = [model radLinkLoading];
    [lockButton setState: locked];
	
	[serialPortController updateButtons:locked && !radLinkLoading];
	
    [pollTimePopup setEnabled:!locked && !radLinkLoading];
	[pollNowButton setEnabled:!radLinkLoading];
    [deleteHistoryButton setEnabled:!locked && !radLinkLoading];
    [radLinkButton setEnabled:!locked && !radLinkLoading];
	
	int runState = [model runState];
	//BOOL idle = (opState==kRad7Idle);
	BOOL counting = runState == kRad7RunStateCounting;
	if(!locked && !radLinkLoading){
		if(runState== kRad7RunStateUnKnown){
			[startTestButton	setEnabled:	 NO];
			[stopTestButton		setEnabled:  NO];
			[eraseAllDataButton setEnabled:  NO];
			[printRunButton		setEnabled:  NO];
			[printCycleButton	setEnabled:  NO];
			[runToPrintTextField setEnabled:  NO];
			[deleteDataOnStartCB setEnabled:  NO];
			[verboseCB			 setEnabled:  NO];
			[makeFileCB			 setEnabled:  NO];
			[loadDialogButton	setEnabled:  NO];
		}
		else if(runState== kRad7RunStateCounting){
			[startTestButton	setEnabled:	 NO];
			[stopTestButton		setEnabled:  YES];
			[eraseAllDataButton setEnabled:  NO];
			[printRunButton		setEnabled:  NO];
			[printCycleButton	setEnabled:  YES];
			[runToPrintTextField setEnabled:  NO];
			[deleteDataOnStartCB setEnabled:  NO];
			[verboseCB			 setEnabled:  YES];
			[makeFileCB			 setEnabled:  YES];
			[loadDialogButton	setEnabled:  NO];
		}
		else {
			[startTestButton	setEnabled:	 YES];
			[stopTestButton		setEnabled:  NO];
			[eraseAllDataButton setEnabled:  YES];
			[printRunButton		setEnabled:  YES];
			[printCycleButton	setEnabled:  NO];
			[runToPrintTextField setEnabled: YES];
			[deleteDataOnStartCB setEnabled: YES];
			[verboseCB			 setEnabled:  NO];
			[makeFileCB			 setEnabled:  NO];
			[loadDialogButton	setEnabled:  YES];
		}
	}
	else {
		[startTestButton	setEnabled:	 NO];
		[stopTestButton		setEnabled:  NO];
		[eraseAllDataButton setEnabled:  NO];
		[printRunButton		setEnabled:  NO];
		[printCycleButton	setEnabled:  NO];
		[runToPrintTextField setEnabled:  NO];
		[deleteDataOnStartCB setEnabled:  NO];
		[verboseCB			 setEnabled:  NO];
		[makeFileCB			 setEnabled:  NO];
		[loadDialogButton	setEnabled:  NO];
	}
	
	//[initHWButton		setEnabled:  !counting && idle && !locked];
	
	[rUnitsPU setEnabled:	!counting && !locked && !radLinkLoading];
	[tUnitsPU setEnabled:	!counting && !locked && !radLinkLoading];
	[formatPU setEnabled:	!counting && !locked && !radLinkLoading];
	[tonePU setEnabled:		!counting && !locked && !radLinkLoading];
	[protocolPU setEnabled:	!counting && !locked && !radLinkLoading];
	
	[saveUserProtocolButton setEnabled:([(ORRad7Model*)model protocol] == kRad7ProtocolNone) && !radLinkLoading ];
	
	[alarmLimitTextField setEnabled:!locked && !radLinkLoading];
	[maxRadonTextField setEnabled:	!locked && !radLinkLoading];
	
	
	if([(ORRad7Model*)model protocol] == kRad7ProtocolUser || [(ORRad7Model*)model protocol] == kRad7ProtocolNone){
		[pumpModePU setEnabled:	!counting && !locked && !radLinkLoading];
		[thoronPU setEnabled:	!counting && !locked && !radLinkLoading];
		[modePU setEnabled:		!counting && !locked && !radLinkLoading];
		[recycleTextField setEnabled: !counting && !locked && !radLinkLoading];
		[cycleTimeTextField setEnabled: !counting && !locked && !radLinkLoading];
		
	}
	else {
		switch([(ORRad7Model*)model protocol]){
			case kRad7ProtocolNone: 
				break;
				
			case kRad7ProtocolSniff:
				[useCycleField setObjectValue:		@"5"];
				[userRecycleField setObjectValue:	@"0"];
				[userModeField setObjectValue:		@"Sniff"];
				[userThoronField setObjectValue:	@"Off"];
				[userPumpModeField setObjectValue:	@"Auto"];
				break;
				
			case kRad7Protocol1Day:
				[useCycleField setObjectValue:		@"30"];
				[userRecycleField setObjectValue:	@"48"];
				[userModeField setObjectValue:		@"Auto"];
				[userThoronField setObjectValue:	@"Off"];
				[userPumpModeField setObjectValue:	@"Auto"];
				break;
				
			case kRad7Protocol2Day:
				[useCycleField setObjectValue:		@"60"];
				[userRecycleField setObjectValue:	@"48"];
				[userModeField setObjectValue:		@"Auto"];
				[userThoronField setObjectValue:	@"Off"];
				[userPumpModeField setObjectValue:	@"Auto"];
				break;
				
			case kRad7ProtocolWeeks:
				[useCycleField setObjectValue:		@"60"];
				[userRecycleField setObjectValue:	@"48"];
				[userModeField setObjectValue:		@"Auto"];
				[userThoronField setObjectValue:	@"Off"];
				[userPumpModeField setObjectValue:	@"Auto"];
				break;
				
			case kRad7ProtocolUser:
				break;
				
			case kRad7ProtocolGrab:
				[useCycleField setObjectValue:		@"5"];
				[userRecycleField setObjectValue:	@"4"];
				[userModeField setObjectValue:		@"Sniff"];
				[userThoronField setObjectValue:	@"Off"];
				[userPumpModeField setObjectValue:	@"Grab"];
				break;
				
			case kRad7ProtocolWat40:
				[useCycleField setObjectValue:		@"5"];
				[userRecycleField setObjectValue:	@"4"];
				[userModeField setObjectValue:		@"Wat-40"];
				[userThoronField setObjectValue:	@"Off"];
				[userPumpModeField setObjectValue:	@"Grab"];
				break;
				
			case kRad7ProtocolWat250:
				[useCycleField setObjectValue:		@"5"];
				[userRecycleField setObjectValue:	@"4"];
				[userModeField setObjectValue:		@"Wat250"];
				[userThoronField setObjectValue:	@"Off"];
				[userPumpModeField setObjectValue:	@"Grab"];
				break;
				
			case kRad7ProtocolThoron:
				[useCycleField setObjectValue:		@"5"];
				[userRecycleField setObjectValue:	@"0"];
				[userModeField setObjectValue:		@"Sniff"];
				[userThoronField setObjectValue:	@"On"];
				[userPumpModeField setObjectValue:	@"Auto"];
				break;
		}
	}
}

- (void) pollTimeChanged:(NSNotification*)aNotification
{
	[pollTimePopup selectItemWithTag:[model pollTime]];
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [[self window] setContentView:blankView];
	NSUInteger style = [[self window] styleMask];
	switch([tabView indexOfTabViewItem:tabViewItem]){
		case  0: 
			[self resizeWindowToSize:basicOpsSize];   
			[[self window] setStyleMask: style & ~NSResizableWindowMask];
			break;
		case  1: 
			[self resizeWindowToSize:processOpsSize];     
			[[self window] setStyleMask: style & ~NSResizableWindowMask];
			break;
		case  2: 
			[self resizeWindowToSize:historyOpsSize];	
			[[self window] setStyleMask: style | NSResizableWindowMask];
			break;
		default: 
			[self resizeWindowToSize:summaryOpsSize];     
			[[self window] setStyleMask: style & ~NSResizableWindowMask];
			break;
	}
    [[self window] setContentView:totalView];
	
    NSString* key = [NSString stringWithFormat: @"orca.ORRad7%lu.selectedtab",[model uniqueIdNumber]];
    int index = [tabView indexOfTabViewItem:tabViewItem];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:key];
}

- (void)windowDidResize:(NSNotification *)notification
{
	if([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 2){
		historyOpsSize = [[self window] frame].size; 
	}
}

#pragma mark ***Actions

- (void) humidityMaxLimitTextFieldAction:(id)sender
{
	[model setHumidityMaxLimit:[sender floatValue]];	
}

- (void) pumpCurrentMaxLimitTextFieldAction:(id)sender
{
	[model setPumpCurrentMaxLimit:[sender floatValue]];	
}

- (void) pumpCurrentAlarmTextFieldAction:(id)sender
{
	[model setPumpCurrentAlarm:[sender floatValue]];	
}

- (void) humidityAlarmTextFieldAction:(id)sender
{
	[model setHumidityAlarm:[sender floatValue]];	
}

- (void) alarmLimitTextFieldAction:(id)sender
{
	[model setAlarmLimit:[sender intValue]];	
}

- (void) maxRadonTextFieldAction:(id)sender
{
	[model setMaxRadon:[sender intValue]];	
}

- (void) makeFileAction:(id)sender
{
	[model setMakeFile:[sender intValue]];	
}

- (void) verboseAction:(id)sender
{
	[model setVerbose:[sender intValue]];	
}

- (void) deleteDataOnStartAction:(id)sender
{
	[model setDeleteDataOnStart:[sender intValue]];	
}

- (void) runToPrintTextFieldAction:(id)sender
{
	[model setRunToPrint:[sender intValue]];	
}

- (void) tUnitsAction:(id)sender
{
	[model setTUnits:[sender indexOfSelectedItem]];	
}

- (void) rUnitsAction:(id)sender
{
	[model setRUnits:[sender indexOfSelectedItem]];	
}

- (void) formatAction:(id)sender
{
	[model setFormatSetting:[sender indexOfSelectedItem]];	
}

- (void) toneAction:(id)sender
{
	[model setTone:[sender indexOfSelectedItem]];	
}

- (void) pumpModeAction:(id)sender
{
	[model setPumpMode:[sender indexOfSelectedItem]];	
}

- (void) thoronAction:(id)sender
{
	[model setThoron:[sender indexOfSelectedItem]];	
}

- (void) modeAction:(id)sender
{
	[model setMode:[sender indexOfSelectedItem]];	
}

- (void) recycleTextFieldAction:(id)sender
{
	[model setRecycle:[sender intValue]];	
}

- (void) cycleTimeTextFieldAction:(id)sender
{
	[model setCycleTime:[sender intValue]];	
}

- (void) protocolAction:(id)sender
{
	[(ORRad7Model*)model setProtocol:[sender indexOfSelectedItem]];
}


- (IBAction) lockAction:(id) sender
{
    [gSecurity tryToSetLock:ORRad7Lock to:[sender intValue] forWindow:[self window]];
}

- (IBAction) updateSettingsAction:(id)sender
{
	
#if defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Load Dialog With Hardware Settings"];
    [alert setInformativeText:@"Really replace the settings in the dialog with the current HW settings?"];
    [alert addButtonWithTitle:@"Yes/Do it NOW"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result){
        if (result == NSAlertFirstButtonReturn){
            [model loadDialogFromHardware];
       }
    }];
#else
    NSBeginAlertSheet(@"Load Dialog With Hardware Settings",
					  @"YES/Do it NOW",
					  @"Cancel",
					  nil,
					  [self window],
					  self,
					  @selector(loadDialogFromHWPanelDidEnd:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really replace the settings in the dialog with the current HW settings?");
#endif
	
}

- (IBAction) eraseAllDataAction:(id)sender
{
	
#if defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Erase All Data"];
    [alert setInformativeText:@"Really erase ALL data?"];
    [alert addButtonWithTitle:@"Yes/Do it NOW"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result){
        if (result == NSAlertFirstButtonReturn){
            [model dataErase];
        }
    }];
#else
    NSBeginAlertSheet(@"Erase All Data",
					  @"YES/Do it NOW",
					  @"Cancel",
					  nil,
					  [self window],
					  self,
					  @selector(eraseAllDataPanelDidEnd:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really erase ALL data?");
#endif
	
}

- (IBAction) radLinkSelection:(id)sender
{
	[NSApp beginSheet:radLinkSelectionPanel modalForWindow:[self window] modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction) radLinkLoadOps:(id)sender
{
	[radLinkSelectionPanel orderOut:nil];
	[NSApp endSheet:radLinkSelectionPanel];
 	int index = [radLinkSelectionMatrix selectedRow];
	if(index==0){
		[NSApp beginSheet:radLinkLoadPanel modalForWindow:[self window]
			modalDelegate:self didEndSelector:NULL contextInfo:nil];
	}	
	else {
        [self getRadLinkFile];
	}
}


- (IBAction) closeLinkSelectionPanel:(id)sender
{
    [radLinkSelectionPanel orderOut:nil];
    [NSApp endSheet:radLinkSelectionPanel];
}

- (IBAction) closeLinkLoadPanel:(id)sender
{
    [radLinkLoadPanel orderOut:nil];
    [NSApp endSheet:radLinkLoadPanel];
}

- (IBAction) doRadLinkLoad:(id)sender
{
    [radLinkLoadPanel orderOut:nil];
    [NSApp endSheet:radLinkLoadPanel];
    [self getRadLinkFile];
}

- (void) getRadLinkFile
{
	int index = [radLinkSelectionMatrix selectedRow];

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:NO];
    if(index==0)[openPanel setPrompt:@"Choose File With RadLink code"];
	else		[openPanel setPrompt:@"Choose File That Removes RadLink"];
    NSString* startingDir = NSHomeDirectory();
	
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:startingDir]];
    [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton){
			[model loadRadLinkFile:[[openPanel URL]path] index:index];
        }
    }];
}

- (IBAction) pollTimeAction:(id)sender
{
	[model setPollTime:[[sender selectedItem] tag]];
}

- (IBAction) getStatusAction:(id)sender
{
	[model pollHardware];
}

- (IBAction) startAction:(id)sender
{
	[self endEditing];
	[startTestButton setEnabled:NO];
	[stopTestButton setEnabled:NO];
	[model performSelector:@selector(specialStart) withObject:nil afterDelay:0];
}

- (IBAction) stopAction:(id)sender
{
	[startTestButton setEnabled:NO];
	[stopTestButton setEnabled:NO];
	[model performSelector:@selector(specialStop) withObject:nil afterDelay:0];
}

- (IBAction) saveUserSettings:(id)sender;
{
#if defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Save Settings As New User Protocol"];
    [alert setInformativeText:@"Really make the current settings the new user protocol?"];
    [alert addButtonWithTitle:@"Yes/Do it NOW"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result){
        if (result == NSAlertFirstButtonReturn){
            [model saveUser];
        }
    }];
#else
    NSBeginAlertSheet(@"Save Settings As New User Protocol",
					  @"YES/Do it NOW",
					  @"Cancel",
					  nil,
					  [self window],
					  self,
					  @selector(saveUserSettingPanelDidEnd:returnCode:contextInfo:),
					  nil,
					  nil,
					  @"Really make the current settings the new user protocol?");
#endif
}

- (IBAction) sendControlC:(id)sender
{
    [model stopOpsAndInterrupt];
}
- (IBAction) printRunAction:(id)sender
{
	[self endEditing];
	[model printRun];
}

- (IBAction) printDataInProgress:(id)sender
{
	[model printDataInProgress];
}

- (IBAction)doAnalysis:(NSToolbarItem*)item
{
	[analysisDrawer toggle:self];
}

#pragma mark ***Data Source
- (int) numberPointsInPlot:(id)aPlot
{
	return [model numPoints];
}

- (void) plotter:(id)aPlot index:(int)i x:(double*)xValue y:(double*)yValue
{
	int theTag = [aPlot tag];
	int count = [model numPoints];
	int index = count-i-1;
	*xValue = [model radonTime:index];
	if(theTag == 0) *yValue = [model radonValue:index];
	else            *yValue = [model rhValue:index];
}

@end

#if !defined(MAC_OS_X_VERSION_10_10) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 // 10.10-specific

@implementation ORRad7Controller (private)

- (void) saveUserSettingPanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(id)info
{
	[model saveUser];
}

- (void) loadDialogFromHWPanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(id)info
{
	[model loadDialogFromHardware];
}

- (void) eraseAllDataPanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(id)info
{
	[model dataErase];
}

@end
#endif
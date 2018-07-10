//--------------------------------------------------------
// ORSynClockController
// Created by Mark  A. Howe on Fri Jul 22 2005 / Julius Hartmann, KIT, November 2017
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
//for the use of this softwarePulser.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORSynClockController.h"
#import "ORSynClockModel.h"
#import "ORRefClockModel.h"

@implementation ORSynClockController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [topLevelObjects release];
    
    [super dealloc];
}

#pragma mark ***Initialization
- (void) awakeFromNib
{
    if(!deviceContent){
        if ([[NSBundle mainBundle] loadNibNamed:@"SynClock" owner:self  topLevelObjects:&topLevelObjects]){
            [topLevelObjects retain];
            [deviceView setContentView:deviceContent];
            [[self model] setStatusPoll:[statusPollCB state]];
        }
        else NSLog(@"Failed to load SynClock.nib");
    }
}

- (id) model
{
    return model;
}

- (void) setModel:(ORSynClockModel*)aModel
{
    model = aModel;
    [self registerNotificationObservers];
    [self updateWindow];
}

#pragma mark ***Notifications
- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
 
		[notifyCenter addObserver : self
		                 selector : @selector(trackModeChanged:)
		                     name : ORSynClockModelTrackModeChanged
                            object: model];

		 [notifyCenter addObserver : self
                          selector : @selector(syncChanged:)
                              name : ORSynClockModelSyncChanged
                             object: model];

		 [notifyCenter addObserver : self
                          selector : @selector(alarmWindowChanged:)
                              name : ORSynClockModelAlarmWindowChanged
                             object: model];

        [notifyCenter addObserver : self
                         selector : @selector(statusChanged:)
                             name : ORSynClockModelStatusChanged
                            object: model];

		[notifyCenter addObserver : self
                         selector : @selector(statusPollChanged:)
                             name : ORSynClockModelStatusPollChanged
                            object: model];
    
        [notifyCenter addObserver : self
                         selector : @selector(statusMessageChanged:)
                             name : ORSynClockStatusUpdated
                            object: nil];
    
        [notifyCenter addObserver : self
                         selector : @selector(iDChanged:)
                             name : ORSynClockIDChanged
                            object: nil];
}

- (void) updateWindow
{
    [self trackModeChanged:nil];
    [self syncChanged:nil];
    [self alarmWindowChanged:nil];
    [self statusChanged:nil];
    [self statusPollChanged:nil];
    [self statusMessageChanged:nil];
}

- (void) setButtonStates
{
    //BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORRefClockLock];
    //BOOL locked = [gSecurity isLocked:ORRefClockLock];
    BOOL portOpen = [model portIsOpen];

    [trackModePU        setEnabled:!lockedOrRunningMaintenance && portOpen];
    [syncPU             setEnabled:!lockedOrRunningMaintenance && portOpen];
    [alarmWindowField   setEnabled:!lockedOrRunningMaintenance && portOpen];
    [statusButton       setEnabled:!lockedOrRunningMaintenance && portOpen];
    [statusPollCB       setEnabled:!lockedOrRunningMaintenance && portOpen];
    [deviceIDButton     setEnabled:!lockedOrRunningMaintenance && portOpen];
    [resetButton        setEnabled:!lockedOrRunningMaintenance && portOpen];
}

- (void) trackModeChanged:(NSNotification*)aNote
{
    if([model trackMode] == 3){
        [trackModePU selectItemAtIndex:1];
    } else [trackModePU selectItemAtIndex:0];
}

- (void) syncChanged:(NSNotification*)aNote
{
    if([model syncMode] == 3){
        [syncPU selectItemAtIndex:1];
    }else [syncPU selectItemAtIndex:0];
}

- (void) alarmWindowChanged:(NSNotification*)aNote
{
    [alarmWindowField setIntValue:[model alarmWindow]];
}

- (void) statusChanged:(NSNotification*)aNote
{
}

- (void) statusPollChanged:(NSNotification*)aNote
{
    [statusPollCB setIntValue:[model statusPoll]];
}

- (void) lockChanged:(NSNotification*)aNotification
{
    [self setButtonStates];
}

- (void) statusMessageChanged:(NSNotification*)aNote
{
    if([[model refClockModel] verbose]){
        NSLog(@"statusMessageChanged!! updating... \n");
    }
    [statusOutputField setStringValue:[model statusMessages]];
}

- (void) iDChanged:(NSNotification*)aNotification{
    if([[model refClockModel] verbose]){
        NSLog(@"iDChanged!! updating... \n");
    }
    [deviceIDField setStringValue:[model clockID]];
}

#pragma mark ***Actions
- (IBAction) trackModeAction:(id)sender
{
    if([sender indexOfSelectedItem] == 0){
        [model setTrackMode:0];
    }
    else if([sender indexOfSelectedItem] == 1){
        [model setTrackMode:3];
    }
    else {NSLog(@"Warning: track mode not supported! \n");}
}

- (IBAction) syncAction:(id)sender
{
    if([sender indexOfSelectedItem] == 0){
        [model setSyncMode:0];
    }
    else if([sender indexOfSelectedItem] == 1){
        [model setSyncMode:3];
    }
    else {NSLog(@"Warning: sync mode not supported! \n");}
}

- (IBAction) alarmWindowAction:(id)sender
{
    [model setAlarmWindow:[sender intValue]];
}

- (IBAction) statusAction:(id)sender
{
  [model requestStatus];
}

- (IBAction) statusPollAction:(id)sender
{
    [model setStatusPoll:[sender intValue]]; 
    // todo: activate / deactivate timer -- do in model!!
}

- (IBAction) deviceIDAction:(id)sender
{
    [model requestID];
}

- (IBAction) resetAction:(id)sender
{
    [model reset];
}
@end


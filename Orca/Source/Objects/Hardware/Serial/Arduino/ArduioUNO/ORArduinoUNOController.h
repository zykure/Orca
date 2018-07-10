//--------------------------------------------------------
// ORArduinoUNOController
// Created by Mark  A. Howe on Wed 10/17/2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina sponsored in part by the United States 
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

@class ORSerialPortController;

@interface ORArduinoUNOController : OrcaObjectController
{
    IBOutlet NSButton*		lockButton;
	IBOutlet NSTextField*	versionField;
	IBOutlet NSButton*		updateButton;
    IBOutlet NSPopUpButton* pollTimePopup;
	IBOutlet NSMatrix*		adcMatrix;
	IBOutlet NSMatrix*		customValueMatrix;
	IBOutlet NSMatrix*		pinTypeMatrix;
	IBOutlet NSMatrix*		pinNameMatrix;
	IBOutlet NSMatrix*		pinStateOutMatrix;
	IBOutlet NSMatrix*		pinStateInMatrix;
	IBOutlet NSMatrix*		pwmMatrix;
	IBOutlet NSTextField*   portStatefield2;
	IBOutlet NSMatrix*		lowLimitMatrix;
	IBOutlet NSMatrix*		hiLimitMatrix;
	IBOutlet NSMatrix*		slopeMatrix;
	IBOutlet NSMatrix*		interceptMatrix;
	IBOutlet NSMatrix*		minValueMatrix;
	IBOutlet NSMatrix*		maxValueMatrix;
	IBOutlet NSTextView*	sketchView;
    IBOutlet ORSerialPortController* serialPortController;
}

#pragma mark •••Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) versionChanged:(NSNotification*)aNote;
- (BOOL) portLocked;
- (void) updateButtons;
- (void) lockChanged:(NSNotification*)aNote;
- (void) adcChanged:(NSNotification*)aNote;
- (void) customValueChanged:(NSNotification*)aNote;
- (void) pinNameChanged:(NSNotification*)aNote;
- (void) pinTypeChanged:(NSNotification*)aNote;
- (void) pinStateInChanged:(NSNotification*)aNote;
- (void) pinStateOutChanged:(NSNotification*)aNote;
- (void) pwmChanged:(NSNotification*)aNote;
- (void) pollTimeChanged:(NSNotification*)aNote;
- (void) portStateChanged:(NSNotification*)aNote;
- (void) slopeChanged:(NSNotification*)aNote;
- (void) interceptChanged:(NSNotification*)aNote;
- (void) minValueChanged:(NSNotification*)aNote;
- (void) maxValueChanged:(NSNotification*)aNote;
- (void) lowLimitChanged:(NSNotification*)aNote;
- (void) hiLimitChanged:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) versionAction:(id)sender;
- (IBAction) pollTimeAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) updateAllAction:(id)sender;
- (IBAction) pwmAction:(id)sender;
- (IBAction) pinTypeAction:(id)sender;
- (IBAction) pinNameAction:(id)sender;
- (IBAction) pinStateOutAction:(id)sender;
- (IBAction) writeValues:(id)sender;
- (IBAction) minValueAction:(id)sender;
- (IBAction) maxValueAction:(id)sender;
- (IBAction) lowLimitAction:(id)sender;
- (IBAction) hiLimitAction:(id)sender;
- (IBAction) slopeAction:(id)sender;
- (IBAction) interceptAction:(id)sender;

@end




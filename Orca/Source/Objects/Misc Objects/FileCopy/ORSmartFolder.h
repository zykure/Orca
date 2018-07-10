//--------------------------------------------------------
// ORSmartFolder
// Created by Mark  A. Howe on Thu Apr 08 2004
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2004 CENPA, University of Washington. All rights reserved.
//--------------------------------------------------------
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

@class ORQueue;
@class ORFolderController;
@class ORFileMoverOp;

@interface ORSmartFolder : NSObject
{
    @private
	IBOutlet NSView*	view;
	IBOutlet NSTextField*   titleField;
	IBOutlet NSButton*      enableCopyButton;
	IBOutlet NSButton*      enableDeleteButton;
	IBOutlet NSButton*      chooseDirButton;
	IBOutlet NSTextField*   dirTextField;
	IBOutlet NSButton*      copyButton;
	IBOutlet NSButton*      deleteButton;
	IBOutlet NSTextField*   remoteHostTextField;
	IBOutlet NSTextField*   remotePathTextField;
	IBOutlet NSSecureTextField* passWordSecureTextField;
	IBOutlet NSTextField*   userNameTextField;
	IBOutlet NSButton*      lockButton;
	IBOutlet NSButton*      verboseButton;
	IBOutlet NSPopUpButton* transferTypePopupButton;

	NSString*    title;
	BOOL	     copyEnabled;
	BOOL	     deleteWhenCopied;
	NSString*    remoteHost;
	NSString*    remotePath;
	NSString*    remoteUserName;
	NSString*    passWord;
	BOOL	     verbose;
	NSString*    directoryName;
	NSWindow*    window;
	BOOL	     sheetDisplayed;
	BOOL		 useFolderStructure;
	NSString*	 defaultLastPathComponent;
	int          percentDone;
    BOOL         halt;
    //------------------internal use only
    NSOperationQueue*	fileQueue;
    int         workingOnFile;
    int         startCount;
    int			transferType;
    NSArray*    topLevelObjects;
}

#pragma mark ***Initialization

- (id)   init;
- (void) dealloc;
- (NSView*) view;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;
- (void) copyEnabledChanged:(NSNotification*)note;
- (void) deleteWhenCopiedChanged:(NSNotification*)note;
- (void) remoteHostChanged:(NSNotification*)note;
- (void) remotePathChanged:(NSNotification*)note;
- (void) remoteUserNameChanged:(NSNotification*)note;
- (void) passWordChanged:(NSNotification*)note;
- (void) verboseChanged:(NSNotification*)note;
- (void) directoryNameChanged:(NSNotification*)note;
- (void) queueChanged:(NSNotification*)note;
- (void) updateButtons;
- (void) updateSpecialButtons;
- (void) securityStateChanged:(NSNotification*)aNotification;
- (void) checkGlobalSecurity;
- (void) lockChanged:(NSNotification*)aNotification;
- (void) sheetChanged:(NSNotification*)aNotification;
- (void) transferTypeChanged:(NSNotification*)aNote;
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context;

#pragma mark ***Accessors
- (NSUndoManager*) undoManager;
- (int) percentDone;
- (void) setPercentDone:(NSNumber*)aPercent;
- (BOOL) useFolderStructure;
- (void) setUseFolderStructure:(BOOL)aFlag;
- (BOOL) copyEnabled;
- (void) setCopyEnabled:(BOOL)aNewCopyEnabled;
- (BOOL) deleteWhenCopied;
- (void) setDeleteWhenCopied:(BOOL)aNewDeleteWhenCopied;
- (NSString*) defaultLastPathComponent;
- (void) setDefaultLastPathComponent:(NSString*)aString;
- (NSString*) remoteHost;
- (void) setRemoteHost:(NSString*)aNewRemoteHost;
- (NSString*) remotePath;
- (void) setRemotePath:(NSString*)aNewRemotePath;
- (NSString*) remoteUserName;
- (void) setRemoteUserName:(NSString*)aNewRemoteUserName;
- (NSString*) passWord;
- (void) setPassWord:(NSString*)aNewPassWord;
- (BOOL) verbose;
- (void) setVerbose:(BOOL)aNewVerbose;
- (NSString*) finalDirectoryName;
- (NSString*) directoryName;
- (void) setDirectoryName:(NSString*)aNewDirectoryName;
- (BOOL) queueIsRunning;
- (NSString*) queueStatusString;
- (NSString *)title;
- (void)setTitle:(NSString *)aTitle;
- (NSWindow *)window;
- (void)setWindow:(NSWindow *)aWindow;
- (NSString*) lockName;
- (int) transferType;
- (void) setTransferType:(int)aNewTransferType;


#pragma mark ***Actions

- (IBAction) lockButtonAction:(id)sender;
- (IBAction) copyEnabledAction:(NSButton*)sender;
- (IBAction) deleteEnabledAction:(NSButton*)sender;
- (IBAction) chooseDirButtonAction:(id)sender;
- (IBAction) copyButtonAction:(id)sender;
- (IBAction) deleteButtonAction:(id)sender;
- (IBAction) remoteHostTextFieldAction:(id)sender;
- (IBAction) remotePathTextFieldAction:(id)sender;
- (IBAction) passWordSecureTextFieldAction:(id)sender;
- (IBAction) userNameTextFieldAction:(id)sender;
- (IBAction) verboseButtonAction:(NSButton*)sender;
- (IBAction) transferPopupButtonAction:(id)sender;


#pragma mark ���File Copying
- (void) sendAll;
- (void) deleteAll;
- (void) queueFileForSending:(NSString*)fullPath;
- (BOOL) shouldRemoveFile:(NSString*)aFile;
- (void) stopTheQueue;
- (NSString*) ensureSubFolder:(NSString*)subFolder inFolder:(NSString*)folderName;
- (NSString*) ensureExists:(NSString*)folderName;
- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary;
- (void) fileMoverIsDone;

@end

extern NSString* ORFolderCopyEnabledChangedNotification;
extern NSString* ORFolderDeleteWhenCopiedChangedNotification;
extern NSString* ORFolderRemoteHostChangedNotification;
extern NSString* ORFolderRemotePathChangedNotification;
extern NSString* ORFolderRemoteUserNameChangedNotification;
extern NSString* ORFolderPassWordChangedNotification;
extern NSString* ORFolderVerboseChangedNotification;
extern NSString* ORFolderDirectoryNameChangedNotification;
extern NSString* ORFolderTransferTypeChangedNotification;
extern NSString* ORFolderPercentDoneChanged;

extern NSString* ORFolderLock;

extern NSString* ORDataFileQueueRunningChangedNotification;
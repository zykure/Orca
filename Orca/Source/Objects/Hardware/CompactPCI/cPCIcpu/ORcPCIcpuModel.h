//--------------------------------------------------------
// ORcPCIcpuModel
// Created by Mark  A. Howe on Tue Feb 07 2006
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2006 CENPA, University of Washington. All rights reserved.
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

#pragma mark ���Imported Files

#import "ORcPCIControllerCard.h"
#import "ORDataTaker.h"
#import "SBC_Linking.h"

@class ORReadOutList;
@class ORDataPacket;
@class SBC_Link;

@interface ORcPCIcpuModel : ORcPCIControllerCard <ORDataTaker,SBC_Linking>
{
	ORReadOutList*	readOutGroup;
	SBC_Link*		sbcLink;
	NSArray*		dataTakers;			//cache of data takers.
}

#pragma mark ���Initialization
- (id)   init;
- (void) dealloc;

#pragma mark ���Accessors
- (id) adapter;
- (SBC_Link*)sbcLink;
- (ORReadOutList*)	readOutGroup;
- (void)			setReadOutGroup:(ORReadOutList*)newReadOutGroup;
- (NSMutableArray*) children;
- (long) getSBCCodeVersion;

#pragma mark ���DataTaker
- (void) load_HW_Config;
- (void) runTaskStarted:(ORDataPacket*)aDataPacket userInfo:(NSDictionary*)userInfo;
- (void) takeData:(ORDataPacket*)aDataPacket userInfo:(NSDictionary*)userInfo;
- (void) runTaskStopped:(ORDataPacket*)aDataPacket userInfo:(NSDictionary*)userInfo;
- (void) saveReadOutList:(NSFileHandle*)aFile;
- (void) loadReadOutList:(NSFileHandle*)aFile;


#pragma mark ���Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;


#pragma mark ���SBC_Linking Protocol
- (NSString*) driverScriptName;
- (NSString*) cpuName;
- (NSString*) sbcLockName;
- (NSString*) sbcLocalCodePath;
- (NSString*) codeResourcePath;

@end

extern NSString* ORcPCIcpuLock;

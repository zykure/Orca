//
//  ORIpeCrateModel.h
//  Orca
//
//  Created by Mark Howe on Fri Aug 5, 2005.
//  Copyright © 2002 CENPA, University of Washington. All rights reserved.
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


#pragma mark „„„Imported Files

#import "ORCrate.h"

@interface ORIpeCrateModel : ORCrate  {
}

#pragma mark „„„initialization
- (void) makeConnectors;
- (void) setUpImage;
- (void) makeMainController;

#pragma mark „„„Accessors
- (NSString*) adapterArchiveKey;
- (void) checkCards;

#pragma mark „„„Notifications
- (void) registerNotificationObservers;
- (id) getFireWireInterface:(NSUInteger) aVenderID;
- (void) adapterChanged:(NSNotification*)aNote;

#pragma mark „„„OROrderedObjHolding
- (int) maxNumberOfObjects;
- (int) objWidth;
- (NSRange) legalSlotsForObj:(id)anObj;
@end

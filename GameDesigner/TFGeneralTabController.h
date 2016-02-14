//
//  TFGeneralTabController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 15.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TFStonesTabController, TFGridTabController, TFGravity, TFStoneGenerator;

@interface TFGeneralTabController : NSObject

@property BOOL gravAllowDown, gravAllowLeft, gravAllowUp, gravAllowRight, gravAllowNone;
@property NSInteger gravInitialDirection;

@property(retain) IBOutlet NSTableView *stonesProbabilitiesTable;
@property(retain) IBOutlet TFStonesTabController *stonesTabController;

-(TFGravity*)gravForSaving;
-(void)loadGrav:(TFGravity*)grav;
-(TFStoneGenerator*)generatorForSaving;
-(void)loadGenerator:(TFStoneGenerator*)gen;
-(void)reloadStones;

@end

//
//  TFStonesTabController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 16.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TFStoneShaperView, TFStone, TFGeneralTabController, TFGridTabController;
#import "TFStonesController.h"

@interface TFStonesTabController : NSObject<TFStonesController>
{
	@private
	NSMutableArray* stones;
}

@property (retain) IBOutlet NSTableView *stonesTable;
@property (retain) IBOutlet TFStoneShaperView *stoneShaperView;
@property (retain) IBOutlet TFGeneralTabController *generalTabController;
@property(retain) IBOutlet TFGridTabController *gridTabController;

@property NSInteger hasSelection;

-(NSInteger)stoneCount;
-(TFStone*)stoneAtIndex:(NSInteger)index;

- (IBAction)addAndSelectNew:(id)sender;
- (IBAction)removeSelected:(id)sender;

- (void)addSquareToSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y;
- (void)removeSquareFromSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y;

-(NSArray*)stonesForSaving;
-(void)loadStones:(NSArray*)stonesToLoad;

@end

//
//  TFGridTabController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 17.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFGridView.h"
@class TFGrid, TFStonesTabController;

@interface TFGridTabController : NSObject <TFGridViewNewStoneDataSource>

@property(retain, readonly) TFGrid* grid;
@property(retain) IBOutlet TFGridView* gridView;
@property(retain) IBOutlet TFStonesTabController* stonesTabController;
@property(retain) IBOutlet NSTableView *stonesTable;

@property(nonatomic, assign) NSInteger gridWidth;
@property(nonatomic, assign) NSInteger gridHeight;

@property(nonatomic, assign) NSInteger newStonePosX;
@property(nonatomic, assign) NSInteger newStonePosY;
@property(nonatomic, assign) BOOL newStoneFixed;

-(IBAction)addStone:(id)sender;

-(TFGrid*)gridForSaving;
-(void)loadGrid:(TFGrid*)grid;

-(void)reloadStones;

@end

//
//  TFGridView.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 17.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TFGrid, TFStone, TFPosition;

#pragma mark - New Stone data source

@protocol TFGridViewNewStoneDataSource <NSObject>

@required
-(TFStone*)stoneToAdd;
-(NSInteger)addPosX;
-(NSInteger)addPosY;

@end

@protocol TFGridViewDelegate <NSObject>

@optional
-(void)clickedGridPosition:(TFPosition*)position;
-(void)doubleClickedGridPosition:(TFPosition*)position;
-(void)draggedGridPosition:(TFPosition*)position;

-(void)rightClickedGridPosition:(TFPosition*)position;
-(void)rightDoubleClickedGridPosition:(TFPosition*)position;
-(void)rightDraggedGridPosition:(TFPosition*)position;

@end


#pragma mark - The grid view interface

@interface TFGridView : NSView

@property(retain) TFGrid* grid;
@property(assign) IBOutlet NSObject<TFGridViewNewStoneDataSource> *addStoneDataSource;
@property(assign) IBOutlet NSObject<TFGridViewDelegate> *gridViewDelegate;

-(void)redrawGrid;

@end



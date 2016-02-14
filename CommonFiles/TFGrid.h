//
//  TFGrid.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFStone;
@class TFStoneOnGrid;

//	An orthoginal grid of fixed dimensions (width, height)
//	containing stones (wihich are movable and influenced by
//	gravity), fixed stones (do not change their position in the grid) and
//	required positions (which are used in some game modes to achieve level completion).
@interface TFGrid : NSObject <NSCoding>





//	Width and height of the grid.
@property(readonly) NSInteger width, height;

//	Arrays of movable and fixed stones currently on the grid.
//	Arrays contain TFStoneOnGrid objects.
@property(readonly) NSArray *stones, *fixedStones;



//	Creates a new empty grid of given dimensions that has no
//	required positions.
-(id)initWithWidth:(NSInteger)w height:(NSInteger)h;

//	Creates a new empty grid of given dimensions that has |requiredPositions|,
//	an array of |TFPosition| objects that are checked for being within |width|
//	and |height| dimensions of the grid.
-(id)initWithWidth:(NSInteger)w height:(NSInteger)h requiredPositions:(NSArray*)requiredPositions;

#pragma mark - Grid information methods


//	Fast method, checks whether the position at (x,y) is a required position,
//	returns 0 if it is not, !0 otherwise.
-(BOOL)isRequiredPositionAtX:(NSInteger)x andY:(NSInteger)y;

//	Returns an array of |TFPosition| objects, one for each required position
//	in this grid.
-(NSArray*)requiredPositions;

//	Fast method, returns the number of moving stones (min 0 max 2) present
//	on the specified grid position.
-(NSInteger)countMovingStonesAtX:(NSInteger)x andY:(NSInteger)y;

//	Fast method, checks whether there is a fixed stone at the given position,
//	returns 0 if it is not, !0 otherwise.
-(BOOL)isFixedStoneAtX:(NSInteger)x andY:(NSInteger)y;

//	Fast method, checks whethere there is any kind of a stone at the given position,
//	returns 0 if it is not, !0 otherwise.
-(BOOL)isFreePositionAtX:(NSInteger)x andY:(NSInteger)y;

//	Fast method, checks whether all the required positions are occupied by stones,
//	returns 0 if it is not, !0 otherwise.
-(BOOL)areRequiredPositionsFilled;

//	Returns a single TFStoneOnGrid (fixed or moving) that covers more then 50% of the given
//	square; nil if such a stone does not exist.
-(TFStoneOnGrid*)stoneCoveringX:(NSInteger)x andY:(NSInteger)y;

//	Returns an NSArray of TFStoneOnGrid objects containing one (possibly fixed) or
//	max two (both moving) stones that are present on the given square; empty
//	array if there are none.
-(NSArray*)stonesPresentAtX:(NSInteger)x andY:(NSInteger)y;


#pragma mark - Grid manipulation methods

//	Sets or resets the required status of grid square at (x,y)
-(void)setRequired:(BOOL)required squareAtX:(NSInteger)x andY:(NSInteger)y;

//	Checks if the grid can place the given |stone| on the given position.
//	This method checks everything: that the given stone fits within
//	grid boundaries, that there are no stones occupying the desired grid
//	squares, and that there are no fixed stones there either.
-(BOOL)canPlaceStone:(TFStone*)stone atX:(NSInteger)x andY:(NSInteger)y;

//	Adds a stone (fixed or not) at the given position in the grid (does not check
//	if the squares the stone will occupy are free, call canPlaceStone... before).
-(void)addStone:(TFStone*)stone fixed:(BOOL)fixed atX:(NSInteger)x andY:(NSInteger)y;

//	Removes |stone| from the grid, if it was present, and returns YES;
//	if the stone was not present returns NO.
-(BOOL)removeStone:(TFStoneOnGrid*)stone;

//	Checks if it is possible to move |stone| to a new location
//	on the grid specified by arguments; takes into account the |fixed|
//	property of the |stone|.
-(BOOL)canMoveStone:(TFStoneOnGrid*)stone 
			 toPosX:(NSInteger)posX 
			andPosY:(NSInteger)posY 
		   withOffX:(NSInteger)offX 
			andOffY:(NSInteger)offY;

//	Moves |stone| from it's current position on the grid to the new
//	position specified by arguments; does not check if the new position
//	is free for this stone, call canMoveStone... first.
-(void)moveStone:(TFStoneOnGrid*)stone 
			 toPosX:(NSInteger)posX 
			andPosY:(NSInteger)posY 
		   withOffX:(NSInteger)offX 
			andOffY:(NSInteger)offY;

@end

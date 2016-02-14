//
//  TFStoneOnGrid.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>



//	The maximum offset a stone can have
//	in the positive or negative direction. Has to be
//	an odd number so that a stone can not occupy *exactly*
//	50% of a square.
static const NSInteger TF_PACKER_STONE_OFFSET_MAX = 9;

//	Treshold value of the offset, so that integer-dividing
//	a specific offset by OFFSET_TRESH will yield +1
//	if the stone is offset by more then 50% in the positive
//	direction, -1 if it is offset by more then 50% in the negative
//	direcion, and 0 otherwise.
static const NSInteger TF_PACKER_STONE_OFFSET_TRESH = 5;

//	A data structure that makes some calculations a lot cleaner.
struct _TFSquare {
	NSInteger x, y, w, h;
};
typedef struct _TFSquare TFSquare;

BOOL TFSquaresIntersect(TFSquare s1, TFSquare s2);



@class TFStone;

//	A TFStone that has been placed on a grid with specific grid position, and offset.
@interface TFStoneOnGrid : NSObject <NSCopying, NSCoding>

//	The stone which has been placed on a grid.
@property(readwrite, retain) TFStone* stone;

//	Is the stone fixed on the grid, or movable.
@property(readwrite, assign) BOOL fixed;

//	The stone's (X,Y) position on the grid.
@property(readwrite, assign) NSInteger posX, posY;

//	The offset of stone from perfect alignment on the grid, in OFFSET_MAX-ths
@property(readwrite, assign) NSInteger offX, offY;

//	Initializes the TFStoneOnGrid with the given stone (fixed or not) and coordinates.
//	Offsets are 0.
-(id)initWithStone:(TFStone*)stone fixed:(BOOL)fixed onX:(NSInteger)x andY:(NSInteger)y;

//	Checks if the stone covers more then 50% of the given position.
-(BOOL)coversX:(NSInteger)x andY:(NSInteger)y;

//	Checks if the stone covers at least 1% of the given position.
-(BOOL)presentOnX:(NSInteger)x andY:(NSInteger)y;

//	Checks if the stone intesects a square defined by (posX, posY) with offX and offY offsets.
-(BOOL)intersectsX:(NSInteger)posX andY:(NSInteger)posY withOffX:(NSInteger)offX andOffY:(NSInteger)offY;

//	Checks if the stone covers a point defined by (posX, posY), with (offX, offY) offsets.
-(BOOL)coversX:(NSInteger)posX andY:(NSInteger)posY withOffX:(NSInteger)offX offY:(NSInteger)offY;

@end

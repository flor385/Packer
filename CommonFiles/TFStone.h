//
//  TFStone.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>


//	Represents a stone in the game with the size of one or more squares.
//	The first square is implicit, other squares are tracked with an array
//	of squares positioned relative to the first.
@interface TFStone : NSObject <NSCopying, NSCoding>

//	Additional squares this stone consists of, besides
//	the initial one, positioned relative to the initial one;
//	each square is defined by a TFPosition.
@property(readonly) NSArray *squares;

//	The total height of the stone (for example 1 for a single-square stone).
@property(readonly) NSInteger height;

//	The total width of the stone (for example 1 for a single-square stone).
@property(readonly) NSInteger width;

//	"Boundaries" of the stone, they give info how much
//	the stone extends in each direction (cartasium coords)
//	relative to the initial stone (considered to be at 0,0)
@property(readonly) NSInteger maxX, maxY, minX, minY;

//	Checks if the stone has a square at the given x and y
-(BOOL)hasSquareAtX:(NSInteger)x andY:(NSInteger)y;

//	Creates a new (autoreleased) TFStone that has one square more then the
//	receiver of this message, that square's relative position defined by |x| and |y| parameters.
//	If the given square already exists in this stone, it returns nil;
-(TFStone*)stoneWithAddedSquareAtX:(NSInteger)x andY:(NSInteger)y;

//	Creates a new (autoreleased) TFStone that has one square less then the
//	receiver of this message, that square's relative position defined by |x| and |y| parameters.
//	If the given stone does not exist, it returns nil;
-(TFStone*)stoneWithRemovedSquareFromX:(NSInteger)x andY:(NSInteger)y;

@end
//
//  TFStoneGenerator.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 12.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFStone;
@class TFGrid;

//	Randomly selects one from a set of stones provided through the
//	|setProbability: forStone:| method and attempts to place it
//	on the grid with the |attemptGenerationOnGrid: withGravityDirection:|
@interface TFStoneGenerator : NSObject <NSCopying, NSCoding>

//	Enables this stone generator to randomly place |stone| on the grid,
//	with the given probability that |stone| will be selected from all
//	the stones provided with this method. Probability can be any kind
//	of a number that will be relatively compared to other probabilities.
-(void)setProbability:(NSNumber*)probability forStone:(TFStone*)stone;

//	Returns all the stones this generator handles.
-(NSArray*)stones;

//	Gets the probability for |stone|, as defined in |setProbability:forStone:|
//	or nil if there is no probability for |stone|.
-(NSNumber*)probabilityForStone:(TFStone*)stone;

//	Randomly selects and returns one of the stones given
//	to the stone generator through the |setProbability: forStone:| method.
//	Should not be called if no stones we provided.
-(TFStone*)randomStone;

//	Randomly selects a stone using the |randomStone| method and attempts
//	to place it on the grid on a random location, but so that it is directly
//	below grid top (which is defined by |gravDirection|. If the randomly
//	selected stone can not be placed anywhere on top of the grid, this
//	method will exit without adding a stone to the grid.
-(void)attemptGenerationOnGrid:(TFGrid*)grid withGravityDirection:(NSInteger)gravDirection;

@end

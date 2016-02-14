//
//  TFGame.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 13.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFGrid, TFStoneGenerator, TFGravity;

//	Model object for a single game, encapsulates the game's
//	grid, gravity and random stone generation.
@interface TFGame : NSObject <NSCoding, NSCopying>

@property(readonly, retain) TFGrid *grid;
@property(readonly, retain) TFGravity *gravity;
@property(readonly, retain) TFStoneGenerator *stoneGenerator;
@property(readonly, copy) NSArray* stones;


-(id)initWithGrid:(TFGrid*)grid 
		  gravity:(TFGravity*)gravity 
		generator:(TFStoneGenerator*)generator
		andStones:(NSArray*)stones;

@end

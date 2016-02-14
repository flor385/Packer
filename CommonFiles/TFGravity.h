//
//  TFGravity.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 10.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

//	the number of frames it takes for a stone
//	to fall exactly one square under the influence
//	of gravity
static const NSInteger TF_PACKER_GRAV_ANIMATION_STEPS = 3;

//	the direction gravity can act relative to the
//	grid's cartasian implementation
//	default value is down
static const NSInteger TF_PACKER_GRAV_NONE = 0;
static const NSInteger TF_PACKER_GRAV_DIRECTION_DOWN = 1;
static const NSInteger TF_PACKER_GRAV_DIRECTION_UP = 2;
static const NSInteger TF_PACKER_GRAV_DIRECTION_LEFT = 3;
static const NSInteger TF_PACKER_GRAV_DIRECTION_RIGHT = 4;

@class TFGrid;

//	Gravity simulation that changes the position of movable stones
//	on a grid in the direction of the gravity.
//
//	Implemented to work as a sequence of steps, during which stones
//	will "fall" for exactly one square. The evaluation of the grid
//	in terms of which stones can "fall" is performed only at the
//	beginning of the sequence.
//
//	TFGravity makes a few assumptions about the state of the grid
//	when performing a "fall" sequence. It assumes that at the beginning
//	of the sequence  there are no stones with offset on the axis of
//	falling, though they may have an offset on the "horizontal" axis.
//	Next, it assumes that the direction of gravity will not be changed
//	in the middle of the sequence, but only right before the first step
//	of the next sequence.
@interface TFGravity : NSObject <NSCoding, NSCopying>

//	The direction of "falling", acceptable values are |TF_PACKER_GRAV_DIRECTION_...|
//	flags.
@property(assign, nonatomic) NSInteger direction;

//	Takes an array of NSNumbers that are the allowed direction
//	|gravity| can then accept (through the |direction| property.
-(void)setAllowedDirections:(NSArray*)directions;

//	Indicates if this gravity allows |direction|.
-(BOOL)allowsDirection:(NSInteger)direction;

//	ensures that gravity does not attempt to move |stones|,
//	regardles of them being blocked or not
-(void)setImmovableStones:(NSArray*)stones;

//	Performs one step in the sequence of "falling". The whole sequence
//	lowers all stones that can be lowered for exactly one square. The
//	number of steps in a sequence is defined by the |GRAV_ANIMATION_STEPS|
//	constant.
-(void)performStepOnGrid:(TFGrid*)grid;

@end

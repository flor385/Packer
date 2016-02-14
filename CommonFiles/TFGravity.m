//
//  TFGravity.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 10.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import	"TFStone.h"
#import "TFStoneOnGrid.h"
#import "TFPosition.h"
#import "TFGravity.h"
#import "TFGrid.h"

//	Private methods used by TFGravity
@interface TFGravity ()
{
	NSMutableArray* stonesInMotion;
	NSMutableArray* allowedDirections;
	NSMutableArray* immovableStones;
	NSInteger step;
	NSInteger direction;
}

//	Fills up the |stonesInMotion| array with stones
//	that can and should be moved by gravity, for the
//	given state of |grid|. Should be used at the
//	beginning of a sequence only.
-(void)populateStonesInMotionForGrid:(TFGrid*)grid;

@end

@implementation TFGravity

@synthesize direction = _nextDirection;

-(id)init
{
	if(self = [super init]){
		
		stonesInMotion = [NSMutableArray new];
		allowedDirections = [NSMutableArray new];
		immovableStones = [NSMutableArray new];
		step = 0;
		_nextDirection = TF_PACKER_GRAV_DIRECTION_DOWN;
		direction = _nextDirection;
		return self;
	}
	
	return nil;
}

//	Overriden setter to raise hell if someone tries
//	to set direction at any point during the fall
//	sequence that is not the beginning.
-(void)setDirection:(NSInteger)dir
{
	if(![allowedDirections containsObject:[NSNumber numberWithInteger:dir]])
		return;
	
	_nextDirection = dir;
}

-(void)setAllowedDirections:(NSArray*)directions
{
	[allowedDirections removeAllObjects];
	[allowedDirections addObjectsFromArray:directions];
}

-(BOOL)allowsDirection:(NSInteger)aDirection
{
	return [allowedDirections containsObject:[NSNumber numberWithInteger:aDirection]];
}

-(void)setImmovableStones:(NSArray*)stones
{
	[immovableStones removeAllObjects];
	[immovableStones addObjectsFromArray:stones];
}

//	Checks if |stone| is present in |array|, if it is NOT then it is added,
//	and this same method is called for all the stones that are directly
//	blocked from moving by this gravity (with it's direction) on |grid|.
-(void)_recursiveAddTo:(NSMutableArray*)array startingWith:(TFStoneOnGrid*)stone onGrid:(TFGrid*)grid
{
	
	//	if the given stone is already present in the array,
	//	then it was already processed by this method, so
	//	we should skip him, not to repeat the whole tree of stones it blocks
	if([array containsObject:stone])
		return;
	
	[array addObject:stone];
	
	// now we need to figure out which other stones this stone is blocking
	//	iterate through all the squares of the stone
	//	first we need some things we will use in every iteration
	NSMutableSet* stonesToConsider = [[NSMutableSet new] autorelease];
	NSInteger aboveX = direction == TF_PACKER_GRAV_DIRECTION_LEFT ? 1 : direction == TF_PACKER_GRAV_DIRECTION_RIGHT ? -1 : 0;
	NSInteger aboveY = direction == TF_PACKER_GRAV_DIRECTION_DOWN ? 1 : direction == TF_PACKER_GRAV_DIRECTION_UP ? -1 : 0;
	NSInteger gridOffX = stone.offX > 0 ? 1 : (stone.offX < 0 ? -1 : 0);
	NSInteger gridOffY = stone.offY > 0 ? 1 : (stone.offY < 0 ? -1 : 0);
	
	NSArray *squares = stone.stone.squares;
	for(int i = -1 ; i < (NSInteger)[squares count] ; i++){
		
		//	the coordinates of a square directly above (relative to the grav direction)
		//	the current square of the stone
		NSInteger squareX = stone.posX + aboveX;
		NSInteger squareY = stone.posY + aboveY;
		squareX += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).x;
		squareY += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).y; 
		
		//	since a stone an be immovable because the user holds it,
		//	we have to take offsets into account
		[stonesToConsider removeAllObjects];
		[stonesToConsider addObjectsFromArray:[grid stonesPresentAtX:squareX andY:squareY]];
		//	if there is offset, we need to consider that too
		[stonesToConsider addObjectsFromArray:[grid stonesPresentAtX:squareX + gridOffX andY:squareY + gridOffY]];
		 
		//	we still have to check are the stonesToConsider are actually blocked...
		//	if so, recursively add to the array
		for(TFStoneOnGrid* stoneToConsider in stonesToConsider)
			if([stoneToConsider intersectsX:squareX andY:squareY withOffX:stone.offX andOffY:stone.offY])
				[self _recursiveAddTo:array startingWith:stoneToConsider onGrid:grid];
	}
}

-(void)populateStonesInMotionForGrid:(TFGrid *)grid
{
	direction = _nextDirection;
	if(direction == TF_PACKER_GRAV_NONE){
		[stonesInMotion removeAllObjects];
		return;
	}
	
	NSMutableArray* stonesThatCantMove = [[NSMutableArray new] autorelease];
	
	//	first add the custom set immovable stones
	for(TFStoneOnGrid* stone in immovableStones)
		[self _recursiveAddTo:stonesThatCantMove startingWith:stone onGrid:grid];
	
	//	first add all the stones on the "bottom" of the grid to the stones's that can't move array
	if(direction == TF_PACKER_GRAV_DIRECTION_DOWN || direction == TF_PACKER_GRAV_DIRECTION_UP){
		
		NSInteger y = direction == TF_PACKER_GRAV_DIRECTION_DOWN ? 0 : grid.height - 1;
		
		for(int x = 0 ; x < grid.width ; x++){
			TFStoneOnGrid *stone = [grid stoneCoveringX:x andY:y];
			if(stone != nil)
				[self _recursiveAddTo:stonesThatCantMove startingWith:stone onGrid:grid];
		}
	}else{
		
		NSInteger x = direction == TF_PACKER_GRAV_DIRECTION_LEFT ? 0 : grid.width - 1;
		
		for(int y = 0 ; y < grid.height ; y++){
			TFStoneOnGrid *stone = [grid stoneCoveringX:x andY:y];
			if(stone != nil)
				[self _recursiveAddTo:stonesThatCantMove startingWith:stone onGrid:grid];
		}
	}
	
	//	then add all the fixed stones to the same grid
	for(TFStoneOnGrid* fixedStone in grid.fixedStones)
		[self _recursiveAddTo:stonesThatCantMove startingWith:fixedStone onGrid:grid];
	
	//	now, the stones that CAN move are all the other stones
	[stonesInMotion removeAllObjects];
	for(TFStoneOnGrid* stone in grid.stones)
		if(![stonesThatCantMove containsObject:stone])
			[stonesInMotion addObject:stone];
}

-(void)performStepOnGrid:(TFGrid*)grid
{
	if(step == 0)
		[self populateStonesInMotionForGrid:grid];
	
	if(direction == TF_PACKER_GRAV_NONE)
		return;
	
	//	increase step
	step +=1;
	if(step == TF_PACKER_GRAV_ANIMATION_STEPS)
		step = 0;
	
	
	//	calculate how much we have to move the stones (offset and grav) in absolute values
	NSInteger gravPos, gravOff;
	if(step == 0){
		//	if here then we have reached the last step of a sequence
		//	so we finish the sequence by reducing offset and increasing position
		gravPos = 1;
		gravOff = - TF_PACKER_STONE_OFFSET_MAX / TF_PACKER_GRAV_ANIMATION_STEPS * (TF_PACKER_GRAV_ANIMATION_STEPS - 1);
	}else{
		//	if here we are not at the end of the sequence,
		//	so we just increase offset
		gravOff = TF_PACKER_STONE_OFFSET_MAX / TF_PACKER_GRAV_ANIMATION_STEPS;
		gravPos = 0;
	}
	
	//	now determine in which direction we need to move the stones
	NSInteger movePosX, movePosY, moveOffX, moveOffY;
	if(direction == TF_PACKER_GRAV_DIRECTION_DOWN){
		movePosX = 0;
		moveOffX = 0;
		movePosY = -gravPos;
		moveOffY = -gravOff;
	}else if(direction == TF_PACKER_GRAV_DIRECTION_UP){
		movePosX = 0;
		moveOffX = 0;
		movePosY = gravPos;
		moveOffY = gravOff;
	}else if(direction == TF_PACKER_GRAV_DIRECTION_LEFT){
		movePosX = -gravPos;
		moveOffX = -gravOff;
		movePosY = 0;
		moveOffY = 0;
	}else{
		movePosX = gravPos;
		moveOffX = gravOff;
		movePosY = 0;
		moveOffY = 0;
	}
	
	//	now move all the stones that deserve it!
	for(TFStoneOnGrid* gridStone in stonesInMotion)
		[grid moveStone:gridStone 
				 toPosX:gridStone.posX + movePosX 
				andPosY:gridStone.posY + movePosY 
			   withOffX:gridStone.offX + moveOffX 
				andOffY:gridStone.offY + moveOffY];
	
	//	done here!
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if([encoder allowsKeyedCoding]){
		
		[encoder encodeInteger:direction forKey:@"direction"];
		[encoder encodeInteger:step forKey:@"step"];
		[encoder encodeObject:stonesInMotion forKey:@"stonesInMotion"];
		[encoder encodeObject:allowedDirections forKey:@"allowedDirections"];
		
	}else{
		NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
		@throw exception;
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if(self = [super init]){
		if([decoder allowsKeyedCoding]){
			
			direction = [decoder decodeIntegerForKey:@"direction"];
			step = [decoder decodeIntegerForKey:@"step"];
			stonesInMotion = [[decoder decodeObjectForKey:@"stonesInMotion"] retain];
			allowedDirections = [[decoder decodeObjectForKey:@"allowedDirections"] retain];
			immovableStones = [NSMutableArray new];
			
		}else{
			NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
			@throw exception;
		}
		
		return self;
	}
	
	return nil;
}

#pragma mark - NSCopying

-(void)_copyStonesInMotion:(NSMutableArray*)sim
{
	if(stonesInMotion == sim) return;
	[stonesInMotion release];
	stonesInMotion = [[NSMutableArray alloc] initWithArray:sim copyItems:YES];
}

-(void)_copyAllowedDirections:(NSMutableArray*)directions
{
	if(directions == allowedDirections) return;
	[allowedDirections release];
	allowedDirections = [[NSMutableArray alloc] initWithArray:directions copyItems:YES];
}

-(void)_setStep:(NSInteger)aStep
{
	step = aStep;
}

-(id)copyWithZone:(NSZone *)zone
{
	TFGravity* copied = [[TFGravity alloc] init];
	copied.direction = direction;
	[copied _copyStonesInMotion:stonesInMotion];
	[copied _copyAllowedDirections:allowedDirections];
	[copied _setStep:step];
	
	return copied;
}

#pragma mark -


-(void)dealloc
{
	[stonesInMotion release];
	[allowedDirections release];
	[immovableStones release];
	[super dealloc];
}

@end

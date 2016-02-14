//
//  TFGrid.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGrid.h"
#import "TFStone.h"
#import "TFStoneOnGrid.h"
#import "TFPosition.h"



#pragma mark - Private interface to TFGrid

//	private interface of the TFGrid class
//	using the class extension mechanism (is this a good way?!?)
@interface TFGrid ()
{
	NSMutableArray *_stones;
	NSMutableArray *_fixedStones;
	
	//	a two-dimensional array containing bitwise flags for each grid position
	//	bitwise masks are REQUIRED_POS_MASK, OCCUPYING_STONE_MASK, FIXED_MASK
	int32_t* _gridPositions;

}

//	helper methods
-(void)_setMask:(int32_t)mask forPositionAtX:(NSInteger)x andY:(NSInteger)y;

@end


#pragma mark - TFGrid implementation

//	Implementation of the TFGrid class
@implementation TFGrid


#pragma mark - Properties

@synthesize width = _width, height = _height;

//	Vraca se kopija varijable jer je ona mutable
-(NSArray*)stones{
	return [[_stones copy] autorelease];
}

//	Vraca se kopija varijable jer je ona mutable
-(NSArray*)fixedStones{
	return [[_fixedStones copy] autorelease];
}


#pragma mark - Initialization

-(id)initWithWidth:(NSInteger)w height:(NSInteger)h
{
	return [self initWithWidth:w height:h requiredPositions:nil];
}

-(id)initWithWidth:(NSInteger)w height:(NSInteger)h requiredPositions:(NSArray*)requiredPositions
{
	if(self = [super init]){
		
		_stones = [NSMutableArray new];
		_fixedStones = [NSMutableArray new];
		_width = w;
		_height = h;
		_gridPositions = (int32_t*)malloc(w * h * sizeof(int32_t));
		for(int i = 0 ; i < w ; i++)
			for(int j = 0 ; j < h ; j++)
				_gridPositions[_width * j + i] = 0;
		
		//	now add the required positions
		for(TFPosition* pos in requiredPositions)
			if(pos.x >= 0 && pos.x < _width && pos.y >= 0 && pos.y < _height)
				[self _setMask:REQUIRED_POS_MASK forPositionAtX:pos.x andY:pos.y];
		
		return self;
		
	}
	
	return nil;
}


#pragma mark - Grid information methods

//	Bitwise masks used for getting and setting info on grid positions.
static int32_t REQUIRED_POS_MASK = 1;
static int32_t ONE_MOVING_STONE_MASK = 2;
static int32_t TWO_MOVING_STONES_MASK = 4;
static int32_t FIXED_MASK = 8;

-(BOOL)_hasMask:(int32_t)mask atX:(NSInteger)x andY:(NSInteger)y
{
	return _gridPositions[_width * y + x] & mask;
}

-(void)_setMask:(int32_t)mask forPositionAtX:(NSInteger)x andY:(NSInteger)y
{
	_gridPositions[_width * y + x] |= mask;
}

-(void)_resetMask:(int32_t)mask forPositionAtX:(NSInteger)x andY:(NSInteger)y
{
	_gridPositions[_width * y + x] &= ~mask;
}

-(BOOL)isRequiredPositionAtX:(NSInteger)x andY:(NSInteger)y
{
	return [self _hasMask:REQUIRED_POS_MASK atX:x andY:y];
}

-(NSArray*)requiredPositions
{
	NSMutableArray *rVal = [[NSMutableArray new] autorelease];
	for(int i = 0 ; i < _width ; i++)
		for(int j = 0 ; j < _height ; j++)
			if([self isRequiredPositionAtX:i andY:j])
			   [rVal addObject:[TFPosition positionWithX:i andY:j]];
	
	return rVal;
}

-(NSInteger)countMovingStonesAtX:(NSInteger)x andY:(NSInteger)y
{
	if([self _hasMask:TWO_MOVING_STONES_MASK atX:x andY:y])
		return 2;
	if([self _hasMask:ONE_MOVING_STONE_MASK atX:x andY:y])
		return 1;
	
	return 0;
}

-(BOOL)isFixedStoneAtX:(NSInteger)x andY:(NSInteger)y
{
	return [self _hasMask:FIXED_MASK atX:x andY:y];
}

-(BOOL)isFreePositionAtX:(NSInteger)x andY:(NSInteger)y
{
	return	[self countMovingStonesAtX:x andY:y] == 0 && ![self isFixedStoneAtX:x andY:y];
}

-(BOOL)areRequiredPositionsFilled
{
	for(int i = 0 ; i < _width ; i++)
		for(int j = 0 ; j < _height ; j++){
			if([self isRequiredPositionAtX:i andY:j] && [self countMovingStonesAtX:i andY:j] != 1 )
				return NO;
		}
	
	return YES;
}

-(TFStoneOnGrid*)stoneCoveringX:(NSInteger)x andY:(NSInteger)y
{
	//	first check the super-fast mask-based methods
	//	and only if it confirms something's there, look for the actual stone
	
	//	fixed stones
	if([self isFixedStoneAtX:x andY:y])
		for(TFStoneOnGrid *stone in _fixedStones)
			if([stone coversX:x andY:y])
				return stone;
	
	//	moving stones
	if([self countMovingStonesAtX:x andY:y] != 0)
		for(TFStoneOnGrid *stone in _stones)
			if([stone coversX:x andY:y])
				return stone;
	
	return nil;
}

-(NSArray*)stonesPresentAtX:(NSInteger)x andY:(NSInteger)y
{
	//	first check the super-fast mask-based methods
	//	and only if it confirms something's there, look for the actual stone
	
	//	fixed stones
	if([self isFixedStoneAtX:x andY:y])
		for(TFStoneOnGrid *stone in _fixedStones)
			if([stone presentOnX:x andY:y])
				return [NSArray arrayWithObject:stone];
	
	
	//	moving stones
	NSArray *rVal = [[NSArray new] autorelease];
	if([self countMovingStonesAtX:x andY:y] != 0)
		for(TFStoneOnGrid *stone in _stones)
			if([stone presentOnX:x andY:y])
				rVal = [rVal arrayByAddingObject:stone];
	
	
	return rVal;
}


#pragma mark - Grid manipulation methods

-(void)setRequired:(BOOL)required squareAtX:(NSInteger)x andY:(NSInteger)y
{
	if(required)
		[self _setMask:REQUIRED_POS_MASK forPositionAtX:x andY:y];
	else
		[self _resetMask:REQUIRED_POS_MASK forPositionAtX:x andY:y];
}

-(BOOL)canPlaceStoneOnSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	if(	x >= _width || 
	   x < 0 || 
	   y >= _height || 
	   y < 0 || 
	   ![self isFreePositionAtX:x andY:y])
		
		return NO;
	
	return YES;
}

-(BOOL)canPlaceStone:(TFStone*)stone atX:(NSInteger)x andY:(NSInteger)y
{
	//	first check the origin of the position itself
	if(![self canPlaceStoneOnSquareAtX:x andY:y])
		return NO;
	
	//	now check all the stone squares
	for(TFPosition *square in stone.squares)
		if(![self canPlaceStoneOnSquareAtX:x + square.x andY:y + square.y])
			return NO;
	
	//	if all the stone's squares would be at legit grid positions,
	//	we return YES!
	return YES;
}

-(void)addStone:(TFStone*)stone fixed:(BOOL)fixed atX:(NSInteger)x andY:(NSInteger)y
{
	//	since this method adds stones so that they occupy 100% of the
	//	square they are present on, the adding process is fairly simple
	
	TFStoneOnGrid *stoneOnGrid = [[TFStoneOnGrid alloc] initWithStone:stone fixed:fixed onX:x andY:y];
	
	if(fixed){
		[_fixedStones addObject:stoneOnGrid];
		[self _setMask:FIXED_MASK forPositionAtX:x andY:y];
		for(TFPosition *square in stone.squares)
			[self _setMask:FIXED_MASK forPositionAtX:x + square.x andY:y + square.y];
	}else{
		[_stones addObject:stoneOnGrid];
		[self _setMask:ONE_MOVING_STONE_MASK forPositionAtX:x andY:y];
		for(TFPosition *square in stone.squares)
			[self _setMask:ONE_MOVING_STONE_MASK forPositionAtX:x + square.x andY:y + square.y];
	}
		
	[stoneOnGrid release];

}

-(BOOL)removeStone:(TFStoneOnGrid*)stone
{
	//	check fixed stones;
	if([_fixedStones containsObject:stone]){
		
		NSSet* positionsToRemoveFrom = [self _presencePositionsFor:stone];
		for(TFPosition* position in positionsToRemoveFrom)
			[self _resetMask:FIXED_MASK forPositionAtX:position.x andY:position.y];
			
		
		[_fixedStones removeObject:stone];
		return YES;
	}
	
	//	check moving stones;
	if([_stones containsObject:stone]){
		
		NSSet* positionsToRemoveFrom = [self _presencePositionsFor:stone];
		for(TFPosition* position in positionsToRemoveFrom)
			[self _reduceMovingStoneCountAtX:position.x andY:position.y];
		
		[_stones removeObject:stone];
		return YES;
	}
	
	return NO;
	
}

-(BOOL)canMoveStone:(TFStoneOnGrid*)stone 
			 toPosX:(NSInteger)posX 
			andPosY:(NSInteger)posY 
		   withOffX:(NSInteger)offX 
			andOffY:(NSInteger)offY
{
	if(stone.fixed) return NO;
	
	//	see if the stone remains within bounds
	if(posX + stone.stone.maxX >= _width || posX + stone.stone.minX < 0)
		return NO;
	if((posX + stone.stone.maxX + 1 == _width && offX > 0) || (posX + stone.stone.minX == 0 && offX < 0))
		return NO;
	if(posY + stone.stone.maxY >= _height || posY + stone.stone.minY < 0)
		return NO;
	if((posY + stone.stone.maxY + 1 == _height && offY > 0) || (posY + stone.stone.minY == 0 && offY < 0))
		return NO;
	
	//	calculate if other stones are blocking the movement
	//	using brute force calc because fancy is complicated
	//	optimize if it turns out to be necessary
	NSArray *squares = stone.stone.squares;
	for(int i = -1 ; i < (NSInteger)[squares count] ; i++){
		
		NSInteger squareX = posX;
		NSInteger squareY = posY;
		squareX += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).x;
		squareY += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).y;
		
		for(TFStoneOnGrid *maybeBlockingStone in _fixedStones)
			if([maybeBlockingStone intersectsX:squareX andY:squareY withOffX:offX andOffY:offY])
				return NO;
		
		for(TFStoneOnGrid *maybeBlockingStone in _stones)
			if(maybeBlockingStone != stone && [maybeBlockingStone intersectsX:squareX andY:squareY withOffX:offX andOffY:offY])
				return NO;
	}
	
	return YES;
}


//	Private helper method
-(void)_reduceMovingStoneCountAtX:(NSInteger)x andY:(NSInteger)y
{
	if([self _hasMask:TWO_MOVING_STONES_MASK atX:x andY:y])
		[self _resetMask:TWO_MOVING_STONES_MASK forPositionAtX:x andY:y];
	else if([self _hasMask:ONE_MOVING_STONE_MASK atX:x andY:y])
		[self _resetMask:ONE_MOVING_STONE_MASK forPositionAtX:x andY:y];
}

-(void)_increaseMovingStoneCountAtX:(NSInteger)x andY:(NSInteger)y
{
	if([self _hasMask:ONE_MOVING_STONE_MASK atX:x andY:y])
		[self _setMask:TWO_MOVING_STONES_MASK forPositionAtX:x andY:y];
	else
		[self _setMask:ONE_MOVING_STONE_MASK forPositionAtX:x andY:y];
}

//	Helper method that identifies the grid squares that
// the given |stone| covers, regardless of how much.
-(NSSet*)_presencePositionsFor:(TFStoneOnGrid*)stone
{
	//	here we will store a set of positions to be removed
	//	we need a set because due to offsets we might want to remove
	//	some positions more times
	NSMutableSet *positions = [[NSMutableSet new] autorelease];
	
	//	calculte the offset in terms of {-1, 0, 1}
	NSInteger gridOffX = stone.offX > 0 ? 1 : (stone.offX < 0 ? -1 : 0);
	NSInteger gridOffY = stone.offY > 0 ? 1 : (stone.offY < 0 ? -1 : 0);
	
	//	add to the set of positions to remove the position of each square,
	//	and also the positions of squares the offset causes the stone to overlap
	NSArray* squares = stone.stone.squares;
	for(int i = -1 ; i < (NSInteger)[squares count] ; i++){
		
		NSInteger x = stone.posX;
		NSInteger y = stone.posY;
		
		x += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).x;
		y += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).y;
		
		[positions addObject:[TFPosition positionWithX:x andY:y]];
		[positions addObject:[TFPosition positionWithX:x + gridOffX andY:y]];
		[positions addObject:[TFPosition positionWithX:x andY:y + gridOffY]];
		[positions addObject:[TFPosition positionWithX:x + gridOffX andY:y + gridOffY]];
	}
	
	return positions;
}

-(void)moveStone:(TFStoneOnGrid*)stone 
		  toPosX:(NSInteger)posX 
		 andPosY:(NSInteger)posY 
		withOffX:(NSInteger)offX 
		 andOffY:(NSInteger)offY
{
	//	first remove the stone from the bit array positions
	NSSet* positionsToRemoveFrom = [self _presencePositionsFor:stone];
	for(TFPosition* position in positionsToRemoveFrom)
		[self _reduceMovingStoneCountAtX:position.x andY:position.y];
	
	//	now change it's parameters
	stone.posX = posX;
	stone.posY = posY;
	stone.offX = offX;
	stone.offY = offY;
	
	//	and finaly add the stone to the bit array at the new positions
	NSSet* positionsToAddTo = [self _presencePositionsFor:stone];
	for(TFPosition* position in positionsToAddTo)
		[self _increaseMovingStoneCountAtX:position.x andY:position.y];
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if([encoder allowsKeyedCoding]){
		[encoder encodeObject:_stones forKey:@"stones"];
		[encoder encodeObject:_fixedStones forKey:@"fixedStones"];
		[encoder encodeInteger:_width forKey:@"width"];
		[encoder encodeInteger:_height forKey:@"height"];
		
		[encoder encodeObject:[NSData dataWithBytes:_gridPositions length:(_width * _height * sizeof(int32_t))] forKey:@"gridPositions"];
		
	}else{
		NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
		@throw exception;
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if(self = [super init]){
		if([decoder allowsKeyedCoding]){
			
			_stones = [[decoder decodeObjectForKey:@"stones"] retain];
			_fixedStones = [[decoder decodeObjectForKey:@"fixedStones"] retain];
			_width = [decoder decodeIntegerForKey:@"width"];
			_height= [decoder decodeIntegerForKey:@"height"];
			
			_gridPositions = (int32_t*)malloc(_width * _height * sizeof(int32_t));
			NSData *gpData = [decoder decodeObjectForKey:@"gridPositions"];
			[gpData getBytes:_gridPositions length:(_width * _height * sizeof(int32_t))];
			
		}else{
			NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
			@throw exception;
		}
		
		return self;
	}
	
	return nil;
}


#pragma mark - NSCopying

-(void)_copyStones:(NSMutableArray*)stones
{
	if(_stones == stones) return;
	
	[_stones release];
	_stones = [[NSMutableArray alloc] initWithArray:stones copyItems:YES];
}

-(void)_copyFixedStones:(NSMutableArray*)fixedStones
{
	if(_fixedStones == fixedStones) return;
	
	[_fixedStones release];
	_fixedStones = [[NSMutableArray alloc] initWithArray:fixedStones copyItems:YES];
}
-(void)_copyGridPositionsFrom:(int32_t*)gridPositions
{
	if(_gridPositions == gridPositions) return;
	memcpy(_gridPositions, gridPositions, _width * _height * sizeof(int32_t));
}

-(id)copyWithZone:(NSZone *)zone
{
	TFGrid *copied = [[TFGrid alloc] initWithWidth:self.width height:self.height];
	[copied _copyStones:_stones];
	[copied _copyFixedStones:_fixedStones];
	[copied _copyGridPositionsFrom:_gridPositions];
	
	return copied;
}


#pragma mark -

-(void)dealloc
{
	[_fixedStones release];
	[_stones release];
	free(_gridPositions);
	
	[super dealloc];
}

@end

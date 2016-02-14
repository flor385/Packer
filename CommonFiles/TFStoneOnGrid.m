//
//  TFStoneOnGrid.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFStoneOnGrid.h"
#import "TFStone.h"
#import "TFPosition.h"

#pragma mark - Helper functions

BOOL TFSquaresIntersect(TFSquare s1, TFSquare s2){
	
	BOOL xIntersect = NO;
	if(s1.x < s2.x)
		xIntersect = s2.x < s1.x + s1.w;
	else
		xIntersect = s1.x < s2.x + s2.w;
	
	BOOL yIntersect = NO;
	if(s1.y < s2.y)
		yIntersect = s2.y < s1.y + s1.h;
	else
		yIntersect = s1.y < s2.y + s2.h;
	
	return xIntersect && yIntersect;
}

#pragma mark - TFStoneOnGrid implementation

@interface TFStoneOnGrid ()
{
	NSUInteger stoneID;
}

@end

@implementation TFStoneOnGrid

@synthesize stone = _stone, fixed = _fixed;
@synthesize posX = _posX, posY = _posY, offX = _offX, offY = _offY;

//	counter of stones used to give each stone a unique ID
//	that is used to evaluate equality
static NSUInteger stoneCounter = 0;

-(id)initWithStone:(TFStone*)stone fixed:(BOOL)fixed onX:(NSInteger)x andY:(NSInteger)y
{
	if(self = [super init]){
		
		_stone = [stone retain];
		_posX = x;
		_posY = y;
		_offY = 0;
		_offX = 0;
		_fixed = fixed;
		
		stoneID = stoneCounter++;
		
		return self;
	}
	
	return nil;
}



#pragma mark - Other methods

//	evaulates if the stone covers the given position without
//	taking offsets into account
-(BOOL)_noOffsetPresentAtX:(NSInteger)x andY:(NSInteger)y
{
	if(x == _posX && y == _posY)
		return YES;
	
	for(TFPosition* square in self.stone.squares)
		if(x == _posX + square.x && y == _posY + square.y)
			return YES;
	
	return NO;
}

//	Checks if the stone covers more then 50% of the given position.
-(BOOL)coversX:(NSInteger)x andY:(NSInteger)y
{
	x -= _offX / TF_PACKER_STONE_OFFSET_TRESH;
	y -= _offY / TF_PACKER_STONE_OFFSET_TRESH;
	
	return [self _noOffsetPresentAtX:x andY:y];
}

//	Checks if the stone covers at least 1% of the given position.
-(BOOL)presentOnX:(NSInteger)x andY:(NSInteger)y
{
	NSInteger gridOffX = _offX > 0 ? 1 : (_offX < 0 ? -1 : 0);
	NSInteger gridOffY = _offY > 0 ? 1 : (_offY < 0 ? -1 : 0);
	
	//	figure it out :P
	return	[self _noOffsetPresentAtX:x andY:y] ||
			(_offX && [self _noOffsetPresentAtX:x - gridOffX andY:y]) ||
			(_offY && [self _noOffsetPresentAtX:x andY:y - gridOffY]) ||
			(_offX && _offY &&[self _noOffsetPresentAtX:x - gridOffX andY:y - gridOffY]);
}

-(BOOL)intersectsX:(NSInteger)posX andY:(NSInteger)posY withOffX:(NSInteger)offX andOffY:(NSInteger)offY
{
	TFSquare s;
	s.x = posX * TF_PACKER_STONE_OFFSET_MAX + offX;
	s.y = posY * TF_PACKER_STONE_OFFSET_MAX + offY;
	s.w = TF_PACKER_STONE_OFFSET_MAX;
	s.h = TF_PACKER_STONE_OFFSET_MAX;
	
	TFSquare s2;
	s2.x = self.posX*TF_PACKER_STONE_OFFSET_MAX + self.offX;
	s2.y = self.posY*TF_PACKER_STONE_OFFSET_MAX + self.offY;
	s2.w = TF_PACKER_STONE_OFFSET_MAX;
	s2.h = TF_PACKER_STONE_OFFSET_MAX;
	
	if(TFSquaresIntersect(s, s2))
		return YES;
	
	for(TFPosition *square in self.stone.squares){
		
		s2.x = (self.posX + square.x)*TF_PACKER_STONE_OFFSET_MAX + self.offX;
		s2.y = (self.posY + square.y)*TF_PACKER_STONE_OFFSET_MAX + self.offY;
		
		if(TFSquaresIntersect(s, s2))
		   return YES;
	}
	
	return NO;
}

-(BOOL)coversX:(NSInteger)posX andY:(NSInteger)posY withOffX:(NSInteger)offX offY:(NSInteger)offY
{
	TFSquare s;
	s.x = posX * TF_PACKER_STONE_OFFSET_MAX + offX;
	s.y = posY * TF_PACKER_STONE_OFFSET_MAX + offY;
	s.w = 1;
	s.h = 1;
	
	TFSquare s2;
	s2.x = self.posX*TF_PACKER_STONE_OFFSET_MAX + self.offX;
	s2.y = self.posY*TF_PACKER_STONE_OFFSET_MAX + self.offY;
	s2.w = TF_PACKER_STONE_OFFSET_MAX;
	s2.h = TF_PACKER_STONE_OFFSET_MAX;
	
	if(TFSquaresIntersect(s, s2))
		return YES;
	
	for(TFPosition *square in self.stone.squares){
		
		s2.x = (self.posX + square.x)*TF_PACKER_STONE_OFFSET_MAX + self.offX;
		s2.y = (self.posY + square.y)*TF_PACKER_STONE_OFFSET_MAX + self.offY;
		
		if(TFSquaresIntersect(s, s2))
			return YES;
	}
	
	return NO;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if([encoder allowsKeyedCoding]){
		[encoder encodeObject:_stone forKey:@"stone"];
		[encoder encodeBool:_fixed forKey:@"fixed"];
		[encoder encodeInteger:_posX forKey:@"posX"];
		[encoder encodeInteger:_posY forKey:@"posY"];
		[encoder encodeInteger:_offX forKey:@"offX"];
		[encoder encodeInteger:_offY forKey:@"offY"];
		
	}else{
		NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
		@throw exception;
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if(self = [super init]){
		if([decoder allowsKeyedCoding]){
			
			_stone = [[decoder decodeObjectForKey:@"stone"] retain];
			_fixed = [decoder decodeBoolForKey:@"fixed"];
			_posX = [decoder decodeIntegerForKey:@"posX"];
			_posY = [decoder decodeIntegerForKey:@"posY"];
			_offX = [decoder decodeIntegerForKey:@"offX"];
			_offY = [decoder decodeIntegerForKey:@"offY"];
			
			stoneID = stoneCounter++;
			
		}else{
			NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
			@throw exception;
		}
		
		return self;
	}
	
	return nil;
}

#pragma mark - NSCopying

-(void)_setStoneID:(NSUInteger)anID
{
	stoneID = anID;
}

-(NSUInteger)_stoneID
{
	return stoneID;
}


-(id)copyWithZone:(NSZone *)zone
{
	TFStoneOnGrid *copied = [TFStoneOnGrid new];
	
	copied.stone = [[self.stone copy] autorelease];
	copied.fixed = self.fixed;
	copied.posX = self.posX;
	copied.posY = self.posY;
	copied.offX = self.offX;
	copied.offY = self.offY;
	
	[copied _setStoneID:stoneID];
	
	return copied;
}

-(NSUInteger)hash
{
	return stoneID;
}


-(BOOL)isEqual:(id)object
{
	if(![object isKindOfClass:[TFStoneOnGrid class]])
		 return NO;
	
	TFStoneOnGrid *stone = object;
	return stoneID == [stone _stoneID];
}

#pragma mark -

-(NSString*)description
{
	return [NSString stringWithFormat:@"StoneOnGrid, posX:%d, posY:%d, offX:%d, offY:%d", _posX, _posY, _offX, _offY];
}

-(void)dealloc
{
	[_stone release];
	[super dealloc];
}


@end

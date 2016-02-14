//
//  TFStone.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFStone.h"
#import "TFPosition.h"

@implementation TFStone


@synthesize squares = _squares, height = _height, width = _width, minX = _minX, minY = _minY, maxX = _maxX, maxY = _maxY;

//	Initializes a stone with no additional squares (consisting of
//	only one square).
//
-(id)init
{
	if(self = [super init]){
		
		_squares = [[NSArray alloc] init];
		_height = 1;
		_width = 1;
		_minX = 0;
		_maxX = 0;
		_minY = 0;
		_maxY = 0;
		
		return self;
	}
	
	return nil;
}

//	Private initializer, should not be used externally
//	because no checks are made as to the contents of the |squares| param.
-(id)initWithSquares:(NSArray*)squares
{
	if(self = [super init]){
		
		_squares = [squares copy];
		_minX = 0;
		_maxX = 0;
		_minY = 0;
		_maxY = 0;
		
		//	need to evaluate total width and height
		for(TFPosition *square in _squares){
			if(square.x > _maxX) _maxX = square.x;
			if(square.x < _minX) _minX = square.x;
			if(square.y > _maxY) _maxY = square.y;
			if(square.y < _minY) _minY = square.y;
		}
		_width = _maxX - _minX + 1;
		_height = _maxY - _minY + 1;
		
		return self;
	}
	
	return nil;
}

-(NSArray*)squares
{
	return [[_squares copy] autorelease];
}

-(BOOL)hasSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	if(x == 0 && y == 0)
		return YES;
	
	for(TFPosition *square in _squares)
		if(x == square.x && y == square.y)
			return YES;
	
	return NO;
}

-(TFStone*)stoneWithAddedSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	if([self hasSquareAtX:x andY:y])
		return nil;
	
	NSArray *newSquares = [_squares arrayByAddingObject:[[[TFPosition alloc] initWithX:x andY:y] autorelease]];
						   
	TFStone *newStone = [[[TFStone alloc] initWithSquares:newSquares] autorelease];
	
	return newStone;
}

-(TFStone*)stoneWithRemovedSquareFromX:(NSInteger)x andY:(NSInteger)y
{
	if(![self hasSquareAtX:x andY:y])
		return nil;
	
	NSMutableArray *newSquares = [[[NSMutableArray alloc] init] autorelease];
	for(TFPosition *square in _squares){
		
		if(x == square.x && y == square.y)
			continue;
		
		[newSquares addObject:square];
	}
	
	TFStone *newStone = [[[TFStone alloc] initWithSquares:newSquares] autorelease];
	
	return newStone;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if([encoder allowsKeyedCoding]){
		[encoder encodeObject:_squares forKey:@"squares"];
		[encoder encodeInteger:_width forKey:@"width"];
		[encoder encodeInteger:_height forKey:@"height"];
		[encoder encodeInteger:_maxX forKey:@"maxX"];
		[encoder encodeInteger:_maxY forKey:@"maxY"];
		[encoder encodeInteger:_minX forKey:@"minX"];
		[encoder encodeInteger:_minY forKey:@"minY"];
		
	}else{
		NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
		@throw exception;
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if(self = [super init]){
		if([decoder allowsKeyedCoding]){
			_squares = [[decoder decodeObjectForKey:@"squares"] retain];
			_width = [decoder decodeIntegerForKey:@"width"];
			_height = [decoder decodeIntegerForKey:@"height"];
			_maxX = [decoder decodeIntForKey:@"maxX"];
			_maxY = [decoder decodeIntForKey:@"maxY"];
			_minX = [decoder decodeIntForKey:@"minX"];
			_minY = [decoder decodeIntForKey:@"minY"];
			
		}else{
			NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
			@throw exception;
		}
		
		return self;
	}
	
	return nil;
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone
{
	//	immutable classes can implement copying by simply retaining the "copied" object
	return [self retain];
}

#pragma mark -

-(void)dealloc
{
	[_squares release];
	[super dealloc];
}

@end

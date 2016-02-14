//
//  TFGame.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 13.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGame.h"

@implementation TFGame

@synthesize gravity = _gravity, stoneGenerator = _stoneGenerator, grid = _grid, stones = _stones;

-(id)initWithGrid:(TFGrid*)grid 
		  gravity:(TFGravity*)gravity 
		generator:(TFStoneGenerator*)generator
		andStones:(NSArray*)stones
{
	if(self = [super init]){
		
		_grid = [grid retain];
		_gravity = [gravity retain];
		_stoneGenerator = [generator retain];
		_stones = [stones copy];
		
		return self;
	}
	
	return nil;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if([encoder allowsKeyedCoding]){
		[encoder encodeObject:_gravity forKey:@"gravity"];
		[encoder encodeObject:_stoneGenerator forKey:@"stoneGenerator"];
		[encoder encodeObject:_grid forKey:@"grid"];
		[encoder encodeObject:_stones forKey:@"stones"];
		
	}else{
		NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
		@throw exception;
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if(self = [super init]){
		if([decoder allowsKeyedCoding]){
			_gravity = [[decoder decodeObjectForKey:@"gravity"] retain];
			_stoneGenerator = [[decoder decodeObjectForKey:@"stoneGenerator"] retain];
			_grid = [[decoder decodeObjectForKey:@"grid"] retain];
			_stones = [[decoder decodeObjectForKey:@"stones"] retain];
			
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
	return [[TFGame alloc] initWithGrid:_grid gravity:_gravity generator:_stoneGenerator andStones:_stones];
}

#pragma mark -

-(void)dealloc
{
	[_grid release];
	[_gravity release];
	[_stoneGenerator release];
	[_stones release];
	
	[super dealloc];
}

@end

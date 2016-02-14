//
//  TFPosition.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 9.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFPosition.h"

@implementation TFPosition

+(TFPosition*)positionWithX:(NSInteger)x andY:(NSInteger)y
{
	TFPosition *rVal = [[TFPosition alloc] initWithX:x andY:y];
	[rVal autorelease];
	return rVal;
}

@synthesize x = _x, y = _y;

-(id)initWithX:(NSInteger)x andY:(NSInteger)y
{
	if(self = [super init]){
		
		_x = x;
		_y = y;
		
		return self;
	}
	
	return nil;
}

- (BOOL)isEqual:(id)anObject
{
	if([anObject isKindOfClass:[TFPosition class]]){
		TFPosition *aPosition = anObject;
		return self.x == aPosition.x && self.y == aPosition.y;
	}
	
	return NO;
}

- (NSUInteger)hash
{
	return 2*_x + _y;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if([encoder allowsKeyedCoding]){
		[encoder encodeInteger:_x forKey:@"x"];
		[encoder encodeInteger:_y forKey:@"y"];
		
	}else{
		NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
		@throw exception;
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if(self = [super init]){
		if([decoder allowsKeyedCoding]){
			_x = [decoder decodeIntegerForKey:@"x"];
			_y = [decoder decodeIntegerForKey:@"y"];
			
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

-(NSString*)description
{
	return [NSString stringWithFormat:@"TFPosition, x:%d, y:%d", _x, _y];
}

@end

//
//  TFStoneGenerator.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 12.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGrid.h"
#import "TFStone.h"
#import "TFPosition.h"
#import "TFStoneGenerator.h"
#import "TFGravity.h"
#include <stdlib.h>
#include <time.h>

@interface TFStoneGenerator ()
{
	NSMutableDictionary *stonesProbabilities;
}

@end

@implementation TFStoneGenerator

-(id)init
{
	if(self = [super init]){
		
		srand(time(NULL));
		stonesProbabilities = [NSMutableDictionary new];
		return self;
	}
	
	return nil;
}


-(void)setProbability:(NSNumber*)probability forStone:(TFStone*)stone
{
	[stonesProbabilities setObject:probability forKey:stone];
}

-(NSArray*)stones
{
	return [stonesProbabilities allKeys];
}

-(NSNumber*)probabilityForStone:(TFStone*)stone
{
	return [stonesProbabilities objectForKey:stone];
}

-(TFStone*)randomStone
{
	if([stonesProbabilities count]  == 0)
		return nil;
	
	//	get probability sum
	//	so we could have normalized probabilities
	float probabilitiesSum = 0.0f;
	for(NSNumber* prob in [stonesProbabilities objectEnumerator])
		probabilitiesSum += [prob floatValue];
	
	//	get a random number on the [0, probabilitiesSum] interval
	float random = ((float)rand()) / RAND_MAX * probabilitiesSum;
	
	//	see which stone we hit
	probabilitiesSum = 0.0f;
	for(TFStone* stone in [stonesProbabilities keyEnumerator]){
		probabilitiesSum += [[stonesProbabilities objectForKey:stone] floatValue];
		if(probabilitiesSum > random)
			return stone;
	}
	
	return [[stonesProbabilities keyEnumerator] nextObject];
}

-(void)attemptGenerationOnGrid:(TFGrid*)grid withGravityDirection:(NSInteger)gravDirection
{
	//	get a stone
	TFStone* stone = [self randomStone];
	if(stone == nil) return;
	
	//	we need a location for the stone so that it "touches" the top of the grid
	//	(where "top" is defined by |gravDirection|)
	
	//	determine the x and y ranges where stone possibly
	//	can be placed
	NSInteger gridXstart, gridYstart, gridXend, gridYend;
	if(gravDirection == TF_PACKER_GRAV_NONE){
		
		gridXstart	= -stone.minX;
		gridXend	= grid.width - 1 - stone.maxX;
		gridYstart	= -stone.minY;
		gridYend	= grid.height - 1 - stone.maxY;
		
	}else if(gravDirection == TF_PACKER_GRAV_DIRECTION_DOWN){
		
		gridXstart	= -stone.minX;
		gridXend	= grid.width - 1 - stone.maxX;
		gridYstart	= grid.height - 1 - stone.maxY;
		gridYend	= grid.height - 1 - stone.maxY;
		
	}else if(gravDirection == TF_PACKER_GRAV_DIRECTION_UP){
		
		gridXstart	= -stone.minX;
		gridXend	= grid.width - 1 - stone.maxX;
		gridYstart	= - stone.minY;
		gridYend	= - stone.minY;
		
	}else if(gravDirection == TF_PACKER_GRAV_DIRECTION_LEFT){
		
		gridXstart	= grid.width - 1 - stone.maxX;
		gridXend	= grid.width - 1 - stone.maxX;
		gridYstart	= -stone.minY;
		gridYend	= grid.height - 1 - stone.maxY;
		
	}else{
		
		gridXstart	= - stone.minX;
		gridXend	= - stone.minX;
		gridYstart	= -stone.minY;
		gridYend	= grid.height - 1 - stone.maxY;
		
	}
	
	//	now we know the range the stone can be placed
	//	we need to take a random location in that range
	//	but if the stone can not be placed there (blocked by other stones)
	//	we need go through all the possible locations until
	//	we find one where it fits, or determine that it fits nowhere (also ok)
	
	BOOL hasXRange = (gridXend - gridXstart) != 0;
	BOOL hasYRange = (gridYend - gridYstart) != 0;
	
	NSInteger startX = gridXstart;
	if(hasXRange)
		startX +=  rand() % (gridXend - gridXstart);
	
	NSInteger startY = gridYstart;
	if(hasYRange)
		startY += rand() % (gridYend - gridYstart);
	
	//	this weird thing starts at (startX, startY),
	//	and works it's way towards the ends of the grid range
	//	where it might want to place stone
	for(int off = 0 ; ; off++){
		
		NSInteger iterationStartX = hasXRange ? startX - off : startX;
		NSInteger iterationEndX = hasXRange ? startX + off : startX;
		NSInteger iterationStartY = hasYRange ? startY - off : startY;
		NSInteger iterationEndY = hasYRange ? startY + off : startY;
		
		for(int x = iterationStartX ; x <= iterationEndX ; x++)
			for(int y = iterationStartY ; y <= iterationEndY ; y++)
				if([grid canPlaceStone:stone atX:x andY:y]){
					[grid addStone:stone fixed:NO atX:x andY:y];
					return;
				}
		
		if( (!hasXRange || (iterationStartX < gridXstart && iterationEndX > gridXend)) && 
		   ( !hasYRange || (iterationStartY < gridYstart && iterationEndY > gridYend))) break;
	}
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if([encoder allowsKeyedCoding]){
		[encoder encodeObject:stonesProbabilities forKey:@"stonesProbabilities"];
		
	}else{
		NSException *exception = [[[NSException alloc] initWithName:@"Coder not keyed" reason:@"Coder not keyed" userInfo:nil] autorelease];
		@throw exception;
	}
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if(self = [super init]){
		
		srand(time(NULL));
		if([decoder allowsKeyedCoding]){
			stonesProbabilities = [[decoder decodeObjectForKey:@"stonesProbabilities"] retain];
			
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
	TFStoneGenerator* copied = [[TFStoneGenerator alloc] init];
	for(TFStone* stone in [stonesProbabilities keyEnumerator])
		[copied setProbability:[stonesProbabilities objectForKey:stone] forStone:stone];
	
	return copied;
}

#pragma mark -

-(void)dealloc
{
	[stonesProbabilities release];
	[super dealloc];
}

@end

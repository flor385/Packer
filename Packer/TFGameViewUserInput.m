//
//  TFGameViewUserInput.m
//  Packer
//
//  Created by Florijan Stamenkovic on 2012 08 29.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGameViewUserInput.h"
#import "TFGrid.h"
#import "TFAppDelegate.h"
#import "TFGameViewController.h"
#import "TFStoneOnGrid.h"

#pragma mark - TFTouchBeganInfo class

@interface TFTouchBeganInfo : NSObject

@property(readonly, assign) CGPointInt touchPos, stonePos, touchOff, stoneOff;

@end

@implementation TFTouchBeganInfo

@synthesize touchPos = _touchPos, touchOff = _touchOff, stoneOff = _stoneOff, stonePos = _stonePos;

-(id)initWithTouchPos:(CGPointInt)touchPos touchOff:(CGPointInt)touchOff andStonePos:(CGPointInt)stonePos stoneOff:(CGPointInt)stoneOff;
{
	if(self = [super init]){
		_touchPos = touchPos;
		_touchOff = touchOff;
		_stonePos = stonePos;
		_stoneOff = stoneOff;
	}
	return self;
}

@end



#pragma mark _ TFGameViewUserInput class

@interface TFGameViewUserInput ()
{
	NSMutableDictionary *touchBeganInfoDict;
}

@end

@implementation TFGameViewUserInput

-(id)initWithFrame:(CGRect)frame viewController:(TFGameViewController*)viewController
{
	EAGLContext* glContext = ((TFAppDelegate*)[UIApplication sharedApplication].delegate).glContext;
	if(self = [super initWithFrame:frame context:glContext grid:viewController.game.grid])
	{
		userInputDelegate = viewController;
		touchBeganInfoDict = [NSMutableDictionary new];
	}
	
	return self;
}

#pragma mark - Responding to events

-(TFStoneOnGrid*)stoneForTouch:(UITouch*)touch
{
	CGPointInt touchGridPos = [self gridPositionForViewPoint:[touch locationInView:self]];
	
	// get all the stones found on the given grid position
	return [self.grid stoneCoveringX:touchGridPos.x andY:touchGridPos.y];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch* touch in touches){
		
		TFStoneOnGrid* touchedStone = [self stoneForTouch:touch];
		if(touchedStone != nil){
			
			//	remember the touch begain info
			TFTouchBeganInfo *info = [[TFTouchBeganInfo alloc] initWithTouchPos:[self gridPositionForViewPoint:[touch locationInView:self]]
																	   touchOff:[self gridOffsetForViewPoint:[touch locationInView:self]]
																	andStonePos:CGPointIntMake(touchedStone.posX, touchedStone.posY)
																	   stoneOff:CGPointIntMake(touchedStone.offX, touchedStone.offY)];
			[touchBeganInfoDict setObject:info forKey:[NSNumber numberWithLong:(long)touch]];
			[info release];
			
			//	do other stuff
			[self setStone:touchedStone isHighlighted:YES];
			[userInputDelegate gameView:self touchBegan:touch forStone:touchedStone];
		}
	}
	
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch* touch in touches){
		TFStoneOnGrid* touchedStone = [userInputDelegate gameView:self stoneForTouch:touch];
		if(touchedStone != nil){
			
			CGPoint currentLocation = [touch locationInView:self];
			CGPointInt currentPosition = [self gridPositionForViewPoint:currentLocation];
			CGPointInt currentOffset = [self gridOffsetForViewPoint:currentLocation];
			
			TFTouchBeganInfo *touchBeganInfo = [touchBeganInfoDict objectForKey:[NSNumber numberWithLong:(long)touch]];
			CGPointInt newPosition = touchBeganInfo.stonePos;
			CGPointInt newOffset = touchBeganInfo.stoneOff;
			newPosition.x += currentPosition.x - touchBeganInfo.touchPos.x;
			newPosition.y += currentPosition.y - touchBeganInfo.touchPos.y;
			newOffset.x += currentOffset.x - touchBeganInfo.touchOff.x;
			newOffset.y += currentOffset.y - touchBeganInfo.touchOff.y;
			
			if(newOffset.x > TF_PACKER_STONE_OFFSET_MAX){
				newOffset.x -= TF_PACKER_STONE_OFFSET_MAX;
				newPosition.x++;
			}else if(newOffset.x < -TF_PACKER_STONE_OFFSET_MAX){
				newOffset.x += TF_PACKER_STONE_OFFSET_MAX;
				newPosition.x--;
			}
			
			if(newOffset.y > TF_PACKER_STONE_OFFSET_MAX){
				newOffset.y -= TF_PACKER_STONE_OFFSET_MAX;
				newPosition.y++;
			}else if(newOffset.y < -TF_PACKER_STONE_OFFSET_MAX){
				newOffset.y += TF_PACKER_STONE_OFFSET_MAX;
				newPosition.y--;
			}
			
			[userInputDelegate gameView:self
							 touchMoved:touch
							  toGridPos:newPosition
							  andOffset:newOffset
					   withGridRotation:[self gridRotation]];
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch* touch in touches){
		
		TFStoneOnGrid* touchedStone = [userInputDelegate gameView:self stoneForTouch:touch];
		if(touchedStone != nil){
			[touchBeganInfoDict removeObjectForKey:[NSNumber numberWithLong:(long)touch]];
			[self setStone:touchedStone isHighlighted:NO];
			[userInputDelegate gameView:self touchEnded:touch];
		}
	}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch* touch in touches){
		TFStoneOnGrid* touchedStone = [userInputDelegate gameView:self stoneForTouch:touch];
		if(touchedStone != nil){
			[self setStone:touchedStone isHighlighted:NO];
			[userInputDelegate gameView:self touchEnded:touch];
		}
	}
}

-(void)dealloc
{
	[touchBeganInfoDict release];
	[super dealloc];
}

@end

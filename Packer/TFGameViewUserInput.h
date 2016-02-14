//
//  TFGameViewUserInput.h
//  Packer
//
//  Created by Florijan Stamenkovic on 2012 08 29.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFGameView.h"

@class TFGameViewController;
@class TFGameViewUserInput;

@protocol TFGameViewUserInputDelegate <NSObject>

-(void)gameView:(TFGameViewUserInput*)view touchBegan:(UITouch*)touch forStone:(TFStoneOnGrid*)stone;
-(void)gameView:(TFGameViewUserInput*)view touchMoved:(UITouch*)touch toGridPos:(CGPointInt)gridPos andOffset:(CGPointInt)gridOff withGridRotation:(NSUInteger)gridRotationPiHalves;
-(void)gameView:(TFGameViewUserInput*)view touchEnded:(UITouch*)touch;
-(TFStoneOnGrid*)gameView:(TFGameViewUserInput*)view stoneForTouch:(UITouch*)touch;

@end

@interface TFGameViewUserInput : TFGameView
{
	NSObject<TFGameViewUserInputDelegate> *userInputDelegate;
}

-(id)initWithFrame:(CGRect)frame viewController:(TFGameViewController*)controller;

@end

//
//  TFGameViewController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 21.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TFGame.h"
#import "TFCGExtras.h"
#import "TFGameViewUserInput.h"

@class TFStoneOnGrid;

@interface TFGameViewController : GLKViewController <TFGameViewUserInputDelegate>

@property(retain, readonly) TFGame* game;

-(id)initWithGame:(TFGame*)game;

@end

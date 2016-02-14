//
//  TFTestTabController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 19.
//  Copyright (c) 2012 FloCo. All rights reserved.
//


#import "TFTestTabController.h"
#import "TFGame.h"
#import "TFGravity.h"
#import "TFGrid.h"
#import "TFStoneGenerator.h"
#import "TFDocumentWindowController.h"
#import "TFGridView.h"
#import "dispatch/dispatch.h"
#import <time.h>

@interface TFTestTabController ()
{
	BOOL testIsRunning;
	dispatch_queue_t dispatchQueue;
}

-(void)performStep:(id)nothing;

@end



@implementation TFTestTabController

@synthesize game = _game, windowController = _windowController, gridView = _gridView, gravDirection = _gravDirection;


-(id)init
{
	self = [super init];
	if(self){
		dispatchQueue = dispatch_queue_create("edu.teonFlorDev.GridStepQueue", NULL);
		testIsRunning = NO;
		_gravDirection = TF_PACKER_GRAV_DIRECTION_DOWN;
	}
	
	return self;
}

int stepCount = 0;
-(IBAction)startTest:(id)sender
{
	testIsRunning = NO;
	
	self.game = [_windowController gameForSaving];
	_gridView.grid = _game.grid;
	
	stepCount = 0;
	testIsRunning = YES;
	dispatch_async(dispatchQueue, ^{ [self performStep:nil]; });
}

-(IBAction)stopTest:(id)sender
{
	testIsRunning = NO;
}


-(void)performStep:(id)nothing
{
	NSTimeInterval t1 = [NSDate timeIntervalSinceReferenceDate];
	
	if(stepCount % TF_PACKER_GRAV_ANIMATION_STEPS == 0)
		_game.gravity.direction = _gravDirection;
	if(stepCount % (2*TF_PACKER_GRAV_ANIMATION_STEPS) == 0)
	   [_game.stoneGenerator attemptGenerationOnGrid:_game.grid withGravityDirection:_game.gravity.direction];
	
	stepCount++;
	
	[_game.gravity performStepOnGrid:_game.grid];
	
	
	dispatch_sync(dispatch_get_main_queue(), ^{ [_gridView redrawGrid]; });
	
	if(testIsRunning){
		double delayInSeconds =  0.033 - ([NSDate timeIntervalSinceReferenceDate] - t1);
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatchQueue, ^(void){
			[self performStep:nil];
		});
	}
}

-(void)dealloc
{
	self.game = nil;
	dispatch_release(dispatchQueue);
	[super dealloc];
}

@end

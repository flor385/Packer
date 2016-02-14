//
//  TFGameViewController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 21.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGameViewController.h"
#import "TFGameViewUserInput.h"
#import "TFTextureLoader.h"
#import "TFGrid.h"
#import "TFGravity.h"
#import "TFStoneGenerator.h"
#import "TFAppDelegate.h"
#import "TFStoneOnGrid.h"
#import "TFStone.h"
#import "TFCGExtras.h"


#pragma mark - TFGameViewController private interface

@interface TFGameViewController ()
{
	NSMutableDictionary* stoneForTouch;
}

@end


#pragma mark - TFGameViewController implementation

@implementation TFGameViewController

@synthesize game = _game;


#pragma mark - Initialization of the game and view

- (id)initWithGame:(TFGame*)game
{
    if(self = [super init]){
		
		//	inits
		stoneForTouch = [NSMutableDictionary new];
		
		//	game retention and cofig
		_game = [game retain];
		_game.gravity.direction = [self gravDirectionForCurrentDeviceOrientation];
		
		//	register for orientation change notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
		
		//	run loop config
		self.preferredFramesPerSecond = 30;
	}
	
	return self;
}

-(void)startGame:(id)sender
{
	[[self navigationController] setNavigationBarHidden:YES animated:YES];
	self.paused = !self.paused;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.paused = YES;
}

- (void)loadView
{
	//	create a start button in the nav bar
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleDone target:self action:@selector(startGame:)] autorelease];
	
	//	create and set teh game view
	TFGameViewUserInput *glkView = [[TFGameViewUserInput alloc] initWithFrame:self.navigationController.view.bounds viewController:self];
	self.view = glkView;
	[glkView release];
}

#pragma mark - Responding to device orientation changes

-(NSInteger)gravDirectionForCurrentDeviceOrientation
{
	BOOL gridIsLandscape = _game.grid.width > _game.grid.height;
	switch ([[UIDevice currentDevice] orientation]) {
			
		case UIDeviceOrientationLandscapeLeft:
			if(gridIsLandscape)
				return TF_PACKER_GRAV_DIRECTION_DOWN;
			else
				return TF_PACKER_GRAV_DIRECTION_LEFT;
			break;
			
		case UIDeviceOrientationLandscapeRight:
			if(gridIsLandscape)
				return TF_PACKER_GRAV_DIRECTION_UP;
			else
				return TF_PACKER_GRAV_DIRECTION_RIGHT;
			break;
			
		case UIDeviceOrientationPortrait:
			if(gridIsLandscape)
				return TF_PACKER_GRAV_DIRECTION_RIGHT;
			else
				return TF_PACKER_GRAV_DIRECTION_DOWN;
			break;
		
		case UIDeviceOrientationPortraitUpsideDown:
			if(gridIsLandscape)
				return TF_PACKER_GRAV_DIRECTION_LEFT;
			else
				return TF_PACKER_GRAV_DIRECTION_UP;
			break;
			
			
		default:
			if(gridIsLandscape)
				return TF_PACKER_GRAV_DIRECTION_DOWN;
			else
				return TF_PACKER_GRAV_DIRECTION_LEFT;
			break;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)orientationDidChange:(NSNotification*)notification
{
	//	make sure the view is notified of orientation change
	TFGameView* gameView = (TFGameView*)self.view;
	[gameView orientationDidChange];
	
	// change gravity direction
	_game.gravity.direction = [self gravDirectionForCurrentDeviceOrientation];
}

#pragma mark - User input

int sgn(int var){
	if(var == 0)
		return 0;
	else if(var > 0)
		return 1;
	else return -1;
}

-(void)gameView:(TFGameViewUserInput*)view touchBegan:(UITouch*)touch forStone:(TFStoneOnGrid*)stone
{
	//	if the touched stone can be held, the make sure it will be held
	[stoneForTouch setObject:stone forKey:[NSNumber numberWithLong:(long)touch]];
}

-(void)gameView2:(TFGameViewUserInput*)view touchMoved:(UITouch*)touch toGridPos:(CGPointInt)gridPos andOffset:(CGPointInt)gridOff withGridRotation:(NSUInteger)gridRotationPiHalves
{
//	NSLog(@"Moving to pos: (%d, %d), off:(%d, %d)", gridPos.x, gridPos.y, gridOff.x, gridOff.y);
	
	TFStoneOnGrid* stone = [self gameView:view stoneForTouch:touch];
	CGPointInt moveToPos = gridPos;
	
	//	first eliminate the y-component (view / user coordinates) of the movement
	switch (gridRotationPiHalves) {
		case 0:
			moveToPos.y = stone.posY;
			break;
		case 1:
			moveToPos.x = stone.posX;
			break;
		case 2:
			moveToPos.y = stone.posY;
			break;
		case 3:
			moveToPos.x = stone.posX;
			break;
		default:
			break;
	}
	
	//	check that the stone can be moved along the desired axis of movement
	//	end when the stone reaches the desired position, or when it can not
	//	be moved in that direction anymore
	int deltaPosX = sgn(moveToPos.x - stone.posX);
	int deltaPosY = sgn(moveToPos.y - stone.posY);
	BOOL done = NO;
	for(int i = stone.posX + deltaPosX ; !done ; i+= deltaPosX){
		for(int j = stone.posY + deltaPosY ; !done ; j+= deltaPosY){
			
			if(![_game.grid canMoveStone:stone toPosX:i andPosY:j withOffX:0 andOffY:0]){
				moveToPos.x = i - deltaPosX;
				moveToPos.y = j - deltaPosY;
				done = YES;
				break;
			}
			
			if(j == moveToPos.y) break;
		}
		
		if(i == moveToPos.x) break;
	}
	
	//	if stone position is the same as before, return
	if(moveToPos.x == stone.posX && moveToPos.y == stone.posY)
		return;
	
	//	move the stone, if it can be moved
	[_game.grid moveStone:stone toPosX:moveToPos.x andPosY:moveToPos.y withOffX:0 andOffY:0];
	
	//	now check that the touch is still over the stone
	//	if not, let go of the stone
	CGPointInt touchedGridPoint = [view gridPositionForViewPoint:[touch locationInView:view]];
	TFStoneOnGrid* stoneUnderTouch = [_game.grid stoneCoveringX:touchedGridPoint.x andY:touchedGridPoint.y];
	if(stoneUnderTouch != stone){
		[view setStone:stone isHighlighted:NO];
		[stoneForTouch removeObjectForKey:[NSNumber numberWithLong:(long)touch]];
	}
}

-(void)gameView:(TFGameViewUserInput*)view touchMoved:(UITouch*)touch toGridPos:(CGPointInt)gridPos andOffset:(CGPointInt)gridOff withGridRotation:(NSUInteger)gridRotationPiHalves
{
	TFStoneOnGrid* stone = [self gameView:view stoneForTouch:touch];
	CGPointInt moveToPos = gridPos;
	CGPointInt moveToOff = gridOff;
	
	//	first eliminate the y-component (view / user coordinates) of the movement
	switch (gridRotationPiHalves) {
		case 0:
			moveToPos.y = stone.posY;
			moveToOff.y = stone.offY;
			break;
		case 1:
			moveToPos.x = stone.posX;
			moveToOff.x = stone.offX;
			break;
		case 2:
			moveToPos.y = stone.posY;
			moveToOff.y = stone.offY;
			break;
		case 3:
			moveToPos.x = stone.posX;
			moveToOff.x = stone.offX;
			break;
		default:
			break;
	}
	CGPointInt moveToTot = CGPointIntMake(moveToPos.x * TF_PACKER_STONE_OFFSET_MAX + moveToOff.x, moveToPos.y * TF_PACKER_STONE_OFFSET_MAX + moveToOff.y);
	
	//	check that the stone can be moved along the desired axis of movement
	//	end when the stone reaches the desired position, or when it can not
	//	be moved in that direction anymore
	int deltaX = sgn(moveToTot.x - stone.posX*TF_PACKER_STONE_OFFSET_MAX - stone.offX)*TF_PACKER_STONE_OFFSET_MAX;
	int deltaY = sgn(moveToTot.y - stone.posY*TF_PACKER_STONE_OFFSET_MAX - stone.offY)*TF_PACKER_STONE_OFFSET_MAX;
	BOOL done = NO;
	
	//	x-dimension iteration from stone pos to moveToPos
	//	step is deltaX, which at first is of OFFSET_MAX magnitude
	//	but at some point maybe reduced to 1
	for(int i = stone.posX*TF_PACKER_STONE_OFFSET_MAX + stone.offX ; !done ; i += deltaX){
		
		//	if i variable has passed the final moving point
		//	then it needs to go one step back, and deltaX needs to become 1
		if( (deltaX > 0 && i > moveToTot.x) || (deltaX < 0 && i < moveToTot.x) ){
			i-= deltaX;
			deltaX /= TF_PACKER_STONE_OFFSET_MAX;
			i+= deltaX;
		}
		
		//	calculate position and offset from their total
		int posX = i / TF_PACKER_STONE_OFFSET_MAX;
		int offX = i % TF_PACKER_STONE_OFFSET_MAX;
		
		//	x-dimension iteration from stone pos to moveToPos
		//	step is deltaX, which at first is of OFFSET_MAX magnitude
		//	but at some point maybe reduced to 1
		for(int j = stone.posY*TF_PACKER_STONE_OFFSET_MAX + stone.offY ; !done ; j+= deltaY){
			
			//	if j variable has passed the final moving point
			//	then it needs to go one step back, and deltaY needs to become 1
			if( (deltaY > 0 && j > moveToTot.y) || (deltaY < 0 && j < moveToTot.y) ){
				j-= deltaY;
				deltaY /= TF_PACKER_STONE_OFFSET_MAX;
				j+= deltaY;
			}
			
			//	calculate position and offset from their total
			int posY = j / TF_PACKER_STONE_OFFSET_MAX;
			int offY = j % TF_PACKER_STONE_OFFSET_MAX;
			
			//	if the stone can not be moved anymore
			//	then end the loop
			if(![_game.grid canMoveStone:stone toPosX:posX andPosY:posY withOffX:offX andOffY:offY]){
				
				//	if the stone can not be moved, but the deltas already
				//	are of 1 magnitude, then we have found the maximum
				//	movement possibility in the desired direction
				if(abs(deltaX) <= 1 && abs(deltaY) <= 1){
					i -= deltaX;
					j -= deltaY;
					moveToPos.x = i / TF_PACKER_STONE_OFFSET_MAX;
					moveToPos.y = j / TF_PACKER_STONE_OFFSET_MAX;
					moveToOff.x = i % TF_PACKER_STONE_OFFSET_MAX;
					moveToOff.y = j % TF_PACKER_STONE_OFFSET_MAX;
					done = YES;
					break;
				}
				
				//	if either of the deltas is still of OFFSET_MAX magnitude,
				//	then iteration goes one step back and the deltas are reduced
				if(abs(deltaX) > 1){
					i -= deltaX;
					deltaX /= abs(deltaX);
				}
				if(abs(deltaY) > 1){
					j -= deltaY;
					deltaY /= abs(deltaY);
				}
			}
			
			if(j == moveToTot.y) break;
		}
		
		if(i == moveToTot.x) break;
	}
	
	//	move the stone
	[_game.grid moveStone:stone toPosX:moveToPos.x andPosY:moveToPos.y withOffX:moveToOff.x andOffY:moveToOff.y];
	
	//	now check that the touch is still over the stone
	//	if not, let go of the stone
	CGPointInt touchedGridPoint = [view gridPositionForViewPoint:[touch locationInView:view]];
	CGPointInt touchedGridOffset = [view gridOffsetForViewPoint:[touch locationInView:view]];
	if(![stone coversX:touchedGridPoint.x andY:touchedGridPoint.y withOffX:touchedGridOffset.x offY:touchedGridOffset.y]){
		[view setStone:stone isHighlighted:NO];
		[stoneForTouch removeObjectForKey:[NSNumber numberWithLong:(long)touch]];
	}
}

-(void)gameView:(TFGameViewUserInput*)view touchEnded:(UITouch*)touch
{
	[stoneForTouch removeObjectForKey:[NSNumber numberWithLong:(long)touch]];
}

-(TFStoneOnGrid*)gameView:(TFGameViewUserInput*)view stoneForTouch:(UITouch*)touch
{
	return [stoneForTouch objectForKey:[NSNumber numberWithLong:(long)touch]];
}

#pragma mark - Run loop actions

-(void)update
{
	//	hold objects
	if(self.framesDisplayed % TF_PACKER_GRAV_ANIMATION_STEPS == 0){
		[_game.gravity setImmovableStones:[stoneForTouch allValues]];
	}
	
	//	perform random stone generation
	if(self.framesDisplayed % (2*TF_PACKER_GRAV_ANIMATION_STEPS) == 0)
		[_game.stoneGenerator attemptGenerationOnGrid:_game.grid withGravityDirection:_game.gravity.direction];
	
	//	perform gravity step
	[_game.gravity performStepOnGrid:_game.grid];
}

#pragma mark -

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_game release];
	[stoneForTouch release];
	[super dealloc];
}

@end

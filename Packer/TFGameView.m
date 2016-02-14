//
//  TFGameView.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 22.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGameView.h"
#import "TFGrid.h"
#import "FSTextures.h"
#import "TFTextureLoader.h"
#import "TFCGExtras.h"
#import "TFStoneOnGrid.h"
#import "TFStone.h"
#import "TFPosition.h"
#import <stdlib.h>
#import <time.h>


#pragma mark TFGrid extensions

//	some additions to the TFGridClass
@interface TFGrid (TFGridViewAdditions)

-(BOOL)isFixedStoneAt:(CGPointInt)point;
-(BOOL)containsPoint:(CGPointInt)point;
-(BOOL)containsPointAtX:(NSInteger)x andY:(NSInteger)y;

@end

@implementation TFGrid (TFGridViewAdditions)

-(BOOL)isFixedStoneAt:(CGPointInt)point
{
	return [self isFixedStoneAtX:point.x andY:point.y];
}

-(BOOL)containsPointAtX:(NSInteger)x andY:(NSInteger)y
{
	return x >= 0 && y >= 0 && x < self.width && y < self.height;
}

-(BOOL)containsPoint:(CGPointInt)point
{
	return point.x >= 0 && point.y >= 0 && point.x < self.width && point.y < self.height;
}

@end

#pragma mark TFGameView private interface

@interface TFGameView ()
{
	//	the glk base effect used for rendering
	GLKBaseEffect *effect;
	
	//	the texture loader
	TFTextureLoader *textureLoader;
	
	//	the texture rendering stack
	FSTextureRenderStack* renderStack;
	
	//	the point (in view coordinates) where the grid (0,0) square
	//	should be rendered
	//	calculated with the calcDrawingParams
	CGPoint squareZeroOrigin;
	
	//	the point (in view coordinates) where the bottom left (in view)
	//	square of the grid's origin is
	CGPoint bottomLeftSquareOrigin;
	
	//	x,y incrementation in view coordinates for +1 in the
	//	x direction in grid coordinates
	//	calculated with the calcDrawingParams
	CGSizeInt squareIncrementX;
	
	//	x,y incrementation in view coordinates for +1 in the
	//	y direction in grid coordinates
	//	calculated with the calcDrawingParams
	CGSizeInt squareIncrementY;
	
	//	the size of a single grid square (in view coordinates)
	//	calculated with the calcDrawingParams
	float squareSize;
	
	//	the amount (in Pi halves) of rotation that needs to be done to a
	//	texture so it would maintain 
	int backgroundRotation;
	
	//	the amount (in Pi halves) of rotation of the grid relative to the view
	int gridRotation;
	
	//	the size of the size of the square clip of the background texture that
	//	renders into one grid square
	float backgroundTextureSquareSize;

	//	the size of the size of the square clip of the stone texture that
	//	renders into one grid square
	float stoneTextureSquareSize;
	
	//	the square side size of a single overlay tile, in view coordinates
	float overlaySquareSize;
	
	//	maps TFPosition objects (used to create CGPoints) that
	//	are randomized-then-remembered origins of stone textures
	NSMutableDictionary* stoneTexturePositionDict;
	
	//	an array of highlighted stones
	NSMutableSet* highlightedStones;
}

@end


#pragma mark - TFGameView implementation

@implementation TFGameView

@synthesize grid = _grid;

-(id)initWithFrame:(CGRect)frame context:(EAGLContext *)context grid:(TFGrid*)grid
{
	if(self = [super initWithFrame:frame context:context]){
		
		self.grid = grid;
		effect = [[GLKBaseEffect alloc] init];
		textureLoader = [TFTextureLoader sharedLoader];
		renderStack = [[FSTextureRenderStack alloc] initWithAtlas:textureLoader.mainTextureAtlas andCapacity:800];
		
		stoneTexturePositionDict = [NSMutableDictionary new];
		highlightedStones = [NSMutableSet new];
		
		[self updateDrawingParams];
		
		//	set the seed for randomizing (used in randomizing stone textures)
		srandom(time(NULL));
		
	}
	
	return self;
}

#pragma mark - Logic

-(void)orientationDidChange
{
	[self updateDrawingParams];
	[self setNeedsDisplay];
}


-(void)setGrid:(TFGrid *)grid
{
	if(grid == _grid) return;
	[grid retain];
	[_grid release];
	_grid = grid;
	
	if(grid != nil)
		[self updateDrawingParams];
	
	[self setNeedsDisplay];
}


#pragma mark - Geometry calc




-(int)gridRotation
{
	return gridRotation;
}

-(CGPointInt)gridPositionForViewPoint:(CGPoint)point
{
	//	translate the point from view point to grid point coordinates
	point.y = self.bounds.size.height - point.y;
	point.x -= bottomLeftSquareOrigin.x;
	point.y -= bottomLeftSquareOrigin.y;
	
	switch (gridRotation) {
		case 0:
			return CGPointIntMake((int)(point.x / squareSize), (int)(point.y / squareSize));
		case 1:
			return CGPointIntMake((int)(point.y / squareSize), _grid.height - 1 - (int)(point.x / squareSize));
		case 2:
			return CGPointIntMake(_grid.width - 1 - (int)(point.x / squareSize), _grid.height - 1 - (int)(point.y / squareSize));
		case 3:
			return CGPointIntMake(_grid.width - 1 - (int)(point.y / squareSize), (int)(point.x / squareSize));
			
		default:
			break;
	}
	
	//	should never happen
	NSException *e = [NSException exceptionWithName:@"Invalid gridRotation" reason:[NSString stringWithFormat:@"GridRotation flag: %d, is not a valid one", gridRotation] userInfo:nil];
	@throw e;
}

-(CGPointInt)gridOffsetForViewPoint:(CGPoint)point
{
	//	translate the point from view point to grid point coordinates
	point.y = self.bounds.size.height - point.y;
	point.x -= bottomLeftSquareOrigin.x;
	point.y -= bottomLeftSquareOrigin.y;
	
	//	remove the non-offset componenets of the point
	point.x -= ((int)(point.x / squareSize)) * squareSize;
	point.y -= ((int)(point.y / squareSize)) * squareSize;
	
	//	recalc the offset components from view points to offset points
	point.x = point.x * TF_PACKER_STONE_OFFSET_MAX / squareSize;
	point.y = point.y * TF_PACKER_STONE_OFFSET_MAX / squareSize;
	
	//	and finally round to ints and accomodate for grid rotation
	switch (gridRotation) {
		case 0:
			return CGPointIntMake((int)point.x, (int)point.y);
		case 1:
			return CGPointIntMake((int)point.y, TF_PACKER_STONE_OFFSET_MAX - (int)point.x);
		case 2:
			return CGPointIntMake(TF_PACKER_STONE_OFFSET_MAX - (int)point.x, TF_PACKER_STONE_OFFSET_MAX - (int)point.y);
		case 3:
			return CGPointIntMake(TF_PACKER_STONE_OFFSET_MAX - (int)point.y, (int)point.x);
			
		default:
			break;
	}
	
	//	should never happen
	NSException *e = [NSException exceptionWithName:@"Invalid gridRotation" reason:[NSString stringWithFormat:@"GridRotation flag: %d, is not a valid one", gridRotation] userInfo:nil];
	@throw e;
}

-(void)updateDrawingParams
{
	//	update the transform
	CGRect bounds = self.bounds;
	float width = bounds.size.width;
	float height = bounds.size.height;
	effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, width, 0, height, -1024, 1024);
	
	//	square size
	float r1 = fminf(width, height) / (fminf(_grid.width, _grid.height) + 1);
	float r2 = fmaxf(width, height) / (fmaxf(_grid.width, _grid.height) + 1);
	squareSize = fminf(r1, r2);
	overlaySquareSize = squareSize / 4.0;
	
	//	background texture square size
	r1 = textureLoader.background.frameInAtlas.size.width / (fmaxf(_grid.width, _grid.height) + 1);
	r2 = textureLoader.background.frameInAtlas.size.width * fminf(width, height) / fmaxf(width, height) / (fminf(_grid.width, _grid.height) + 1);
	backgroundTextureSquareSize = fminf(r1, r2);
	
	//	the scale in which the stone texture should be rendered
	stoneTextureSquareSize = textureLoader.stone.frameInAtlas.size.width / MAX(_grid.width, _grid.height) * 2.0;

	//	calc the position of grid origin (bottom left corner of the 0.0 square
	//	in grid) in view coordinates
	//	also calc square incrementation flags and background rotation (assuming the background text is in landscape)
	BOOL gridIsLandscape = _grid.width > _grid.height;
	switch ([[UIDevice currentDevice] orientation]) {
			
		case UIDeviceOrientationFaceDown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationLandscapeLeft:
			
			backgroundRotation = 0;
			if(gridIsLandscape){
				gridRotation = 0;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.width*squareSize)/2.0,
													 (bounds.size.height - _grid.height*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   (bounds.size.width - _grid.width*squareSize)/2.0,
											   (bounds.size.height - _grid.height*squareSize)/2.0);
				
				squareIncrementX = CGSizeIntMake(1, 0);
				squareIncrementY = CGSizeIntMake(0, 1);
				
				
			}else{
				gridRotation = 1;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.height*squareSize)/2.0,
													 (bounds.size.height - _grid.width*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   bounds.size.width - (bounds.size.width - _grid.height*squareSize)/2.0 - squareSize,
											   (bounds.size.height - _grid.width*squareSize)/2.0);
				
				squareIncrementX = CGSizeIntMake(0, 1);
				squareIncrementY = CGSizeIntMake(-1, 0);
			}
			
			break;
			
		case UIDeviceOrientationLandscapeRight:
			
			backgroundRotation = 2;
			if(gridIsLandscape){
				gridRotation = 2;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.width*squareSize)/2.0,
													 (bounds.size.height - _grid.height*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   bounds.size.width - (bounds.size.width - _grid.width*squareSize)/2.0 - squareSize,
											   bounds.size.height - (bounds.size.height - _grid.height*squareSize)/2.0 - squareSize);
				
				squareIncrementX = CGSizeIntMake(-1, 0);
				squareIncrementY = CGSizeIntMake(0, -1);
				
			}else{
				gridRotation = 3;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.height*squareSize)/2.0,
													 (bounds.size.height - _grid.width*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   (bounds.size.width - _grid.height*squareSize)/2.0, 
											   bounds.size.height - (bounds.size.height - _grid.width*squareSize)/2.0 - squareSize);
				
				squareIncrementX = CGSizeIntMake(0, -1);
				squareIncrementY = CGSizeIntMake(1, 0);
			}
			
			break;
			
		case UIInterfaceOrientationPortrait:
			
			backgroundRotation = 3;
			if(gridIsLandscape){
				gridRotation = 3;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.height*squareSize)/2.0,
													 (bounds.size.height - _grid.width*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   (bounds.size.width - _grid.height*squareSize)/2.0,
											   bounds.size.height - (bounds.size.height - _grid.width*squareSize)/2.0 - squareSize);
				
				squareIncrementX = CGSizeIntMake(0, -1);
				squareIncrementY = CGSizeIntMake(1, 0);
				
			}else{
				gridRotation = 0;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.width*squareSize)/2.0,
													 (bounds.size.height - _grid.height*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   (bounds.size.width - _grid.width*squareSize)/2.0, 
											   (bounds.size.height - _grid.height*squareSize)/2.0);
				
				squareIncrementX = CGSizeIntMake(1, 0);
				squareIncrementY = CGSizeIntMake(0, 1);
			}
			
			break;
			
		case UIInterfaceOrientationPortraitUpsideDown:
			
			backgroundRotation = 1;
			if(gridIsLandscape){
				gridRotation = 1;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.height*squareSize)/2.0,
													 (bounds.size.height - _grid.width*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   bounds.size.width - (bounds.size.width - _grid.height*squareSize)/2.0 - squareSize,
											   (bounds.size.height - _grid.width*squareSize)/2.0);
				
				squareIncrementX = CGSizeIntMake(0, 1);
				squareIncrementY = CGSizeIntMake(-1, 0);
				
			}else{
				gridRotation = 2;
				bottomLeftSquareOrigin = CGPointMake((bounds.size.width - _grid.width*squareSize)/2.0,
													 (bounds.size.height - _grid.height*squareSize)/2.0);
				squareZeroOrigin = CGPointMake(
											   bounds.size.width - (bounds.size.width - _grid.width*squareSize)/2.0 - squareSize, 
											   bounds.size.height - (bounds.size.height - _grid.height*squareSize)/2.0 - squareSize);
				
				squareIncrementX = CGSizeIntMake(-1, 0);
				squareIncrementY = CGSizeIntMake(0, -1);
			}
			
			break;
			
		
		default:
			break;
	}
}

-(CGPointInt)squareLeftOfSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	CGPointInt rVal;
	rVal.x = x - squareIncrementX.width;
	rVal.y = y - squareIncrementY.width;
	return rVal;
}

-(CGPointInt)squareRightOfSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	CGPointInt rVal;
	rVal.x = x + squareIncrementX.width;
	rVal.y = y + squareIncrementY.width;
	return rVal;
}

-(CGPointInt)squareAboveSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	CGPointInt rVal;
	rVal.x = x + squareIncrementX.height;
	rVal.y = y + squareIncrementY.height;
	return rVal;
}

-(CGPointInt)squareBelowSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	CGPointInt rVal;
	rVal.x = x - squareIncrementX.height;
	rVal.y = y - squareIncrementY.height;
	return rVal;
}

-(CGPoint)texture:(FSTexture*)texture originForStone:(TFStoneOnGrid*)stone
{
	TFPosition* pos = [stoneTexturePositionDict objectForKey:stone];
	if(pos == nil){
		
		//	if creating a randomized position we have to know
		//	 how much to the left and right does the stone extend
		int xMin = (int)ceilf(-stone.stone.minX * stoneTextureSquareSize);
		int xMax = (int)floorf(texture.frameInAtlas.size.width  - (stone.stone.maxX + 1)*stoneTextureSquareSize);
		int yMin = (int)ceilf(-stone.stone.minY * stoneTextureSquareSize);
		int yMax = (int)floorf(texture.frameInAtlas.size.height - (stone.stone.maxY + 1)*stoneTextureSquareSize);
		
		//	we need to generate a location so that the stone
		//	does not escape texture's bounds, i.e. between min and max
		pos = [TFPosition positionWithX:random()%(xMax-xMin)+xMin andY:random()%(yMax-yMin)+yMin];
		[stoneTexturePositionDict setObject:pos forKey:stone];
	}
	
	return CGPointMake(pos.x, pos.y);
}

#pragma mark - Rendering

-(void)renderMovingStone:(TFStoneOnGrid*)stone
{
	//	now render
	FSTexture* texture = textureLoader.stone;
	
	//	first get the mapping of the origin stone's origin (grid coordinates)
	//	in the texture's coordinates
	CGPoint textureOrigin = [self texture:texture originForStone:stone];
	CGPoint stoneFloatOrigin = CGPointMake(stone.posX + ((CGFloat)stone.offX) / TF_PACKER_STONE_OFFSET_MAX, stone.posY + ((CGFloat)stone.offY) / TF_PACKER_STONE_OFFSET_MAX);
	
	CGPoint stoneRenderOrigin = CGPointMake(
		squareZeroOrigin.x + stoneFloatOrigin.x * squareIncrementX.width * squareSize + stoneFloatOrigin.y * squareIncrementY.width * squareSize,
		squareZeroOrigin.y + stoneFloatOrigin.x * squareIncrementX.height * squareSize + stoneFloatOrigin.y * squareIncrementY.height * squareSize);
	
	CGRect squareRenderingRect = CGRectMake(stoneRenderOrigin.x, stoneRenderOrigin.y, squareSize, squareSize);
	[renderStack pushPart:CGRectMake(textureOrigin.x, textureOrigin.y, stoneTextureSquareSize, stoneTextureSquareSize)
				ofTexture:texture
				   inRect:squareRenderingRect
			 withRotation:gridRotation];
	
	for(TFPosition* pos in stone.stone.squares){
		squareRenderingRect = CGRectMake(
			stoneRenderOrigin.x + pos.x * squareIncrementX.width * squareSize + pos.y * squareIncrementY.width * squareSize,
			stoneRenderOrigin.y + pos.x * squareIncrementX.height * squareSize + pos.y * squareIncrementY.height * squareSize,
			squareSize, squareSize);
		[renderStack pushPart:CGRectMake(textureOrigin.x + pos.x * stoneTextureSquareSize, textureOrigin.y + pos.y * stoneTextureSquareSize, stoneTextureSquareSize, stoneTextureSquareSize)
					ofTexture:texture
					   inRect:squareRenderingRect
				 withRotation:gridRotation];
	}
}

-(void)renderSquareOverlayAtRenderPoint:(CGPoint)renderOrigin thatHasSquareAbove:(BOOL)hasAbove below:(BOOL)hasBelow left:(BOOL)hasLeft right:(BOOL)hasRight aboveLeft:(BOOL)hasAboveLeft aboveRight:(BOOL)hasAboveRight belowLeft:(BOOL)hasBelowLeft belowRight:(BOOL)hasBelowRight
{
	//	entire left side of the square
	if(!hasLeft){
		
		//	lower left corner
		if(!hasBelow)
			[renderStack pushTexture:textureLoader.stoneOverlayLowLeft inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		else
			[renderStack pushTexture:textureLoader.stoneOverlayMidLeft inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		
		
		//	upper left corner
		if(!hasAbove)
			[renderStack pushTexture:textureLoader.stoneOverlayTopLeft inRect:CGRectMake(renderOrigin.x, renderOrigin.y + 0.75 * squareSize, overlaySquareSize, overlaySquareSize)];
		else
			[renderStack pushTexture:textureLoader.stoneOverlayMidLeft inRect:CGRectMake(renderOrigin.x, renderOrigin.y + 0.75 * squareSize, overlaySquareSize, overlaySquareSize)];
		
		//	left side
		[renderStack pushTexture:textureLoader.stoneOverlayMidLeft inRect:CGRectMake(renderOrigin.x, renderOrigin.y + overlaySquareSize, overlaySquareSize, overlaySquareSize)];
		[renderStack pushTexture:textureLoader.stoneOverlayMidLeft inRect:CGRectMake(renderOrigin.x, renderOrigin.y + overlaySquareSize + overlaySquareSize, overlaySquareSize, overlaySquareSize)];
		
		
	}else{
		
		//	lower left corner
		if(!hasBelow)
			[renderStack pushTexture:textureLoader.stoneOverlayLowMid inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		else if(!hasBelowLeft)
			[renderStack pushTexture:textureLoader.stoneOverlayLowLeft2 inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		
		//	upper left cornder
		if(!hasAbove)
			[renderStack pushTexture:textureLoader.stoneOverlayTopMid inRect:CGRectMake(renderOrigin.x, renderOrigin.y + squareSize * 0.75, overlaySquareSize, overlaySquareSize)];
		else if(!hasAboveLeft)
			[renderStack pushTexture:textureLoader.stoneOverlayTopLeft2 inRect:CGRectMake(renderOrigin.x, renderOrigin.y + squareSize * 0.75, overlaySquareSize, overlaySquareSize)];
	}
	
	
	//	entire right side of the square
	renderOrigin.x += squareSize * 0.75;
	if(!hasRight){
		
		//	lower right corner
		if(!hasBelow)
			[renderStack pushTexture:textureLoader.stoneOverlayLowRight inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		else
			[renderStack pushTexture:textureLoader.stoneOverlayMidRight inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		
		
		//	upper right corner
		if(!hasAbove)
			[renderStack pushTexture:textureLoader.stoneOverlayTopRight inRect:CGRectMake(renderOrigin.x, renderOrigin.y + squareSize * 0.75, overlaySquareSize, overlaySquareSize)];
		else
			[renderStack pushTexture:textureLoader.stoneOverlayMidRight inRect:CGRectMake(renderOrigin.x, renderOrigin.y + squareSize * 0.75, overlaySquareSize, overlaySquareSize)];
		
		//	right side
		[renderStack pushTexture:textureLoader.stoneOverlayMidRight inRect:CGRectMake(renderOrigin.x, renderOrigin.y + overlaySquareSize, overlaySquareSize, overlaySquareSize)];
		[renderStack pushTexture:textureLoader.stoneOverlayMidRight inRect:CGRectMake(renderOrigin.x, renderOrigin.y + overlaySquareSize + overlaySquareSize, overlaySquareSize, overlaySquareSize)];
		
	}else{
		
		//	lower right corner
		if(!hasBelow)
			[renderStack pushTexture:textureLoader.stoneOverlayLowMid inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		else if(!hasBelowRight)
			[renderStack pushTexture:textureLoader.stoneOverlayLowRight2 inRect:CGRectMake(renderOrigin.x, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		
		//	upper right cornder
		if(!hasAbove)
			[renderStack pushTexture:textureLoader.stoneOverlayTopMid inRect:CGRectMake(renderOrigin.x, renderOrigin.y + squareSize * 0.75, overlaySquareSize, overlaySquareSize)];
		else if(!hasAboveRight)
			[renderStack pushTexture:textureLoader.stoneOverlayTopRight2 inRect:CGRectMake(renderOrigin.x, renderOrigin.y + squareSize * 0.75, overlaySquareSize, overlaySquareSize)];
	
	}
	
	//	middle of the bottom side of the stone
	renderOrigin.x -= squareSize * 0.75;
	if(!hasBelow){
		[renderStack pushTexture:textureLoader.stoneOverlayLowMid inRect:CGRectMake(renderOrigin.x + overlaySquareSize, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		[renderStack pushTexture:textureLoader.stoneOverlayLowMid inRect:CGRectMake(renderOrigin.x + overlaySquareSize + overlaySquareSize, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
	}
	
	//	middle of the top side of the stone
	renderOrigin.y += 0.75 * squareSize;
	if(!hasAbove){
		[renderStack pushTexture:textureLoader.stoneOverlayTopMid inRect:CGRectMake(renderOrigin.x + overlaySquareSize, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
		[renderStack pushTexture:textureLoader.stoneOverlayTopMid inRect:CGRectMake(renderOrigin.x + overlaySquareSize + overlaySquareSize, renderOrigin.y, overlaySquareSize, overlaySquareSize)];
	}
}

-(void)renderShadowForSquareAtRenderPoint:(CGPoint)squareRenderOrigin
{
	[renderStack pushTexture:textureLoader.shadow inRect:CGRectMake(squareRenderOrigin.x + 0.10*squareSize, squareRenderOrigin.y - 0.12*squareSize, squareSize, squareSize)];
}

-(void)renderStoneShadow:(TFStoneOnGrid*)stone
{
	CGPoint stoneFloatOrigin = CGPointMake(stone.posX + ((CGFloat)stone.offX) / TF_PACKER_STONE_OFFSET_MAX, stone.posY + ((CGFloat)stone.offY) / TF_PACKER_STONE_OFFSET_MAX);
	CGPoint stoneRenderOrigin = CGPointMake(
											squareZeroOrigin.x + stoneFloatOrigin.x * squareIncrementX.width * squareSize + stoneFloatOrigin.y * squareIncrementY.width * squareSize,
											squareZeroOrigin.y + stoneFloatOrigin.x * squareIncrementX.height * squareSize + stoneFloatOrigin.y * squareIncrementY.height * squareSize);
	
	//	iterate through stone squares
	NSArray *squares = stone.stone.squares;
	for(int i = -1 ; i < (NSInteger)squares.count ; i++){
		
		NSInteger posX = 0;
		NSInteger posY = 0;
		posX += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).x;
		posY += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).y;
		
		CGPoint squareRenderOrigin = CGPointMake(stoneRenderOrigin.x + posX * squareIncrementX.width * squareSize + posY * squareIncrementY.width * squareSize,
												 stoneRenderOrigin.y + posX * squareIncrementX.height * squareSize + posY * squareIncrementY.height * squareSize);
		if(squareRenderOrigin.x < 0.0)
			return;
		[self renderShadowForSquareAtRenderPoint:squareRenderOrigin];
	}
}

-(void)renderShadows
{
	// first render the shadows of the screen edge and fixed stones
	CGPoint renderPoint = CGPointMake(bottomLeftSquareOrigin.x - squareSize, bottomLeftSquareOrigin.y);
	int gridHeightInView = gridRotation % 2 ? _grid.width : _grid.height;
	for(int i = 0 ; i < gridHeightInView ; i++){
		[self renderShadowForSquareAtRenderPoint:renderPoint];
		renderPoint.y += squareSize;
	}
	int gridWidthInView = gridRotation % 2 ? _grid.height : _grid.width;
	for(int i = 0 ; i <= gridWidthInView ; i++){
		[self renderShadowForSquareAtRenderPoint:renderPoint];
		renderPoint.x += squareSize;
	}
	
	//	then render fixed stone shadows
	for(int i = 0 ; i < _grid.width ; i++){
		
		//	define coordinates for the beginning of a grid's column
		renderPoint.x = squareZeroOrigin.x + i*squareIncrementX.width*squareSize;
		renderPoint.y = squareZeroOrigin.y + i*squareIncrementX.height*squareSize;
		
		//	iterate through grid's height (a column)
		for(int j = 0 ; j < _grid.height ; j++){
			
			if([_grid isFixedStoneAtX:i andY:j])
				[self renderShadowForSquareAtRenderPoint:renderPoint];
			
			renderPoint.x += squareIncrementY.width *squareSize;
			renderPoint.y += squareIncrementY.height*squareSize;
		}
	}
	
	//	and finally render moving stone shadows
	for(TFStoneOnGrid* movingStone in _grid.stones)
		[self renderStoneShadow:movingStone];
}

-(void)setStone:(TFStoneOnGrid*)stone isHighlighted:(BOOL)isHighlighted
{
	if(isHighlighted)
		[highlightedStones addObject:stone];
	else
		[highlightedStones removeObject:stone];
}

-(void)renderHighlights
{
	for(TFStoneOnGrid* stone in highlightedStones){
		CGPoint stoneFloatOrigin = CGPointMake(stone.posX + ((CGFloat)stone.offX) / TF_PACKER_STONE_OFFSET_MAX, stone.posY + ((CGFloat)stone.offY) / TF_PACKER_STONE_OFFSET_MAX);
		CGPoint stoneRenderOrigin = CGPointMake(
												squareZeroOrigin.x + stoneFloatOrigin.x * squareIncrementX.width * squareSize + stoneFloatOrigin.y * squareIncrementY.width * squareSize,
												squareZeroOrigin.y + stoneFloatOrigin.x * squareIncrementX.height * squareSize + stoneFloatOrigin.y * squareIncrementY.height * squareSize);
		
		//	iterate through stone squares
		NSArray *squares = stone.stone.squares;
		for(int i = -1 ; i < (NSInteger)squares.count ; i++){
			
			NSInteger posX = 0;
			NSInteger posY = 0;
			posX += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).x;
			posY += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).y;
			
			CGPoint squareRenderOrigin = CGPointMake(stoneRenderOrigin.x + posX * squareIncrementX.width * squareSize + posY * squareIncrementY.width * squareSize,
													 stoneRenderOrigin.y + posX * squareIncrementX.height * squareSize + posY * squareIncrementY.height * squareSize);
			if(squareRenderOrigin.x < 0.0)
				return;
			[renderStack pushTexture:textureLoader.highlight inRect:CGRectMake(squareRenderOrigin.x, squareRenderOrigin.y, squareSize, squareSize)];
		}
	}
}

-(void)renderStoneOverlay:(TFStoneOnGrid*)stone
{
	CGPoint stoneFloatOrigin = CGPointMake(stone.posX + ((CGFloat)stone.offX) / TF_PACKER_STONE_OFFSET_MAX, stone.posY + ((CGFloat)stone.offY) / TF_PACKER_STONE_OFFSET_MAX);
	CGPoint stoneRenderOrigin = CGPointMake(
											squareZeroOrigin.x + stoneFloatOrigin.x * squareIncrementX.width * squareSize + stoneFloatOrigin.y * squareIncrementY.width * squareSize,
											squareZeroOrigin.y + stoneFloatOrigin.x * squareIncrementX.height * squareSize + stoneFloatOrigin.y * squareIncrementY.height * squareSize);
	
	//	iterate through stone squares
	NSArray *squares = stone.stone.squares;
	for(int i = -1 ; i < (NSInteger)squares.count ; i++){
		
		NSInteger posX = 0;
		NSInteger posY = 0;
		posX += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).x;
		posY += i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).y;
		
		CGPoint squareRenderOrigin = CGPointMake(stoneRenderOrigin.x + posX * squareIncrementX.width * squareSize + posY * squareIncrementY.width * squareSize,
												 stoneRenderOrigin.y + posX * squareIncrementX.height * squareSize + posY * squareIncrementY.height * squareSize);
		
		CGPointInt squareAbove = [self squareAboveSquareAtX:posX andY:posY];
		CGPointInt squareAboveLeft = [self squareLeftOfSquareAtX:squareAbove.x andY:squareAbove.y];
		CGPointInt squareAboveRight = [self squareRightOfSquareAtX:squareAbove.x andY:squareAbove.y];
		CGPointInt squareBelow = [self squareBelowSquareAtX:posX andY:posY];
		CGPointInt squareBelowLeft = [self squareLeftOfSquareAtX:squareBelow.x andY:squareBelow.y];
		CGPointInt squareBelowRight = [self squareRightOfSquareAtX:squareBelow.x andY:squareBelow.y];
		CGPointInt squareLeft = [self squareLeftOfSquareAtX:posX andY:posY];
		CGPointInt squareRight = [self squareRightOfSquareAtX:posX andY:posY];
		
		BOOL hasAbove = [stone.stone hasSquareAtX:squareAbove.x andY:squareAbove.y];
		BOOL hasAboveLeft = [stone.stone hasSquareAtX:squareAboveLeft.x andY:squareAboveLeft.y];
		BOOL hasAboveRight = [stone.stone hasSquareAtX:squareAboveRight.x andY:squareAboveRight.y];
		BOOL hasBelow = [stone.stone hasSquareAtX:squareBelow.x andY:squareBelow.y];
		BOOL hasBelowLeft = [stone.stone hasSquareAtX:squareBelowLeft.x andY:squareBelowLeft.y];
		BOOL hasBelowRight = [stone.stone hasSquareAtX:squareBelowRight.x andY:squareBelowRight.y];
		BOOL hasLeft = [stone.stone hasSquareAtX:squareLeft.x andY:squareLeft.y];
		BOOL hasRight = [stone.stone hasSquareAtX:squareRight.x andY:squareRight.y];
		
		[self renderSquareOverlayAtRenderPoint:squareRenderOrigin thatHasSquareAbove:hasAbove below:hasBelow left:hasLeft right:hasRight aboveLeft:hasAboveLeft aboveRight:hasAboveRight belowLeft:hasBelowLeft belowRight:hasBelowRight];
	}
}

-(void)renderOverlays
{
	//	render moving stone overlays
	for(TFStoneOnGrid* movingStone in _grid.stones)
		[self renderStoneOverlay:movingStone];
	
	//	render grid boundary and fixed stone overlays
	CGPoint renderPoint = CGPointMake(squareZeroOrigin.x, squareZeroOrigin.y);
	
	//	iterate through all of grid's squares and render fixed stones
	for(int i = -1 ; i <= _grid.width ; i++){
		
		//	define coordinates for the beginning of a grid's column
		renderPoint.x = squareZeroOrigin.x + i*squareIncrementX.width*squareSize - squareIncrementY.width *squareSize;
		renderPoint.y = squareZeroOrigin.y + i*squareIncrementX.height*squareSize - squareIncrementY.height*squareSize;
		
		//	iterate through grid's height (a column)
		for(int j = -1 ; j <= _grid.height ; j++){
			
			CGPointInt squareAbove = [self squareAboveSquareAtX:i andY:j];
			CGPointInt squareAboveLeft = [self squareLeftOfSquareAtX:squareAbove.x andY:squareAbove.y];
			CGPointInt squareAboveRight = [self squareRightOfSquareAtX:squareAbove.x andY:squareAbove.y];
			CGPointInt squareBelow = [self squareBelowSquareAtX:i andY:j];
			CGPointInt squareBelowLeft = [self squareLeftOfSquareAtX:squareBelow.x andY:squareBelow.y];
			CGPointInt squareBelowRight = [self squareRightOfSquareAtX:squareBelow.x andY:squareBelow.y];
			CGPointInt squareLeft = [self squareLeftOfSquareAtX:i andY:j];
			CGPointInt squareRight = [self squareRightOfSquareAtX:i andY:j];
			
			BOOL hasAbove = [_grid isFixedStoneAt:squareAbove] || ![_grid containsPoint:squareAbove];
			BOOL hasAboveLeft = [_grid isFixedStoneAt:squareAboveLeft] || ![_grid containsPoint:squareAboveLeft];
			BOOL hasAboveRight = [_grid isFixedStoneAt:squareAboveRight] || ![_grid containsPoint:squareAboveRight];
			BOOL hasBelow = [_grid isFixedStoneAt:squareBelow] || ![_grid containsPoint:squareBelow];
			BOOL hasBelowLeft = [_grid isFixedStoneAt:squareBelowLeft] || ![_grid containsPoint:squareBelowLeft];
			BOOL hasBelowRight = [_grid isFixedStoneAt:squareBelowRight] || ![_grid containsPoint:squareBelowRight];
			BOOL hasLeft = [_grid isFixedStoneAt:squareLeft] || ![_grid containsPoint:squareLeft];
			BOOL hasRight = [_grid isFixedStoneAt:squareRight] || ![_grid containsPoint:squareRight];
			
			//	check if the position is the edge of the grid, if so, render overlay
			if(![_grid containsPointAtX:i andY:j])
				
				[self renderSquareOverlayAtRenderPoint:renderPoint thatHasSquareAbove:hasAbove below:hasBelow left:hasLeft right:hasRight aboveLeft:hasAboveLeft aboveRight:hasAboveRight belowLeft:hasBelowLeft belowRight:hasBelowRight];
			
			//	check if the position is fixed stone, if so, then render overlay
			else if([_grid isFixedStoneAtX:i andY:j])
				
				[self renderSquareOverlayAtRenderPoint:renderPoint thatHasSquareAbove:hasAbove below:hasBelow left:hasLeft right:hasRight aboveLeft:hasAboveLeft aboveRight:hasAboveRight belowLeft:hasBelowLeft belowRight:hasBelowRight];
			
			renderPoint.x += squareIncrementY.width *squareSize;
			renderPoint.y += squareIncrementY.height*squareSize;
		}
	}
}

-(void)renderMovingStones
{
	for(TFStoneOnGrid* stone in _grid.stones)
		[self renderMovingStone:stone];
}

-(void)renderBackground
{
	//	we want to preserve the aspect ratio of the background texture
	//	which is made so it's width is fixed
	FSTexture* backgroundTexture = textureLoader.background;
	CGSize selfSize = self.bounds.size;
	CGFloat aspectRatio = fminf(selfSize.width, selfSize.height) / fmaxf(selfSize.width, selfSize.height);
	CGRect textPart = CGRectMake(0.0, 0.0, backgroundTexture.frameInAtlas.size.width, aspectRatio * backgroundTexture.frameInAtlas.size.width);
	
	[renderStack pushPart:textPart ofTexture:backgroundTexture inRect:self.bounds withRotation:backgroundRotation];
}


-(void)renderFixedStonesAndGrid
{
	FSTexture *gridSquareText = textureLoader.gridSquare;
	FSTexture *backgoundTexture = textureLoader.background;
	CGRect renderSquare = CGRectMake(0.0, 0.0, squareSize, squareSize);
	
	CGPoint backgroundTextureBottomLeftSquareOrigin;
	if(backgroundRotation % 2)
		backgroundTextureBottomLeftSquareOrigin = CGPointMake(bottomLeftSquareOrigin.y * backgroundTextureSquareSize / squareSize, bottomLeftSquareOrigin.x * backgroundTextureSquareSize / squareSize);
	else
		backgroundTextureBottomLeftSquareOrigin = CGPointMake(bottomLeftSquareOrigin.x * backgroundTextureSquareSize / squareSize, bottomLeftSquareOrigin.y * backgroundTextureSquareSize / squareSize);

	//	iterate through all of grid's squares and render fixed stones
	for(int i = -1 ; i <= _grid.width ; i++){
		
		//	define coordinates for the beginning of a grid's column
		renderSquare.origin.x = squareZeroOrigin.x + i*squareIncrementX.width*squareSize - squareIncrementY.width *squareSize;
		renderSquare.origin.y = squareZeroOrigin.y + i*squareIncrementX.height*squareSize - squareIncrementY.height*squareSize;
		
		//	iterate through grid's height (a column)
		for(int j = -1 ; j <= _grid.height ; j++){
			
			//	check if the position is the edge of the grid
			//	if so, render it's tile
			if(![_grid containsPointAtX:i andY:j] || [_grid isFixedStoneAtX:i andY:j]){
				
				CGPoint backgroundTextureTileOrigin;
				
				
				if(_grid.width > _grid.height)
					backgroundTextureTileOrigin = CGPointMake(backgroundTextureBottomLeftSquareOrigin.x + i * backgroundTextureSquareSize,backgroundTextureBottomLeftSquareOrigin.y + j * backgroundTextureSquareSize);
				else
					backgroundTextureTileOrigin = CGPointMake(backgoundTexture.frameInAtlas.size.width - backgroundTextureBottomLeftSquareOrigin.x - (j+1) * backgroundTextureSquareSize, backgroundTextureBottomLeftSquareOrigin.y + i * backgroundTextureSquareSize);
																																			
				[renderStack pushPart:CGRectMake(backgroundTextureTileOrigin.x, backgroundTextureTileOrigin.y, backgroundTextureSquareSize, backgroundTextureSquareSize)
							ofTexture:backgoundTexture
							   inRect:renderSquare
						 withRotation:backgroundRotation];
			}
			
			//	check if the position is fixed stone
			//	if there is not, render the empty grid square,
			//	otherwise render
			else
				[renderStack pushTexture:gridSquareText inRect:renderSquare];
			
			renderSquare.origin.x += squareIncrementY.width *squareSize;
			renderSquare.origin.y += squareIncrementY.height*squareSize;
		}
	}
}


-(void)drawRect:(CGRect)rect
{	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	[renderStack clear];
	[self renderBackground];
	[self renderShadows];
	[self renderFixedStonesAndGrid];
	[self renderMovingStones];
	[self renderOverlays];
	[self renderHighlights];
	
	[renderStack renderToEffect:effect];
}

#pragma mark -

-(void)dealloc
{
	self.grid = nil;
	[effect release];
	[stoneTexturePositionDict release];
	[highlightedStones release];
	[super dealloc];
}

@end

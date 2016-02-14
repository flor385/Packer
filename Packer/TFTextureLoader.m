//
//  TFTextureLoader.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 22.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFTextureLoader.h"

@implementation TFTextureLoader

@synthesize deviceIsPad = _deviceIsPad, deviceIsRetina = _deviceIsRetina;

@synthesize mainTextureAtlas = _mainTextureAtlas;

@synthesize background = _background, stone = _stone, gridSquare = _gridSquare, shadow = _shadow;
@synthesize
stoneOverlayLowLeft = _stoneOverlayLowLeft,
stoneOverlayLowLeft2 = _stoneOverlayLowLeft2,
stoneOverlayMidRight = _stoneOverlayMidRight,
stoneOverlayMidLeft = _stoneOverlayMidLeft,
stoneOverlayLowRight = _stoneOverlayLowRight,
stoneOverlayLowRight2 = _stoneOverlayLowRight2,
stoneOverlayLowMid = _stoneOverlayLowMid,
stoneOverlayTopLeft = _stoneOverlayTopLeft,
stoneOverlayTopLeft2 = _stoneOverlayTopLeft2,
stoneOverlayTopMid = _stoneOverlayTopMid,
stoneOverlayTopRight = _stoneOverlayTopRight,
stoneOverlayTopRight2 = _stoneOverlayTopRight2;
@synthesize highlight = _highlight;

- (id)init
{
	if(self = [super init]){
		
		_deviceIsPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
		_deviceIsRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))?1:0;
		
		//	load the atlas
		NSBundle *bundle = [NSBundle mainBundle];
		NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithBool:YES],
								  GLKTextureLoaderOriginBottomLeft,
								  nil];
		
		if(_deviceIsPad){
			if(_deviceIsRetina)
				_mainTextureAtlas = [[FSTextureAtlas alloc] initWithPath:[bundle pathForResource:@"Texture_atlas_2048" ofType:@"png"] loadOption:options];
			else
				_mainTextureAtlas = [[FSTextureAtlas alloc] initWithPath:[bundle pathForResource:@"Texture_atlas_1024" ofType:@"png"] loadOption:options];
		}else{
			if(_deviceIsRetina)
				_mainTextureAtlas = [[FSTextureAtlas alloc] initWithPath:[bundle pathForResource:@"Texture_atlas_1024" ofType:@"png"] loadOption:options];
			else
				_mainTextureAtlas = [[FSTextureAtlas alloc] initWithPath:[bundle pathForResource:@"Texture_atlas_512" ofType:@"png"] loadOption:options];
		}
		
		[self initTextures];
	}
	
	return self;
}

-(void)initTextures
{
	_background = [[FSTexture alloc] initWithBottomLeft:CGPointMake(4.0 / 3088.0, 4.0 / 3088.0)
											andTopRight:CGPointMake( (4.0 + 2048.0) / 3088.0, (4.0 + 1536.0) / 3088.0)
												inAtlas:_mainTextureAtlas];
	_stone = [[FSTexture alloc] initWithBottomLeft:CGPointMake(4.0 / 3088.0, 1548.0 / 3088.0)
											andTopRight:CGPointMake( (4.0 + 2048.0) / 3088.0, (1548.0 + 1536.0) / 3088.0)
												inAtlas:_mainTextureAtlas];
	_gridSquare = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 4.0 / 3088.0)
											andTopRight:CGPointMake( (2060.0 + 512.0) / 3088.0, (4.0 + 512.0) / 3088.0)
												inAtlas:_mainTextureAtlas];
	_shadow = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 524.0 / 3088.0)
											andTopRight:CGPointMake( (2060.0 + 512.0) / 3088.0, (524.0 + 512.0) / 3088.0)
												inAtlas:_mainTextureAtlas];
	_stoneOverlayLowLeft2 = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1044.0 / 3088.0)
										andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1044.0 + 128.0) / 3088.0)
											inAtlas:_mainTextureAtlas];
	_stoneOverlayLowLeft = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1180.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1180.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayLowMid = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1316.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1316.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayLowRight2 = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1452.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1452.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayLowRight = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1588.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1588.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayMidLeft = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1724.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1724.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayMidRight = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1860.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1860.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayTopLeft2 = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1996.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (1996.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayTopLeft = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 2132.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (2132.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayTopMid = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 2268.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (2268.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayTopRight2 = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 2404.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (2404.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_stoneOverlayTopRight = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 2540.0 / 3088.0)
													  andTopRight:CGPointMake( (2060.0 + 128.0) / 3088.0, (2540.0 + 128.0) / 3088.0)
														  inAtlas:_mainTextureAtlas];
	_highlight = [[FSTexture alloc] initWithBottomLeft:CGPointMake(2060.0 / 3088.0, 1724.0 / 3088.0)
										   andTopRight:CGPointMake( (2060.0 + 28.0) / 3088.0, (1724.0 + 28.0) / 3088.0)
											   inAtlas:_mainTextureAtlas];

}



#pragma mark - Singleton stuff


static TFTextureLoader* _sharedLoader;

+(TFTextureLoader*)sharedLoader
{
	if(_sharedLoader == nil){
		_sharedLoader = [[super allocWithZone:NULL] init];
	}
	
	return _sharedLoader;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedLoader] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end

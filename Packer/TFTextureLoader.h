//
//  TFTextureLoader.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 22.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTextures.h"

@interface TFTextureLoader : NSObject

+(TFTextureLoader*)sharedLoader;

@property(readonly, assign) BOOL deviceIsPad;
@property(readonly, assign) BOOL deviceIsRetina;

@property(readonly, retain) FSTextureAtlas* mainTextureAtlas;

@property(readonly, retain) FSTexture* background;
@property(readonly, retain) FSTexture* stone;
@property(readonly, retain) FSTexture* gridSquare;
@property(readonly, retain) FSTexture* shadow;

@property(readonly, retain) FSTexture
	*stoneOverlayLowLeft,
	*stoneOverlayLowLeft2,
	*stoneOverlayLowMid,
	*stoneOverlayLowRight,
	*stoneOverlayLowRight2,
	*stoneOverlayMidLeft,
	*stoneOverlayMidRight,
	*stoneOverlayTopLeft,
	*stoneOverlayTopLeft2,
	*stoneOverlayTopMid,
	*stoneOverlayTopRight,
	*stoneOverlayTopRight2;

@property(readonly, retain) FSTexture *highlight;

@end

//
//  FSTextureAtlas.h
//  GLTextureRenderingTest
//
//  Created by Florijan Stamenkovic on 2012 08 18.
//  Copyright (c) 2012 Florijan Stamenkovic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>




#pragma mark - FSTextureAtlas interface

@class FSTexture;

//	A texture atlas backed by an actual texture.
@interface FSTextureAtlas : NSObject

//	Dimensions of the texture, in pixels.
@property(readonly, assign) GLint width, height;

//	Initializes the atlas with the texture found in the file at |path|,
//	using default load options (|GLKTextureLoaderBottomLeft| = YES|).
-(id)initWithPath:(NSString*)path;

//	Initializes the atlas with the texture found in the file at |path|,
//	with |options|.
-(id)initWithPath:(NSString*)path loadOption:(NSDictionary*)loadOptions;

//	Returns a new texture that is a cutout from the atlas,
//	the cutout defined by |rect|. |rect| should be defined
//	in pixels.
-(FSTexture*)textureWithRect:(CGRect)rect;

@end




#pragma mark - FSTexture interface

//	A texture that is a part of a |FSTextureAtlas|, and does
//	not contain pixel information, but which part of the
//	atlas it represents.
@interface FSTexture : NSObject

//	The frame this |FSTexture| occupies in it's atlas;
@property CGRect frameInAtlas;

//	Initializes an |FSTexture| that represents |rect| part (in pixels)
//	of |textAtlas|.
-(id)initWithFrame:(CGRect)rect inAtlas:(FSTextureAtlas*)textAtlas;

//	Initializes an |FSTexture| that represents a part of |textAtlas|,
//	defined by bottom left and top right points of the texture, relative
//	to |textAtlas| (arguments should be in the [0.0 1.0] range).
-(id)initWithBottomLeft:(CGPoint)bottomLeft andTopRight:(CGPoint)topRight inAtlas:(FSTextureAtlas *)textAtlas;

@end




#pragma mark - FSTextureRenderStack interface

//	A stack of texture rendering orders for a single |FSTextureAtlas|.
//	|FSTexture|s are pushed on the stack, which results in the stack
//	calculating which atlas parts (textures) should be rendered where
//	(|rect| param of |pushTexture...| method). Once all the required
//	rendering orders are made, actual OpenGL rendering can be invoked
//	using the |render...| method.
@interface FSTextureRenderStack : NSObject

@property(readonly, retain) FSTextureAtlas* atlas;

//	Initializes the stack for rendering |FSTextures| that are part of
//	the |atlas| with a starting texture rendering capacity
//	(memory for caching render coordinates). Once the capacity is exceeded
//	(using the |pushTexture..| method), it is automatically expanded.
-(id)initWithAtlas:(FSTextureAtlas*)textAtlas andCapacity:(NSUInteger)initCapacity;

//	Pushes a texture render order onto the stack, so it can be
//	batch rendered with other textures of the same |FSTextureAtlas|.
//	|texture| is automatically scaled to fill |rect|.
-(void)pushTexture:(FSTexture*)texture inRect:(CGRect)rect;

//	Pushes a texture render order onto the stack, so it can be
//	batch rendered with other textures of the same |FSTextureAtlas|.
//	|texture| is rotated for |piHalves| and automatically scaled to fill |rect|
//	(rendering |rect| is NOT rotated).
-(void)pushTexture:(FSTexture*)texture inRect:(CGRect)rect withRotation:(NSUInteger)piHalves;

//	Pushes a texture render order onto the stack, so it can be
//	batch rendered with other textures of the same |FSTextureAtlas|.
//	|texture| is first clipped so that only |part| of it is rendered. Then
//	the clip is rotated for |piHalves| and automatically scaled to fill |rect|
//	(rendering |rect| is NOT rotated).
-(void)pushPart:(CGRect)part ofTexture:(FSTexture*)texture inRect:(CGRect)rect withRotation:(NSUInteger)piHalves;

//	Renders all the cached |FSTexture|s to |effect|. 
-(void)renderToEffect:(GLKBaseEffect*)effect;

//	Clears the stack and reduces the capacity to the initial one.
-(void)clear;

@end
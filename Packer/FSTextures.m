//
//  FSTextureAtlas.m
//  GLTextureRenderingTest
//
//  Created by Florijan Stamenkovic on 2012 08 18.
//  Copyright (c) 2012 Florijan Stamenkovic. All rights reserved.
//

#import "FSTextures.h"



#pragma mark - FSTextureAtlas implementation

//	Private interface of |FSTextureAtlas|
@interface FSTextureAtlas ()
{
	GLKTextureInfo *textureInfo;
}

-(void)bindToEffect:(GLKBaseEffect*)effect;

@end

//	|FSTextureAtlas| implementation
@implementation FSTextureAtlas


-(GLint)width
{
	return textureInfo.width;
}

-(GLint)height
{
	return textureInfo.height;
}

-(id)initWithPath:(NSString*)path
{
	return [self initWithPath:path loadOption:nil];
}

-(id)initWithPath:(NSString*)path loadOption:(NSDictionary*)loadOptions
{
	if(self = [super init])
	{
		NSError * error;
		textureInfo = [[GLKTextureLoader textureWithContentsOfFile:path options:loadOptions error:&error] retain];
		if (textureInfo == nil) {
			NSLog(@"Error loading file: %@", [error localizedDescription]);
			return nil;
		}
	}
	
	return self;
}

-(FSTexture*)textureWithRect:(CGRect)rect
{
	return [[[FSTexture alloc] initWithFrame:rect inAtlas:self] autorelease];
}

-(void)bindToEffect:(GLKBaseEffect *)effect
{
	effect.texture2d0.envMode = GLKTextureEnvModeReplace;
	effect.texture2d0.target = GLKTextureTarget2D;
	effect.texture2d0.name = textureInfo.name;
	effect.texture2d0.enabled = YES;
}

-(void)dealloc
{
	[textureInfo release];
	[super dealloc];
}

@end




#pragma mark - FSTexture implementation

//	Private interface of |FSTexture|
@interface FSTexture ()
{
	// texture location in the atlas, relative, range is [0.0, 1.0]
	GLfloat bottomLeftX, bottomLeftY, topRightX, topRightY;
	
	// the atlas!
	FSTextureAtlas* atlas;
}

-(GLfloat)bottomLeftX;
-(GLfloat)bottomLeftY;
-(GLfloat)topRightX;
-(GLfloat)topRightY;

@end

@implementation FSTexture

@synthesize frameInAtlas = _frameInAtlas;

-(id)initWithFrame:(CGRect)rect inAtlas:(FSTextureAtlas*)textAtlas{
	
	if(self = [super init]){
		
		atlas = [textAtlas retain];
		bottomLeftX = rect.origin.x / textAtlas.width;
		bottomLeftY = rect.origin.y / textAtlas.height;
		topRightX = (rect.origin.x + rect.size.width) / textAtlas.width;
		topRightY = (rect.origin.y + rect.size.height) / textAtlas.height;
		
		_frameInAtlas = rect;
	}
	
	return self;
}

-(id)initWithBottomLeft:(CGPoint)bottomLeft andTopRight:(CGPoint)topRight inAtlas:(FSTextureAtlas *)textAtlas
{
	if(self = [super init]){
		
		atlas = [textAtlas retain];
		bottomLeftX = bottomLeft.x;
		bottomLeftY = bottomLeft.y;
		topRightX = topRight.x;
		topRightY = topRight.y;
		
		_frameInAtlas.size.width = (topRightX - bottomLeftX)*textAtlas.width;
		_frameInAtlas.size.height = (topRightY - bottomLeftY)*textAtlas.height;
		_frameInAtlas.origin.x = bottomLeftX*textAtlas.width;
		_frameInAtlas.origin.y = bottomLeftY*textAtlas.height;
	}
	
	return self;
}

-(FSTextureAtlas*)atlas
{
	return atlas;
}

-(GLfloat)bottomLeftX { return bottomLeftX; }
-(GLfloat)bottomLeftY { return bottomLeftY; }
-(GLfloat)topRightX { return topRightX; }
-(GLfloat)topRightY { return topRightY; }

-(NSString*)description
{
	return [NSString stringWithFormat:@"FSTexture with points (%f, %f) and (%f, %f)", bottomLeftX, bottomLeftY, topRightX, topRightY];
}

-(void)dealloc
{
	[atlas release];
	[super dealloc];
}

@end




#pragma mark - FSTextureRenderStack implementation

typedef struct {
	GLfloat x;
	GLfloat y;
} GLPoint;

//	Private interface to |FSTextureRenderStack|
@interface FSTextureRenderStack ()
{
	FSTextureAtlas* atlas;
	
	//	positions in texture atlas that should be rendered
	GLPoint *textVertices;
	
	//	coordnates in which textures should be rendered
	GLPoint *geomVertices;
	
	//	the number of textures that can be pushed before more
	//	memory has to be allocated for the vertices
	NSUInteger pushCapacity;
	
	//	remembering the initial capacity so we could revert to it
	NSUInteger initialCapacity;
	
	//	the number of textures that have been pushed
	NSUInteger pushCount;
}

@end

@implementation FSTextureRenderStack

-(FSTextureAtlas*)atlas
{
	return atlas;
}

-(id)initWithAtlas:(FSTextureAtlas*)textAtlas andCapacity:(NSUInteger)initCapacity
{
	if(self = [super init])
	{
		atlas = [textAtlas retain];
		pushCapacity = initCapacity;
		initialCapacity = initCapacity;
		pushCount = 0;
		
		geomVertices = malloc(pushCapacity * 6 * sizeof(GLPoint));
		textVertices = malloc(pushCapacity * 6 * sizeof(GLPoint));
	}
	
	return self;
}

-(void)pushTexture:(FSTexture*)texture inRect:(CGRect)rect
{
	[self pushTexture:texture inRect:rect withRotation:0];
}

-(void)pushTexture:(FSTexture*)texture inRect:(CGRect)rect withRotation:(NSUInteger)piHalves
{
	//	check that stack atlas and texture atlas are indeed the same atlas
	if (texture.atlas != self.atlas) {
		NSException *e = [NSException exceptionWithName:@"Wrong FSTextureAtlas"
												 reason:@"When pushing texture the stack and texture atlases must be the same object" userInfo:nil];
		@throw e;
	}
	
	//	ensure there is enough memory for the vertices
	if(pushCount == pushCapacity)
	{
		pushCapacity += initialCapacity;
		geomVertices = realloc(geomVertices, pushCapacity * 6 * sizeof(GLPoint));
		textVertices = realloc(textVertices, pushCapacity * 6 * sizeof(GLPoint));
	}
	
	//	texture coordinates are different if rotation should be done
	piHalves = piHalves % 4;
	switch (piHalves) {
		
		case 0:
			textVertices[pushCount * 6].x = [texture bottomLeftX];
			textVertices[pushCount * 6].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 1] = textVertices[pushCount * 6];
			textVertices[pushCount * 6 + 2].x = [texture topRightX];
			textVertices[pushCount * 6 + 2].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 3].x = [texture bottomLeftX];
			textVertices[pushCount * 6 + 3].y = [texture topRightY];
			textVertices[pushCount * 6 + 4].x = [texture topRightX];
			textVertices[pushCount * 6 + 4].y = [texture topRightY];
			textVertices[pushCount * 6 + 5] = textVertices[pushCount * 6 + 4];
			break;
		
		case 1:
			textVertices[pushCount * 6].x = [texture bottomLeftX];
			textVertices[pushCount * 6].y = [texture topRightY];
			textVertices[pushCount * 6 + 1] = textVertices[pushCount * 6];
			textVertices[pushCount * 6 + 2].x = [texture bottomLeftX];
			textVertices[pushCount * 6 + 2].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 3].x = [texture topRightX];
			textVertices[pushCount * 6 + 3].y = [texture topRightY];
			textVertices[pushCount * 6 + 4].x = [texture topRightX];
			textVertices[pushCount * 6 + 4].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 5] = textVertices[pushCount * 6 + 4];
			break;
		
		case 2:
			textVertices[pushCount * 6].x = [texture topRightX];
			textVertices[pushCount * 6].y = [texture topRightY];
			textVertices[pushCount * 6 + 1] = textVertices[pushCount * 6];
			textVertices[pushCount * 6 + 2].x = [texture bottomLeftX];
			textVertices[pushCount * 6 + 2].y = [texture topRightY];
			textVertices[pushCount * 6 + 3].x = [texture topRightX];
			textVertices[pushCount * 6 + 3].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 4].x = [texture bottomLeftX];
			textVertices[pushCount * 6 + 4].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 5] = textVertices[pushCount * 6 + 4];
			break;
		
		case 3:
			textVertices[pushCount * 6].x = [texture topRightX];
			textVertices[pushCount * 6].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 1] = textVertices[pushCount * 6];
			textVertices[pushCount * 6 + 2].x = [texture topRightX];
			textVertices[pushCount * 6 + 2].y = [texture topRightY];
			textVertices[pushCount * 6 + 3].x = [texture bottomLeftX];
			textVertices[pushCount * 6 + 3].y = [texture bottomLeftY];
			textVertices[pushCount * 6 + 4].x = [texture bottomLeftX];
			textVertices[pushCount * 6 + 4].y = [texture topRightY];
			textVertices[pushCount * 6 + 5] = textVertices[pushCount * 6 + 4];
			break;
			
		default:
			break;
	}
	
	//	create geometry vertices for the rendering
	geomVertices[pushCount * 6].x = rect.origin.x;
	geomVertices[pushCount * 6].y = rect.origin.y;
	geomVertices[pushCount * 6 + 1].x = rect.origin.x;
	geomVertices[pushCount * 6 + 1].y = rect.origin.y;
	geomVertices[pushCount * 6 + 2].x = rect.origin.x + rect.size.width;
	geomVertices[pushCount * 6 + 2].y = rect.origin.y;
	geomVertices[pushCount * 6 + 3].x = rect.origin.x;
	geomVertices[pushCount * 6 + 3].y = rect.origin.y + rect.size.height;
	geomVertices[pushCount * 6 + 4].x = rect.origin.x + rect.size.width;
	geomVertices[pushCount * 6 + 4].y = rect.origin.y + rect.size.height;
	geomVertices[pushCount * 6 + 5].x = rect.origin.x + rect.size.width;
	geomVertices[pushCount * 6 + 5].y = rect.origin.y + rect.size.height;
	
	//	increase push count
	pushCount++;
}

-(void)pushPart:(CGRect)part ofTexture:(FSTexture*)texture inRect:(CGRect)rect withRotation:(NSUInteger)piHalves
{
	//	the easiest way to do this is to first create another |FSTexture|
	//	that represents |part|, push it to the render stack
	//	and immediatly release
	//	it adds some overhead, but it should be acceptable
	part.origin.x += texture.frameInAtlas.origin.x;
	part.origin.y += texture.frameInAtlas.origin.y;
	FSTexture *tempTexture = [[FSTexture alloc] initWithFrame:part inAtlas:texture.atlas];
	[self pushTexture:tempTexture inRect:rect withRotation:piHalves];
	[tempTexture release];
}


-(void)renderToEffect:(GLKBaseEffect*)effect
{
	[atlas bindToEffect:effect];
	[effect prepareToDraw];
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, (void *) (geomVertices));
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, (void *) (textVertices));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 6*pushCount);
}

-(void)clear
{
	pushCount = 0;
}

-(void)dealloc
{
	[atlas release];
	free(textVertices);
	free(geomVertices);
	[super dealloc];
}

@end





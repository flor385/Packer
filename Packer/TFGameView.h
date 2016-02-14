//
//  TFGameView.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 22.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "TFCGExtras.h"
@class TFGrid;
@class TFStoneOnGrid;

//	OpenGL view that visually presents it's |grid| property.
@interface TFGameView : GLKView

@property(retain, nonatomic) TFGrid* grid;

-(id)initWithFrame:(CGRect)frame context:(EAGLContext *)context grid:(TFGrid*)grid;

-(void)orientationDidChange;
-(CGPointInt)gridPositionForViewPoint:(CGPoint)point;
-(CGPointInt)gridOffsetForViewPoint:(CGPoint)point;
-(int)gridRotation;

-(void)setStone:(TFStoneOnGrid*)stone isHighlighted:(BOOL)isHighlighted;

@end

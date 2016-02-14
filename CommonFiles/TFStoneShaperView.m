//
//  TFStoneShaperView.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 6.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFStoneShaperView.h"
#import "TFStone.h"
#import "TFStonesWindowController.h"
#import "TFPosition.h"

#define SQUARE_SIZE 50.0
#define SQUARE_INSET 1.0
#define SQUARE_BORDER 10.0
#define DOT_SIZE 2.0

@interface TFStoneShaperView ()
{
	TFStone* _stone;
}
@end



@implementation TFStoneShaperView


@synthesize stonesController = _stonesController;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _stone = nil;
    }
    
    return self;
}

-(NSInteger)originX
{
	return ((NSInteger)(self.bounds.size.width / SQUARE_SIZE)) / 2;
}

-(NSInteger)originY
{
	return ((NSInteger)(self.bounds.size.height / SQUARE_SIZE)) / 2;
}


#pragma mark - The TFStone being edited

-(void)setStone:(TFStone*)stone
{
	[stone retain];
	[_stone release];
	_stone = stone;
	
	[self setNeedsDisplay:YES];
	
}

-(TFStone*)stone
{
	return _stone;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
	[NSBezierPath fillRect:dirtyRect];
	
	NSRect bounds = [self bounds];	
	
	//	draw positioning squares
	[[NSColor lightGrayColor] set];
	for(CGFloat i = 0 ; i < bounds.size.width + 2*SQUARE_SIZE ; i += SQUARE_SIZE)
		for(CGFloat j = 0 ; j < bounds.size.height + 2*SQUARE_SIZE ; j += SQUARE_SIZE){
			NSRect dot;
			dot.size.width = DOT_SIZE;
			dot.size.height = DOT_SIZE;
			dot.origin.x = i - DOT_SIZE / 2;
			dot.origin.y = j - DOT_SIZE / 2;
			
			[NSBezierPath fillRect:dot];
	}
	
	//	draw the actual stones
	NSInteger originX = [self originX];
	NSInteger originY = [self originY];
	
	CGFloat outSize = SQUARE_SIZE - 2*SQUARE_INSET;
	CGFloat inSize = SQUARE_SIZE - 2*SQUARE_INSET - 2*SQUARE_BORDER;
	
	//	draw the first stone
	NSRect r = NSMakeRect(originX * SQUARE_SIZE + SQUARE_INSET, originY * SQUARE_SIZE + SQUARE_INSET, outSize, outSize);
	
	if(self.stone == nil)
		[[NSColor lightGrayColor] set];
	else
		[[NSColor blackColor] set];
	
	[NSBezierPath fillRect:r];
	
	r = NSMakeRect(originX * SQUARE_SIZE + SQUARE_INSET + SQUARE_BORDER, originY * SQUARE_SIZE + SQUARE_INSET + SQUARE_BORDER, 
				   inSize, inSize);
	
	if(self.stone == nil)
		[[NSColor whiteColor] set];
	else
		[[NSColor orangeColor] set];
	
	[NSBezierPath fillRect:r];
	
	//	draw other stones
	for(TFPosition *square in self.stone.squares){
		
		NSInteger x = originX + square.x;
		NSInteger y = originY + square.y;
		
		r = NSMakeRect(x * SQUARE_SIZE + SQUARE_INSET, y * SQUARE_SIZE + SQUARE_INSET, outSize, outSize);
		[[NSColor blackColor] set];
		[NSBezierPath fillRect:r];
		
		r = NSMakeRect(x * SQUARE_SIZE + SQUARE_INSET + SQUARE_BORDER, y * SQUARE_SIZE + SQUARE_INSET + SQUARE_BORDER, inSize, inSize);
		[[NSColor grayColor] set];
		[NSBezierPath fillRect:r];
	}
	
	
	//	draw border round the bounds
	[[NSColor grayColor] set];
	[NSBezierPath setDefaultLineWidth:1.0];
	NSPoint lowerLeft = NSMakePoint(bounds.origin.x + 0.5, bounds.origin.y + 0.5);
	NSPoint upperRight = NSMakePoint(bounds.origin.x + bounds.size.width - 0.5, bounds.origin.y + bounds.size.height - 0.5);
	[NSBezierPath strokeLineFromPoint:lowerLeft toPoint:NSMakePoint(lowerLeft.x, upperRight.y)];
	[NSBezierPath strokeLineFromPoint:lowerLeft toPoint:NSMakePoint(upperRight.x, lowerLeft.y)];
	[NSBezierPath strokeLineFromPoint:upperRight toPoint:NSMakePoint(lowerLeft.x, upperRight.y)];
	[NSBezierPath strokeLineFromPoint:upperRight toPoint:NSMakePoint(upperRight.x, lowerLeft.y)];
}


#pragma mark - Responding to user input

-(void)flipStoneAtX:(NSInteger)x andY:(NSInteger)y
{
	if(self.stone == nil)
		return;
	
	x -= [self originX];
	y -= [self originY];
	
	//	we can't flip the origin stone
	if(x == 0 && y == 0)
		return;
	
	if([self.stone hasSquareAtX:x andY:y])
		[self.stonesController removeSquareFromSelectedStoneAtX:x andY:y];
	else
		[self.stonesController addSquareToSelectedStoneAtX:x andY:y];
}

-(void)mouseEvent:(NSEvent*)event atX:(NSInteger*)x andY:(NSInteger*)y
{
	NSPoint localMouse = [self convertPoint:[event locationInWindow] fromView:nil];
	
	*x = (NSInteger)(localMouse.x / SQUARE_SIZE);
	*y = (NSInteger)(localMouse.y / SQUARE_SIZE);
	
}

NSInteger mouseDownX;
NSInteger mouseDownY;

-(void)mouseDown:(NSEvent *)theEvent
{
	[self mouseEvent:theEvent atX:&mouseDownX andY:&mouseDownY];
	[self flipStoneAtX:(NSInteger)mouseDownX andY:(NSInteger)mouseDownY];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	//	is the cursor still in view?
	NSPoint localMouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if(!NSPointInRect(localMouse, [self bounds]))
	   return;
	
	NSInteger x,y;
	[self mouseEvent:theEvent atX:&x andY:&y];
	
	//	check if we should flip the square
	NSInteger originX = [self originX], originY = [self originY];
	if([self.stone hasSquareAtX:x - originX andY:y - originY] == [self.stone hasSquareAtX:mouseDownX - originX andY:mouseDownY - originY])
		return;
	else
		[self flipStoneAtX:x andY:y];
}


@end

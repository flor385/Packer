//
//  TFGridView.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 17.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGridView.h"
#import "TFGrid.h"
#import "TFStoneOnGrid.h"
#import "TFStone.h"
#import "TFPosition.h"

#define BORDER_WIDTH_PERCENTAGE 20.0
#define CENTER_DOT_DIAMETER_PERCENTAGE 20.0

@interface TFGrid (Mutable)

-(void)setRequiredPositionAtX:(NSInteger)x andY:(NSInteger)y;

@end

@implementation TFGrid (Mutable)

-(void)setRequiredPositionAtX:(NSInteger)x andY:(NSInteger)y
{
	
}

@end

@interface TFGridView ()
{
	TFGrid *_grid;
}
@end


@implementation TFGridView

@synthesize addStoneDataSource = _addStoneDataSource, gridViewDelegate = _gridViewDelegate;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_addStoneDataSource = nil;
		_gridViewDelegate = nil;
    }
    
    return self;
}

-(void)setGrid:(TFGrid *)grid
{
	if(grid == _grid) return;
	
	[grid retain];
	[_grid release];
	_grid = grid;
	
	[self redrawGrid];
}

-(TFGrid*)grid
{
	return _grid;
}

#pragma mark - Drawing grid

-(void)redrawGrid
{
	[self setNeedsDisplay:YES];
}

-(BOOL)_stone:(TFStone*)stone hasSquareAtX:(NSInteger)x andY:(NSInteger)y
{
	if(x == 0 && y == 0) return YES;
	
	for(TFPosition* pos in stone.squares)
		if(pos.x == x && pos.y == y)
			return YES;
	return NO;
}

-(void)drawStone:(TFStone*)stone
		  atPosX:(NSInteger)posX 
		 andPosY:(NSInteger)posY
		withOffX:(NSInteger)offX
		 andOffY:(NSInteger)offY
   withFillColor:(NSColor*)fillColor 
  andBorderColor:(NSColor*)borderColor
{
	//	determine square size
	NSRect bounds = [self bounds];
	CGFloat squareSize = fmin(bounds.size.width / _grid.width, bounds.size.height / _grid.height);
	
	//	determine grid origin
	NSPoint origin = NSMakePoint((bounds.size.width - squareSize * _grid.width) / 2, 
								 (bounds.size.height - squareSize * _grid.height) / 2);
	
	//	now draw!
	for(int i = -1 ; i < (NSInteger)(stone.squares.count) ; i++){
		
		NSInteger squareX = i == -1 ? 0 : ((TFPosition*)[stone.squares objectAtIndex:i]).x;
		NSInteger squareY = i == -1 ? 0 : ((TFPosition*)[stone.squares objectAtIndex:i]).y;
		NSInteger x = i == -1 ? posX : posX + squareX;
		NSInteger y = i == -1 ? posY : posY + squareY;
		
		NSRect square = NSMakeRect(origin.x + x * squareSize + offX * squareSize / TF_PACKER_STONE_OFFSET_MAX, origin.y + y *squareSize + offY* squareSize / TF_PACKER_STONE_OFFSET_MAX, squareSize, squareSize);
		[fillColor set];
		[NSBezierPath fillRect:square];
		
		[borderColor set];
		if(i == -1){
			CGFloat centerDiameter = squareSize / 100.0 * CENTER_DOT_DIAMETER_PERCENTAGE;
			NSRect centerRect = NSMakeRect(square.origin.x + (squareSize - centerDiameter)/2.0, 
										   square.origin.y + (squareSize - centerDiameter)/2.0, centerDiameter, centerDiameter);
			NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:centerRect];
			[circle fill];
		}
		
		CGFloat border = squareSize / 100.0 * BORDER_WIDTH_PERCENTAGE;
		
		//	first draw the four squares
		NSRect corner = NSMakeRect(square.origin.x, square.origin.y, border, border);
		[NSBezierPath fillRect:corner];
		corner = NSMakeRect(square.origin.x + squareSize - border, square.origin.y, border, border);
		[NSBezierPath fillRect:corner];
		corner = NSMakeRect(square.origin.x, square.origin.y + squareSize - border, border, border);
		[NSBezierPath fillRect:corner];
		corner = NSMakeRect(square.origin.x  + squareSize - border, square.origin.y + squareSize - border, border, border);
		[NSBezierPath fillRect:corner];
		
		//	now draw the lines
		NSRect line;
		if(![self _stone:stone hasSquareAtX:squareX + 1 andY:squareY]){
			line = NSMakeRect(square.origin.x + squareSize - border, square.origin.y, border, squareSize);
			[NSBezierPath fillRect:line];
		}
		if(![self _stone:stone hasSquareAtX:squareX - 1 andY:squareY]){
			line = NSMakeRect(square.origin.x, square.origin.y, border, squareSize);
			[NSBezierPath fillRect:line];
		}
		if(![self _stone:stone hasSquareAtX:squareX andY:squareY + 1]){
			line = NSMakeRect(square.origin.x, square.origin.y + squareSize - border, squareSize, border);
			[NSBezierPath fillRect:line];
		}
		if(![self _stone:stone hasSquareAtX:squareX andY:squareY - 1]){
			line = NSMakeRect(square.origin.x, square.origin.y, squareSize, border);
			[NSBezierPath fillRect:line];
		}
		
	}
}

NSColor *addStoneYesGridColor = nil;
NSColor *addStoneYesFillColor = nil;
NSColor *addStoneNoGridColor = nil;
NSColor *addStoneNoFillColor = nil;
NSColor *fixedStoneFillColor = nil;
NSColor *fixedStoneBorderColor = nil;
NSColor *stoneFillColor = nil;
NSColor *stoneBorderColor = nil;

- (void)drawRect:(NSRect)dirtyRect
{
	if(addStoneYesFillColor == nil){
		addStoneYesGridColor = [[[NSColor blueColor] colorWithAlphaComponent:0.25] retain];
		addStoneYesFillColor = [[[NSColor cyanColor] colorWithAlphaComponent:0.25] retain];
		addStoneNoGridColor = [[[NSColor redColor] colorWithAlphaComponent:0.25] retain];
		addStoneNoFillColor = [[[NSColor orangeColor] colorWithAlphaComponent:0.25] retain];
		
		fixedStoneFillColor = [[NSColor grayColor] retain];
		fixedStoneBorderColor = [[NSColor grayColor] retain];
		stoneFillColor = [[NSColor whiteColor] retain];
		stoneBorderColor = [[NSColor blackColor] retain];
	}
	
	if(_grid == nil)
		return;
	
    //	determine square size
	NSRect bounds = [self bounds];
	CGFloat squareSize = fmin(bounds.size.width / _grid.width, bounds.size.height / _grid.height);
	
	//	determine grid origin
	NSPoint origin = NSMakePoint((bounds.size.width - squareSize * _grid.width) / 2, 
								 (bounds.size.height - squareSize * _grid.height) / 2);
	NSRect gridRect = NSMakeRect(origin.x, origin.y, squareSize * _grid.width, squareSize * _grid.height);
	
	//	draw background
	[[NSColor lightGrayColor] set];
	[NSBezierPath fillRect:gridRect];
	
	//	draw grid lines
	[[NSColor grayColor] set];
	[NSBezierPath setDefaultLineWidth:1.0];
	for(int i = 1 ; i < _grid.width ; i++)
		[NSBezierPath strokeLineFromPoint:NSMakePoint(origin.x + i * squareSize, origin.y) toPoint:NSMakePoint(origin.x + i * squareSize, origin.y + gridRect.size.height)];
	for(int i = 1 ; i < _grid.height ; i++)
		[NSBezierPath strokeLineFromPoint:NSMakePoint(origin.x, origin.y + i * squareSize) toPoint:NSMakePoint(origin.x + gridRect.size.width, origin.y + i * squareSize)];
	
	//	draw fixed stones
	NSArray* fixedStones = self.grid.fixedStones;
	for(TFStoneOnGrid* stone in fixedStones)
		[self drawStone:stone.stone atPosX:stone.posX andPosY:stone.posY withOffX:stone.offX andOffY:stone.offY withFillColor:fixedStoneFillColor andBorderColor:fixedStoneBorderColor];
	
	//	draw moving stones
	NSArray* stones = self.grid.stones;
	for(TFStoneOnGrid* stone in stones)
		[self drawStone:stone.stone atPosX:stone.posX andPosY:stone.posY withOffX:stone.offX andOffY:stone.offY withFillColor:stoneFillColor andBorderColor:stoneBorderColor];
	
	//	draw new stone to add
	TFStone* stoneToAdd = self.addStoneDataSource.stoneToAdd;
	NSInteger addPosX = self.addStoneDataSource.addPosX;
	NSInteger addPosY = self.addStoneDataSource.addPosY;
	if(stoneToAdd)
		if([_grid canPlaceStone:stoneToAdd atX:addPosX andY:addPosY])
		   [self drawStone:stoneToAdd atPosX:addPosX andPosY:addPosY withOffX:0 andOffY:0 withFillColor:addStoneYesFillColor andBorderColor:addStoneYesGridColor];
		else
			[self drawStone:stoneToAdd atPosX:addPosX andPosY:addPosY withOffX:0 andOffY:0 withFillColor:addStoneNoFillColor andBorderColor:addStoneNoGridColor];
	
	//	draw required positions
	[[NSColor greenColor] set];
	[NSBezierPath setDefaultLineWidth:1.0];
	for(TFPosition* pos in [_grid requiredPositions]){
		NSRect r = NSMakeRect(origin.x + squareSize * pos.x, origin.y + squareSize * pos.y, squareSize, squareSize);
		[NSBezierPath strokeRect:r];
		[NSBezierPath strokeLineFromPoint:r.origin toPoint:NSMakePoint(r.origin.x + squareSize, r.origin.y + squareSize)];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(r.origin.x + squareSize, r.origin.y) toPoint:NSMakePoint(r.origin.x, r.origin.y + squareSize)];
	}
	
	//	draw grid info flags
	for(int i = 0 ; i < _grid.width ; i++)
		for (int j = 0 ; j < _grid.height ; j++) {
			
			if([_grid isFixedStoneAtX:i andY:j])
				[@"F" drawAtPoint:NSMakePoint(origin.x + squareSize * i, origin.y + squareSize * j) withAttributes:nil];
		}
	
	//	draw bounds
	NSPoint lowerLeft = NSMakePoint(origin.x + 0.5, origin.y + 0.5);
	NSPoint upperRight = NSMakePoint(origin.x + squareSize * _grid.width - 0.5, 
								   origin.y + squareSize * _grid.height - 0.5);
	[[NSColor grayColor] set];
	[NSBezierPath setDefaultLineWidth:1.0];
	[NSBezierPath strokeLineFromPoint:lowerLeft toPoint:NSMakePoint(lowerLeft.x, upperRight.y)];
	[NSBezierPath strokeLineFromPoint:lowerLeft toPoint:NSMakePoint(upperRight.x, lowerLeft.y)];
	[NSBezierPath strokeLineFromPoint:upperRight toPoint:NSMakePoint(lowerLeft.x, upperRight.y)];
	[NSBezierPath strokeLineFromPoint:upperRight toPoint:NSMakePoint(upperRight.x, lowerLeft.y)];
}

#pragma mark - Responding to mouse events

-(TFPosition*)_positionForMouseEvent:(NSEvent*)event
{
	NSPoint pointInSelf = [self convertPoint:[event locationInWindow] fromView:nil];
	
	//	determine square size
	NSRect bounds = [self bounds];
	CGFloat squareSize = fmin(bounds.size.width / _grid.width, bounds.size.height / _grid.height);
	
	//	determine grid origin
	NSPoint origin = NSMakePoint((bounds.size.width - squareSize * _grid.width) / 2, 
								 (bounds.size.height - squareSize * _grid.height) / 2);
	
	
	
	return [TFPosition positionWithX:(NSInteger)((pointInSelf.x - origin.x) / squareSize) 
								andY:(NSInteger)((pointInSelf.y - origin.y) / squareSize)];
}

-(void)mouseDown:(NSEvent *)theEvent
{
	if([theEvent clickCount] == 1)
		[_gridViewDelegate clickedGridPosition:[self _positionForMouseEvent:theEvent]];
	else if([theEvent clickCount] == 2)
		[_gridViewDelegate doubleClickedGridPosition:[self _positionForMouseEvent:theEvent]];
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
	if([theEvent clickCount] == 1)
		[_gridViewDelegate rightClickedGridPosition:[self _positionForMouseEvent:theEvent]];
	else if([theEvent clickCount] == 2)
		[_gridViewDelegate rightDoubleClickedGridPosition:[self _positionForMouseEvent:theEvent]];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	[_gridViewDelegate draggedGridPosition:[self _positionForMouseEvent:theEvent]];
}

-(void)rightMouseDragged:(NSEvent *)theEvent
{
	[_gridViewDelegate rightDraggedGridPosition:[self _positionForMouseEvent:theEvent]];
}

#pragma mark -

-(void)dealloc
{
	self.grid = nil;
	[super dealloc];
}

@end

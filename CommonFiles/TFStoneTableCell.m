//
//  TFStoneTableCell.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 7.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFStoneTableCell.h"
#import "TFStone.h"
#import "TFPosition.h"

#define SQUARE_SIZE_TOTAL 12.0
#define SQUARE_SIZE_MARGIN 1.0
#define CELL_MARGIN 5.0
#define DEFAULT_STONE_HEIGHT 3.0


@implementation TFStoneTableCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	//	cocoa sometimes flips cartasius upside down...
	BOOL isFlipped = [controlView isFlipped];
	
	//	the stone we want to draw
	TFStone *stone = [self representedObject];
	if(stone == nil) return;
	
	//	now we can start generating rects and drawing them out
	//	first calculate some dimensions
	CGFloat square_size_total = stone.height > DEFAULT_STONE_HEIGHT ?
	((CGFloat)DEFAULT_STONE_HEIGHT * SQUARE_SIZE_TOTAL) / stone.height
	:	SQUARE_SIZE_TOTAL;
	CGFloat square_size_margin = square_size_total / SQUARE_SIZE_TOTAL * SQUARE_SIZE_MARGIN;
	CGFloat square_size = square_size_total - 2*square_size_margin;
	
	//	calculate y margin based on the cell height
	CGFloat yMargin = (cellFrame.size.height - stone.height * square_size_total) / 2;
	
	//	 calculate x margin
	CGFloat xMargin = (cellFrame.size.width - stone.width * square_size_total) / 2;
	
	//	determine the minY and minX among stone squares 
	NSInteger minX = 0;
	NSInteger minY = 0;
	for(TFPosition *square in stone.squares){
		
		if(minX > square.x) minX = square.x;
		if(minY > square.y) minY = square.y;
	}
	
	//	set the squares drawing color
	if([self isHighlighted])
		[[NSColor selectedMenuItemTextColor] set];
	else 
		[[NSColor textColor] set];
	
	//	now iterate over stone's squares and draw them
	//	start at -2 to draw the origin square of the stone
	NSArray *squares = stone.squares;
	for(int i = -1 ; i < (NSInteger)[squares count] ; i++){
		
		NSInteger x = i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).x;
		NSInteger y = i == -1 ? 0 : ((TFPosition*)[squares objectAtIndex:i]).y;
		
		//	we want x and y realtive to their min values, so that the
		//	lowest ones start at 0
		x -= minX;
		y -= minY;
		
		NSRect rect;
		rect.size.height = square_size;
		rect.size.width = square_size;
		
		rect.origin.x = cellFrame.origin.x + xMargin + x*square_size_total + square_size_margin;
		rect.origin.y = isFlipped ?
			cellFrame.origin.y + cellFrame.size.height - yMargin - (y + 1)*square_size_total - square_size_margin
		:	cellFrame.origin.y + yMargin + y*square_size_total + square_size_margin;
		
		[NSBezierPath fillRect:rect];
	}
	
}

@end

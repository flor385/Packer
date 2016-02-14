//
//  TFGridTabController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 17.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGridTabController.h"
#import "TFGrid.h"
#import "TFGridView.h"
#import "TFStone.h"
#import "TFStoneOnGrid.h"
#import "TFStonesTabController.h"
#import "TFStoneTableCell.h"
#import "TFPosition.h"

@implementation TFGridTabController

@synthesize grid = _grid, gridView = _gridView, stonesTabController = _stonesTabController;
@synthesize stonesTable = _stonesTable;
@synthesize gridHeight = _gridHeight, gridWidth = _gridWidth, newStonePosX = _newStonePosX, newStonePosY = _newStonePosY, newStoneFixed = _newStoneFixed;

-(id)init
{
	self = [super init];
	if(self){
		
		_gridWidth = 10;
		_gridHeight = 10;
		_newStonePosX = 0;
		_newStonePosY = 0;
		_newStoneFixed = YES;
		_grid = [[TFGrid alloc] initWithWidth:_gridWidth height:_gridHeight];
	}
	
	return self;
}

-(void)awakeFromNib
{
	_gridView.grid = _grid;
}

-(TFGrid*)gridForSaving
{
	return [[_grid copy] autorelease];
}

-(void)loadGrid:(TFGrid*)grid
{
	self.gridWidth = grid.width;
	self.gridHeight = grid.height;
	
	_grid = [grid copy];
	self.gridView.grid = _grid;
	[_stonesTable reloadData];
	[_gridView redrawGrid];
}

-(void)_recreateGrid
{
	
	TFGrid *newGrid = [[TFGrid alloc] initWithWidth:_gridWidth height:_gridHeight requiredPositions:[_grid requiredPositions]];
	
	//	add stones from the old grid to the new grid
	NSArray *stones = _grid.stones;
	for(TFStoneOnGrid* stone in stones)
		if([newGrid canPlaceStone:stone.stone atX:stone.posX andY:stone.posY])
			[newGrid addStone:stone.stone fixed:NO atX:stone.posX andY:stone.posY];
	NSArray *fixedStones = _grid.fixedStones;
	for(TFStoneOnGrid* stone in fixedStones)
		if([newGrid canPlaceStone:stone.stone atX:stone.posX andY:stone.posY])
			[newGrid addStone:stone.stone fixed:YES atX:stone.posX andY:stone.posY];
	
	//	make the switch
	[_grid release];
	_grid = newGrid;
	_gridView.grid = _grid;
}

-(void)setGridHeight:(NSInteger)gridHeight
{
	if(gridHeight == _gridHeight)
		return;
	
	_gridHeight = gridHeight;
	[self _recreateGrid];
}

-(void)setGridWidth:(NSInteger)gridWidth
{
	if(gridWidth == _gridWidth)
		return;
	
	_gridWidth = gridWidth;
	[self _recreateGrid];
}

-(void)reloadStones
{
	[_stonesTable reloadData];
	[_gridView redrawGrid];
}

-(IBAction)addStone:(id)sender
{
	//	get selected stone
	NSInteger selectedIndex = [_stonesTable selectedRow];
	if(selectedIndex == -1) return;
	
	TFStone* selectedStone = [_stonesTabController stoneAtIndex:selectedIndex];
	
	if([_grid canPlaceStone:selectedStone atX:_newStonePosX andY:_newStonePosY]){
		[_grid addStone:selectedStone fixed:_newStoneFixed atX:_newStonePosX andY:_newStonePosY];
		[_gridView redrawGrid];
	}
}

#pragma mark - Table data source and delegate protocol methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [_stonesTabController stoneCount];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [_stonesTabController stoneAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	
	[aCell setRepresentedObject:[_stonesTabController stoneAtIndex:rowIndex]];
	
}

TFStoneTableCell *stoneTableCell;

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if(stoneTableCell == nil)
		stoneTableCell = [[TFStoneTableCell alloc] init];
	
	return stoneTableCell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[_gridView redrawGrid];
}

#pragma mark - TFGridViewAddStoneDataSource implementation

-(void)setNewStonePosX:(NSInteger)newPosX
{
	_newStonePosX = newPosX;
	[_gridView redrawGrid];
}

-(void)setNewStonePosY:(NSInteger)newPosY
{
	_newStonePosY = newPosY;
	[_gridView redrawGrid];
}

-(TFStone*)stoneToAdd
{
	NSInteger selectedRow = [_stonesTable selectedRow];
	if(selectedRow == -1)
		return nil;
	
	return [_stonesTabController stoneAtIndex:selectedRow];
}

-(NSInteger)addPosX
{
	return _newStonePosX;
}

-(NSInteger)addPosY
{
	return _newStonePosY;
}

#pragma mark - Grid View Delegate implementation

-(void)clickedGridPosition:(TFPosition*)position
{
	//	option-clicking deletes the stones
	if([NSEvent modifierFlags] & NSAlternateKeyMask){
		
		TFStoneOnGrid *clickedStone = [_grid stoneCoveringX:position.x andY:position.y];
		if(clickedStone)
			[_grid removeStone:clickedStone];
	}
	
	self.newStonePosX = position.x;
	self.newStonePosY = position.y;
	
	[_gridView redrawGrid];

}
-(void)doubleClickedGridPosition:(TFPosition*)position
{
	self.newStonePosX = position.x;
	self.newStonePosY = position.y;
	
	[self addStone:self];
	
	[_gridView redrawGrid];

}
-(void)draggedGridPosition:(TFPosition*)position
{
	self.newStonePosX = position.x;
	self.newStonePosY = position.y;
	
	[_gridView redrawGrid];
}

BOOL rightMouseDownPositionIsRequired = NO;

-(void)rightClickedGridPosition:(TFPosition*)position
{
	rightMouseDownPositionIsRequired = ![_grid isRequiredPositionAtX:position.x andY:position.y];
	
	[_grid setRequired:rightMouseDownPositionIsRequired squareAtX:position.x andY:position.y];
	
	[_gridView redrawGrid];
}
-(void)rightDoubleClickedGridPosition:(TFPosition*)position{}

-(void)rightDraggedGridPosition:(TFPosition*)position{
	
	if([_grid isRequiredPositionAtX:position.x andY:position.y] != rightMouseDownPositionIsRequired){
		[_grid setRequired:rightMouseDownPositionIsRequired squareAtX:position.x andY:position.y];
		[_gridView redrawGrid];
	}
}

#pragma mark -

-(void)dealloc
{
	[stoneTableCell release];
	[_grid release];
	self.gridView = nil;
	[super dealloc];
}

@end

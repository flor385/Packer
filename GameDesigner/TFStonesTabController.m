//
//  TFStonesTabController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 16.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFStonesTabController.h"
#import "TFStoneTableCell.h"
#import "TFStone.h"
#import "TFStoneShaperView.h"
#import "TFGeneralTabController.h"
#import "TFGeneralTabController.h"

@implementation TFStonesTabController

@synthesize stonesTable = _stonesTable;
@synthesize stoneShaperView = _stoneShaperView;
@synthesize hasSelection = _hasSelection;
@synthesize generalTabController = _generalTabController;
@synthesize gridTabController = _gridTabController;

-(id)init
{
	if(self = [super init]){
		
		stones = [NSMutableArray new];
		return self;
	}
	
	return nil;
}

-(NSInteger)stoneCount
{
	return stones.count;
}

-(TFStone*)stoneAtIndex:(NSInteger)index
{
	return [stones objectAtIndex:index];
}

#pragma mark - Table data source and delegate protocol methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(aTableView == _stonesTable){
		return [stones count];
	}else
		return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [stones objectAtIndex:rowIndex];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger selectedRow = [_stonesTable selectedRow];
	self.hasSelection = selectedRow != -1;
	
	TFStone *selectedStone = selectedRow == -1 ? nil : [stones objectAtIndex:selectedRow];
	
	self.stoneShaperView.stone = selectedStone;
}

#pragma mark - Stone manipulation methods

- (IBAction)addAndSelectNew:(id)sender {
	[stones addObject:[[[TFStone alloc] init] autorelease]];
	[_stonesTable reloadData];
	[_generalTabController reloadStones];
	[_gridTabController reloadStones];
	[_stonesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:stones.count - 1] byExtendingSelection:NO];
}

- (IBAction)removeSelected:(id)sender {
	NSInteger selectedIndex = self.stonesTable.selectedRow;
	if(selectedIndex == -1)
		return;
	[stones removeObjectAtIndex:selectedIndex];
	[_stonesTable reloadData];
	[_generalTabController reloadStones];
	[_gridTabController reloadStones];
}

- (void)addSquareToSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y
{
	TFStone *selectedStone = self.stoneShaperView.stone;
	
	TFStone* newStone = [selectedStone stoneWithAddedSquareAtX:x andY:y];
	
	//	update the editor with the new stone
	self.stoneShaperView.stone = newStone;
	
	//	add the new stone to the list just below the currently selected
	NSUInteger index = self.stonesTable.selectedRow;
	[stones insertObject:newStone atIndex:index + 1];
	[stones removeObjectAtIndex:index];
	
	[self.stonesTable reloadData];
	[_generalTabController reloadStones];
	[_gridTabController reloadStones];
}

- (void)removeSquareFromSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y
{
	TFStone *selectedStone = self.stoneShaperView.stone;
	
	TFStone* newStone = [selectedStone stoneWithRemovedSquareFromX:x andY:y];
	
	//	update the editor with the new stone
	self.stoneShaperView.stone = newStone;
	
	//	add the new stone to the list just below the currently selected
	NSUInteger index = self.stonesTable.selectedRow;
	[stones insertObject:newStone atIndex:index + 1];
	[stones removeObjectAtIndex:index];
	
	[self.stonesTable reloadData];
	[_generalTabController reloadStones];
	[_gridTabController reloadStones];
}


#pragma mark - Table cell modifications

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	[aCell setRepresentedObject:[stones objectAtIndex:rowIndex]];
	
}

TFStoneTableCell *stoneTableCell;

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if(stoneTableCell == nil)
		stoneTableCell = [[TFStoneTableCell alloc] init];
	
	return stoneTableCell;
}

-(NSArray*)stonesForSaving
{
	return [[stones copy] autorelease];
}

-(void)loadStones:(NSArray*)stonesToLoad
{
	if(stonesToLoad == stones) return;
	
	[stones removeAllObjects];
	[stones addObjectsFromArray:stonesToLoad];
	
	[self.stonesTable reloadData];
	[_generalTabController reloadStones];
	[_gridTabController reloadStones];
}

-(void)dealloc
{
	self.stonesTable = nil;
	self.gridTabController = nil;
	self.stoneShaperView = nil;
	self.generalTabController = nil;
	
	[stoneTableCell release];
	[stones release];
	[super dealloc];
}

@end

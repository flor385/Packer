//
//  TFStonesController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 6.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFStonesWindowController.h"
#import "TFDocument.h"
#import "TFStoneTableCell.h"
#import "TFStone.h"
#import "TFStoneShaperView.h"

@implementation TFStonesWindowController

@synthesize stonesTable = _stonesTable;
@synthesize stoneShaperView = _stoneShaperView;
@synthesize hasSelection = _hasSelection;

#pragma mark - Table data source and delegate protocol methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(aTableView == _stonesTable){
		TFDocument* doc = self.document;
		NSArray *stones = doc.stones;
		return [stones count];
	}else
		return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	TFDocument* doc = self.document;
	NSArray *stones = doc.stones;
	return [stones objectAtIndex:rowIndex];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger selectedRow = [_stonesTable selectedRow];
	self.hasSelection = selectedRow != -1;
	
	TFStone *selectedStone = selectedRow == -1 ? nil : [((TFDocument*)self.document).stones objectAtIndex:selectedRow];
	
	self.stoneShaperView.stone = selectedStone;
}

#pragma mark - Stone manipulation methods

- (IBAction)addAndSelectNew:(id)sender {
	[((TFDocument*)self.document) addNewStone];
	[_stonesTable reloadData];
	[_stonesTable selectRowIndexes:[NSIndexSet indexSetWithIndex:((TFDocument*)self.document).stones.count - 1] byExtendingSelection:NO];
}

- (IBAction)removeSelected:(id)sender {
	NSInteger selectedIndex = self.stonesTable.selectedRow;
	if(selectedIndex == -1)
		return;
	[self.document removeStoneAtIndex:selectedIndex];
	[self.stonesTable reloadData];
}

- (void)addSquareToSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y
{
	TFStone *selectedStone = self.stoneShaperView.stone;
	
	TFStone* newStone = [selectedStone stoneWithAddedSquareAtX:x andY:y];
	
	//	update the editor with the new stone
	self.stoneShaperView.stone = newStone;
	
	//	add the new stone to the list just below the currently selected
	NSUInteger index = self.stonesTable.selectedRow;
	[self.document insertStone:newStone atIndex:index + 1];
	[self.document removeStoneAtIndex:index];
	
	[self.stonesTable reloadData];
}

- (void)removeSquareFromSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y
{
	TFStone *selectedStone = self.stoneShaperView.stone;
	
	TFStone* newStone = [selectedStone stoneWithRemovedSquareFromX:x andY:y];
	
	//	update the editor with the new stone
	self.stoneShaperView.stone = newStone;
	
	//	add the new stone to the list just below the currently selected
	NSUInteger index = self.stonesTable.selectedRow;
	[self.document insertStone:newStone atIndex:index + 1];
	[self.document removeStoneAtIndex:index];
	
	[self.stonesTable reloadData];
}


#pragma mark - Table cell modifications

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	[aCell setRepresentedObject:[((TFDocument*)self.document).stones objectAtIndex:rowIndex]];
	
}

TFStoneTableCell *stoneTableCell;

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if(stoneTableCell == nil)
		stoneTableCell = [[TFStoneTableCell alloc] init];
	
	return stoneTableCell;
}

-(void)dealloc
{
	self.stonesTable = nil;
	[stoneTableCell release];
	[super dealloc];
}

@end

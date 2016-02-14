//
//  TFGeneralTabController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 15.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFGeneralTabController.h"
#import "TFGravity.h"
#import "TFStonesTabController.h"
#import "TFStoneTableCell.h"
#import "TFStoneGenerator.h"
#import "TFStone.h"

@interface TFGeneralTabController ()
{
	NSMutableDictionary* stonesProbabilitiesDict;
}

@end

@implementation TFGeneralTabController

@synthesize gravAllowUp, gravAllowDown, gravAllowLeft, gravAllowRight, gravAllowNone;
@synthesize gravInitialDirection;
@synthesize stonesProbabilitiesTable = _stonesProbabilitiesTable, stonesTabController = _stonesTabController;

-(id)init
{
	if(self = [super init]){
		
		stonesProbabilitiesDict = [NSMutableDictionary new];
		
		gravAllowDown = YES;
		gravAllowLeft = YES;
		gravAllowRight = YES;
		gravAllowUp = YES;
		gravAllowNone = NO;
		gravInitialDirection = TF_PACKER_GRAV_DIRECTION_DOWN;
		
		return self;
	}
	
	return nil;
}

-(TFGravity*)gravForSaving
{
	TFGravity* grav = [[[TFGravity alloc] init] autorelease];
	
	
	NSMutableArray *allowedDirections = [[NSMutableArray new] autorelease];
	if(gravAllowDown) 
		[allowedDirections addObject:[NSNumber numberWithInteger:TF_PACKER_GRAV_DIRECTION_DOWN]];
	if(gravAllowUp) 
		[allowedDirections addObject:[NSNumber numberWithInteger:TF_PACKER_GRAV_DIRECTION_UP]];
	if(gravAllowLeft) 
		[allowedDirections addObject:[NSNumber numberWithInteger:TF_PACKER_GRAV_DIRECTION_LEFT]];
	if(gravAllowRight) 
		[allowedDirections addObject:[NSNumber numberWithInteger:TF_PACKER_GRAV_DIRECTION_RIGHT]];
	if(gravAllowNone) 
		[allowedDirections addObject:[NSNumber numberWithInteger:TF_PACKER_GRAV_NONE]];
	[grav setAllowedDirections:[[allowedDirections copy] autorelease]];
	
	grav.direction = self.gravInitialDirection;
	
	return grav;
}

-(void)loadGrav:(TFGravity*)grav
{
	self.gravAllowUp = [grav allowsDirection:TF_PACKER_GRAV_DIRECTION_UP];
	self.gravAllowDown = [grav allowsDirection:TF_PACKER_GRAV_DIRECTION_DOWN];
	self.gravAllowLeft = [grav allowsDirection:TF_PACKER_GRAV_DIRECTION_LEFT];
	self.gravAllowRight = [grav allowsDirection:TF_PACKER_GRAV_DIRECTION_RIGHT];
	self.gravAllowNone = [grav allowsDirection:TF_PACKER_GRAV_NONE];
	self.gravInitialDirection = grav.direction;
}

-(TFStoneGenerator*)generatorForSaving
{
	TFStoneGenerator *gen = [[[TFStoneGenerator alloc] init] autorelease];
	for(TFStone *stone in [stonesProbabilitiesDict keyEnumerator])
		if([[stonesProbabilitiesDict objectForKey:stone] integerValue])
			[gen setProbability:[stonesProbabilitiesDict objectForKey:stone] forStone:stone];
	
	return gen;
}

-(void)loadGenerator:(TFStoneGenerator*)gen
{
	for(TFStone* stone in [gen stones])
		[stonesProbabilitiesDict setObject:[gen probabilityForStone:stone] forKey:stone];
	
	[_stonesProbabilitiesTable reloadData];
}

-(void)reloadStones
{
	[_stonesProbabilitiesTable reloadData];
}

#pragma mark - Table data source and delegate protocol methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(aTableView == _stonesProbabilitiesTable){
		return [_stonesTabController stoneCount];
	}else
		return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"stoneColumn"])
		return [_stonesTabController stoneAtIndex:rowIndex];
	else {
		NSNumber *prob = [stonesProbabilitiesDict objectForKey:[_stonesTabController stoneAtIndex:rowIndex]];
		if(prob == nil)
			prob = [NSNumber numberWithInt:0];
		
		return prob;
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	[stonesProbabilitiesDict setObject:anObject forKey:[_stonesTabController stoneAtIndex:rowIndex]];
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
	
	if([[tableColumn identifier] isEqualToString:@"stoneColumn"])
		return stoneTableCell;
	else {
		return nil;
	}
}

-(void)dealloc
{
	[stonesProbabilitiesDict release];
	self.stonesTabController = nil;
	self.stonesProbabilitiesTable = nil;
	[super dealloc];
}

@end

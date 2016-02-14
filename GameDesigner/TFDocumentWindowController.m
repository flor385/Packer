//
//  TFDocumentWindowController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 15.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFDocumentWindowController.h"
#import "TFStone.h"
#import "TFGame.h"
#import "TFGridTabController.h"
#import "TFStonesTabController.h"
#import	"TFGeneralTabController.h"
#import "TFDocument.h"

@implementation TFDocumentWindowController

@synthesize generalTabController = _generalTabController, stonesTabController = _stonesTabController, gridTabController = _gridTabController;

-(TFGame*)gameForSaving
{
	//	create and initialize the game to be saved
	TFGame* game = [[[TFGame alloc] initWithGrid:[_gridTabController gridForSaving] 
										 gravity:[_generalTabController gravForSaving]
									   generator:[_generalTabController generatorForSaving] 
									   andStones:[_stonesTabController stonesForSaving]] autorelease];
	
	return game;
}

-(void)awakeFromNib
{
	TFDocument *doc = [self document];
	if(doc.game)
		[self loadGame:doc.game];
}

-(void)loadGame:(TFGame*)game
{
	[_stonesTabController loadStones:game.stones];
	[_generalTabController loadGrav:game.gravity];
	[_generalTabController loadGenerator:game.stoneGenerator];
	[_gridTabController loadGrid:game.grid];
}


-(void)dealloc
{
	[_generalTabController release];
	[_stonesTabController release];
	[_gridTabController release];
	
	[super dealloc];
}

@end

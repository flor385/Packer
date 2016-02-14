//
//  TFDocument.m
//  StonesDesigner
//
//  Created by Stamenkovic Florijan on 2012 07 6.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFDocument.h"
#import "TFStone.h"
#import "TFStonesWindowController.h"

@implementation TFDocument



-(NSArray*)stones
{
	return [[_stones copy] autorelease];
}

-(void)addNewStone
{
	[_stones addObject:[[[TFStone alloc] init] autorelease]];
}

-(void)insertStone:(TFStone*)stone atIndex:(NSUInteger)index
{
	[_stones insertObject:stone atIndex:index];
}

-(void)removeStoneAtIndex:(NSUInteger)index
{
	[_stones removeObjectAtIndex:index];
}

- (id)init
{
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
    }
    return self;
}

//	initialization method called when not opening an existing document
//	containing data (then readFromData:... method is used)
- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
	if(self = [super initWithType:typeName error:outError]){
		
		_stones = [[NSMutableArray alloc] init];
		
		//	some test stones
		TFStone *ts1 = [[[TFStone alloc] init] autorelease];
		[_stones addObject:ts1];
		ts1 = [ts1 stoneWithAddedSquareAtX:1 andY:0];
		[_stones addObject:ts1];
		[_stones addObject:[ts1 stoneWithAddedSquareAtX:0 andY:1]];
		[_stones addObject:[ts1 stoneWithAddedSquareAtX:2 andY:0]];
		
		return self;
	}
	
	return nil;
}

- (void)makeWindowControllers
{
	TFStonesWindowController *documentWindow = [[[TFStonesWindowController alloc] initWithWindowNibName:@"TFDocument"] autorelease];
	[self addWindowController:documentWindow];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	return [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:_stones]];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	
	_stones = [[NSMutableArray alloc] init];
	[_stones addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	
	return YES;
}

-(void)dealloc
{
	[_stones release];
	_stones = nil;
	[super dealloc];
}

@end

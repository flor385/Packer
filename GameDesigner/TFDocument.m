//
//  TFDocument.m
//  GameDesigner
//
//  Created by Stamenkovic Florijan on 2012 07 15.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFDocument.h"
#import "TFDocumentWindowController.h"
#import "TFGame.h"

@interface TFDocument ()
{
	TFDocumentWindowController *_controller;
}

@end

@implementation TFDocument

@synthesize game = _game;

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
		
		return self;
	}
	
	return nil;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	self.game = [_controller gameForSaving];
	return [NSKeyedArchiver archivedDataWithRootObject:_game];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	self.game = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	return YES;
}

- (void)makeWindowControllers
{
	_controller = [[[TFDocumentWindowController alloc] initWithWindowNibName:@"TFDocument"] autorelease];
	[self addWindowController:_controller];
}

-(void)dealloc
{
	self.game = nil;
	[super dealloc];
}

@end

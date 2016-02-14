//
//  TFLevelLoader.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 21.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFLevelLoader.h"

@interface TFLevelLoader ()
{
	NSMutableDictionary* puzzleGamePathDict;
}

@end

@implementation TFLevelLoader

static TFLevelLoader* _sharedLoader;

+(TFLevelLoader*)sharedLoader
{
	if(_sharedLoader == nil){
		_sharedLoader = [[super allocWithZone:NULL] init];
	}
	
	return _sharedLoader;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedLoader] retain];
}

- (id)init
{
	if(self = [super init]){
		
		puzzleGamePathDict = [NSMutableDictionary new];
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSArray *levelPaths = [bundle pathsForResourcesOfType:@"tfpackergame" inDirectory:nil];
		for(NSString *path in levelPaths)
			if([[path lastPathComponent] rangeOfString:@"puzzle"].location == 0)
				[puzzleGamePathDict setObject:path forKey:[[path stringByDeletingPathExtension] lastPathComponent]];

	}
	
	return self;
}

-(NSArray*)puzzleGameNames
{
	return [[puzzleGamePathDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

-(TFGame*)freePack
{
	NSString* path;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		path = [[NSBundle mainBundle] pathForResource:@"freePackPhone" ofType:@"tfpackergame" inDirectory:nil];
	else 
		path = [[NSBundle mainBundle] pathForResource:@"freePackPad" ofType:@"tfpackergame" inDirectory:nil];
	
	TFGame* rVal = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	return rVal;
}

-(TFGame*)puzzleGameNamed:(NSString*)puzzleGameName
{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[puzzleGamePathDict objectForKey:puzzleGameName]];
}



#pragma mark - Singleton stuff

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end

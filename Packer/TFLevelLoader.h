//
//  TFLevelLoader.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 21.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFGame.h"

//	Singleton class in charge of loading level files and
//	unarchiving them into |TFGame| instances.

@interface TFLevelLoader : NSObject

+(TFLevelLoader*)sharedLoader;

//	An array of the names of all puzzle games
//	available. Names are loaded without loading
//	game files.
@property(retain, readonly) NSArray *puzzleGameNames;

//	Loads the file for |puzzleGameName|, unarchives it
//	and returns it.
-(TFGame*)puzzleGameNamed:(NSString*)puzzleGameName;

//	Loads and returns the "free pack" level (which is device dependant).
-(TFGame*)freePack;


@end

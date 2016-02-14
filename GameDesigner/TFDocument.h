//
//  TFDocument.h
//  GameDesigner
//
//  Created by Stamenkovic Florijan on 2012 07 15.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TFGame;

@interface TFDocument : NSDocument

@property(retain, readwrite) TFGame* game;

@end

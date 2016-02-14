//
//  TFDocumentWindowController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 15.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TFGeneralTabController, TFStonesTabController, TFGridTabController, TFGame;

@interface TFDocumentWindowController : NSWindowController

@property(retain, readwrite) IBOutlet TFGeneralTabController *generalTabController;
@property(retain, readwrite) IBOutlet TFStonesTabController *stonesTabController;
@property(retain, readwrite) IBOutlet TFGridTabController *gridTabController;

-(TFGame*)gameForSaving;
-(void)loadGame:(TFGame*)game;

@end

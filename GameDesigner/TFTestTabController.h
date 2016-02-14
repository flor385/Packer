//
//  TFTestTabController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 19.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFGame, TFDocumentWindowController, TFGridView;

@interface TFTestTabController : NSObject

@property(retain, readwrite) TFGame* game;
@property(assign, readwrite) IBOutlet TFDocumentWindowController *windowController;
@property(assign, readwrite) IBOutlet TFGridView *gridView;

@property(assign, readwrite) NSInteger gravDirection;

-(IBAction)startTest:(id)sender;
-(IBAction)stopTest:(id)sender;

@end

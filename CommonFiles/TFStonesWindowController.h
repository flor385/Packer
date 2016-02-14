//
//  TFStonesController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 6.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFStonesController.h"
@class  TFDocument, TFStoneShaperView;

@interface TFStonesWindowController : NSWindowController <TFStonesController>

@property (assign) IBOutlet NSTableView *stonesTable;
@property (assign) IBOutlet TFStoneShaperView *stoneShaperView;

@property NSInteger hasSelection;


- (IBAction)addAndSelectNew:(id)sender;
- (IBAction)removeSelected:(id)sender;

@end

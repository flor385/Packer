//
//  TFStoneShaperView.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 6.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TFStone;
#import "TFStonesController.h"

@interface TFStoneShaperView : NSView

@property(retain) TFStone* stone;
@property(retain) IBOutlet NSObject<TFStonesController> *stonesController;

@end

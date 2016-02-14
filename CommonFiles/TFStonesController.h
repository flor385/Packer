//
//  TFStonesController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 16.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TFStonesController <NSObject>

- (void)addSquareToSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y;
- (void)removeSquareFromSelectedStoneAtX:(NSInteger)x andY:(NSInteger)y;

@end

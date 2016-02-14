//
//  TFDocument.h
//  StonesDesigner
//
//  Created by Stamenkovic Florijan on 2012 07 6.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TFStone;

@interface TFDocument : NSDocument
{
	@private
	NSMutableArray* _stones;
}

@property(readonly) NSArray* stones;


-(void)addNewStone;
-(void)insertStone:(TFStone*)stone atIndex:(NSUInteger)index;
-(void)removeStoneAtIndex:(NSUInteger)index;

@end

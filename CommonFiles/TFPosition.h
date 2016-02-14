//
//  TFPosition.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 9.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

//	Immutable class that carries two NSInteger values, to be utilized
//	in many wonderful places.
@interface TFPosition : NSObject <NSCoding>

@property(readonly, assign) NSInteger x,y;

+(TFPosition*)positionWithX:(NSInteger)x andY:(NSInteger)y;

-(id)initWithX:(NSInteger)x andY:(NSInteger)y;

@end

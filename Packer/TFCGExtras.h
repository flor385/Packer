//
//  TFCGExtras.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 27.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <Foundation/Foundation.h>

//	a point in int coordinates
typedef struct _CGPointInt {
	int x, y;
} CGPointInt;

//	a size in int coordinates
typedef struct _CGSizeInt{
	int width, height;
} CGSizeInt;


CGPointInt CGPointIntMake(int x, int y);
CGSizeInt CGSizeIntMake(int width, int height);
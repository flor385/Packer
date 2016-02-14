//
//  TFCGExtras.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 27.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFCGExtras.h"

CGPointInt CGPointIntMake(int x, int y){
	CGPointInt rVal;
	rVal.x = x;
	rVal.y = y;
	return rVal;
}

CGSizeInt CGSizeIntMake(int width, int height){
	CGSizeInt rVal;
	rVal.width = width;
	rVal.height = height;
	return rVal;
}
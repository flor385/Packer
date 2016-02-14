//
//  main.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TFAppDelegate.h"

int main(int argc, char *argv[])
{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([TFAppDelegate class]));
    [pool release];
    return retVal;
}

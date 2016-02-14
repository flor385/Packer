//
//  TFAppDelegate.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFMainMenuController;

@interface TFAppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) TFMainMenuController *mainMenuController;
@property (retain, readonly) EAGLContext *glContext;

@end

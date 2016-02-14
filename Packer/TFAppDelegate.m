//
//  TFAppDelegate.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 3.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFAppDelegate.h"
#import "TFMainMenuController.h"

@implementation TFAppDelegate

@synthesize window = _window;
@synthesize mainMenuController = _mainMenuController;
@synthesize glContext = _glContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
	//	create and set the GL context
	_glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	if(_glContext == nil)
		_glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	if(!_glContext) {
		NSLog(@"Failed to create ES context");
	}
	[EAGLContext setCurrentContext:_glContext];
	
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    self.mainMenuController = [[[TFMainMenuController alloc] initWithNibName:@"TFMainMenuController_iPhone" bundle:nil] autorelease];
	} else {
	    self.mainMenuController = [[[TFMainMenuController alloc] initWithNibName:@"TFMainMenuController_iPad" bundle:nil] autorelease];
	}
	
	self.window.rootViewController = self.mainMenuController;
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
	[_glContext release];
	_glContext = nil;
	[_window release];
	[_mainMenuController release];
    [super dealloc];
}

@end

//
//  TFMainMenuController.m
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 20.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import "TFMainMenuController.h"
#import "TFPuzzlesViewController.h"
#import "TFAppDelegate.h"
#import "TFGameViewController.h"
#import "TFLevelLoader.h"

@implementation TFMainMenuController

@synthesize navigationController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[navigationController.view setFrame:self.view.bounds];
	[self.view addSubview:navigationController.view];
}

- (void)viewDidUnload
{
    [self setNavigationController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)freePack:(id)sender
{
	TFGameViewController *detailViewController = [[TFGameViewController alloc] initWithGame:[[TFLevelLoader sharedLoader] freePack]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (IBAction)rushAction:(id)sender
{
	
}

- (IBAction)puzzlesAction:(id)sender {
	
	TFPuzzlesViewController *pvc = [[TFPuzzlesViewController alloc] initWithStyle:UITableViewStylePlain];
	[navigationController pushViewController:pvc animated:YES];
	[pvc release];
}

- (void)dealloc {
    [navigationController release];
    [super dealloc];
}

@end

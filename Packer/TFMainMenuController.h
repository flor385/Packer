//
//  TFMainMenuController.h
//  Packer
//
//  Created by Stamenkovic Florijan on 2012 07 20.
//  Copyright (c) 2012 FloCo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFMainMenuController : UIViewController

@property (retain, nonatomic) IBOutlet UINavigationController *navigationController;

- (IBAction)puzzlesAction:(id)sender;
- (IBAction)freePack:(id)sender;
- (IBAction)rushAction:(id)sender;

@end

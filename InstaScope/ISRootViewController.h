//
//  RootViewController.h
//  InstaScope
//
//  Created by Javier Luraschi on 9/17/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationHeader;

@end

//
//  ISPageModelController.h
//  InstaScope
//
//  Created by Javier Luraschi on 9/17/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ISViewController;

@interface ISPageModelController : NSObject <UIPageViewControllerDataSource>

- (ISViewController*) viewControllerAtIndex: (NSUInteger)index storyboard: (UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController: (ISViewController*)viewController;

@end


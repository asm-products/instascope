//
//  ISAppDelegate.h
//  InstaScope
//
//  Created by Javier Luraschi on 10/5/12.
//  Copyright (c) 2012 Javier Luraschi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (weak, nonatomic) UINavigationItem *navigationHeader;

@property (weak, nonatomic) UIViewController *navigationViewController;

@property (weak, nonatomic) UIViewController *rootViewController;

@property (weak, nonatomic) UIPageViewController *pageViewController;

@property (weak, nonatomic) NSObject *pageModelController;

@property (weak, nonatomic) NSDictionary *selectedData;

@property (atomic) bool dataNeedsRefresh;

@property (nonatomic) NSString* instagramAccessToken;

@property (nonatomic) bool recordLocationOnce;

@end

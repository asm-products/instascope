//
//  ISDetailsViewController.h
//  InstaScope
//
//  Created by Javier Porras Luraschi on 9/29/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ISDetailsViewController : UIViewController<UIAccelerometerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
{
    NSDictionary* data;
}

@property (strong, nonatomic) IBOutlet UIImageView *mainImage;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
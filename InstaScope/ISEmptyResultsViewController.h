//
//  ISEmptyResultsViewController.h
//  InstaScope
//
//  Created by Javier Porras Luraschi on 10/15/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISEmptyResultsViewController : UIViewController<UIActionSheetDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (nonatomic) NSUInteger locationsIndex;

@end
//
//  ISDetailsViewController.m
//  InstaScope
//
//  Created by Javier Porras Luraschi on 9/29/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>

#import "ISAppDelegate.h"
#import "ISDetailsViewController.h"
#import "ISCommonActions.h"
#import "Flurry.h"

@implementation ISDetailsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    data = appDelegate.selectedData;
    
    int height = self.view.frame.size.height - 65;
    self.mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height, height)];
    self.mainImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.mainImage sizeThatFits:CGSizeMake(height, height)];
    [self.scrollView setContentSize:CGSizeMake(height, height)];
    self.scrollView.maximumZoomScale = 4;
    
    NSString* imageUrl = [[[data objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"];
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    
    //[image drawInRect:CGRectMake(0, 0, height, height)];
    [self.mainImage setImage:image];
    [self.scrollView addSubview:self.mainImage];
    
    UITapGestureRecognizer *viewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    viewTapGesture.delegate = self;
    [self.view addGestureRecognizer:viewTapGesture];
    
    //self.scrollView.bounces = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [Flurry logEvent:@"DetailsAppeared"];
    
    //UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
    //accelerometer.delegate = self;
    //accelerometer.updateInterval = 1.0f / 60.0f;
    
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = nil;
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    float centerX = self.mainImage.center.x +
    100.0f * (acceleration.x > 0.20 ? 0.05 : (acceleration.x < -0.20 ? -0.05 : 0.0));
    
    if (centerX - self.mainImage.frame.size.width / 2 + 5 > 0)
        centerX = self.mainImage.frame.size.width / 2 - 5;
    
    if (centerX + self.mainImage.frame.size.width / 2 - 5 < self.view.frame.size.width)
        centerX = self.view.frame.size.width - self.mainImage.frame.size.width / 2 + 5;
    
    self.mainImage.center = CGPointMake(centerX, self.mainImage.center.y);
}

-  (void)imageTapped:(UITapGestureRecognizer *)sender
{
    [Flurry logEvent:@"DetailsTapped"];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Instagram", @"Log in to Instagram", @"Report and Remove", nil];
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    switch (buttonIndex)
    {
        case 0:
            [Flurry logEvent:@"DetailsOpenInstagram"];
            [self openInInstagram];
            break;
        case 1:
            [Flurry logEvent:@"ListSignInstagram"];
            [appDelegate.navigationViewController performSegueWithIdentifier:@"segueToAuth" sender:self];
        case 2:
            [Flurry logEvent:@"DetailsReportContent"];
            [self reportContent];
            break;
    }
}

-(void)openInInstagram
{
    NSString* mediaId = [data valueForKey:@"id"];
    [ISCommonActions openInInstagramForMediaId: mediaId];
}

-(void)reportContent
{
    NSString* mediaId = [data valueForKey:@"id"];
    
    [ISCommonActions reportContentForMediaId:mediaId];
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.dataNeedsRefresh = true;
    
    [appDelegate.navigationViewController.navigationController popToRootViewControllerAnimated:TRUE];
}

@end

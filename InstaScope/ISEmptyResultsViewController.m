//
//  ISEmptyResultsViewController.m
//  InstaScope
//
//  Created by Javier Porras Luraschi on 10/15/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import "ISAppDelegate.h"
#import "ISEmptyResultsViewController.h"
#import "ISCommonActions.h"
#import "Flurry.h"

@implementation ISEmptyResultsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"EmptyLocationLoaded"];
    
    UITapGestureRecognizer *removeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRemoveTapGesture:)];
    removeTapGesture.numberOfTapsRequired=1;
    removeTapGesture.numberOfTouchesRequired=1;
    removeTapGesture.cancelsTouchesInView = NO;
    
    [self.removeButton addTarget:self action:@selector(handleRemove:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.parentViewController.view addGestureRecognizer:removeTapGesture];
}

-  (void)handleRemoveTapGesture:(UITapGestureRecognizer *)recognizer
{
    [Flurry logEvent:@"EmptyLocationMenu"];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove Location", nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)handleRemove:(id)sender {
    [ISCommonActions removeLocation:self.locationsIndex];
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.navigationViewController.navigationController popToRootViewControllerAnimated:NO];
    [self performSegueWithIdentifier: @"SegueToMain2" sender:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [Flurry logEvent:@"EmptyLocationRemoved"];
            [self handleRemove:nil];
            break;
    }
}

@end

//
//  ISLocationSettings.m
//  InstaScope
//
//  Created by Javier Luraschi on 9/17/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>

#import "ISSettingsViewController.h"
#import "ISAppDelegate.h"
#import "Flurry.h"
#import "ISCommonActions.h"
#import "ISPageModelController.h"

@implementation ISSettingsViewController

- (IBAction)handleAddButton:(id)sender {
    NSMutableDictionary* flurryData = [[NSMutableDictionary alloc] init];
    [flurryData setValue:self.searchTextField.text forKey:@"NewLocation"];
    [Flurry logEvent:@"NewLocationAdded" withParameters:flurryData];
    
    CLLocationCoordinate2D location = [self.mapView centerCoordinate];
    [ISCommonActions addLocation: self.searchTextField.text withLatitude: location.latitude andLongitude:location.longitude];
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.navigationViewController.navigationController popToRootViewControllerAnimated:NO];
    
    ISPageModelController* pageModelController = (ISPageModelController*)appDelegate.pageModelController;
    [pageModelController init];
    ISViewController* startingViewController = [pageModelController viewControllerAtIndex:0 storyboard:self.storyboard];
    [appDelegate.pageViewController setViewControllers:[NSArray arrayWithObject:startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self performSegueWithIdentifier: @"SegueToMain" sender: self];
}

- (void) applyStyles
{
    self.addLocationButton.layer.cornerRadius = 2;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.searchTextField.delegate = self;
    self.addLocationButton.hidden = true;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self applyStyles];
    [self.searchTextField becomeFirstResponder];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) setReverseGeolocation: (NSString*)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            CLLocationDistance distance = 2000;
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
            
            [self.mapView setRegion:region];
            self.addLocationButton.hidden = false;
        } else {
            NSLog(@"error");
            self.addLocationButton.hidden = true;
        }
    }];
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    NSMutableDictionary* flurryData = [[NSMutableDictionary alloc] init];
    [flurryData setValue:textField.text forKey:@"NewLocationSearch"];
    [Flurry logEvent:@"NewLocationSearched" withParameters:flurryData];
    
    [textField resignFirstResponder];
    [self setReverseGeolocation: textField.text];
    
    return YES;
}

@end
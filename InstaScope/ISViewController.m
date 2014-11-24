//
//  ISViewController.m
//  InstaScope
//
//  Created by Javier Luraschi on 10/5/12.
//  Copyright (c) 2012 Javier Luraschi. All rights reserved.
//

#import "ISViewController.h"
#import "ISInstagram.h"
#import "ISAppDelegate.h"
#import "ISCommonActions.h"
#import "Flurry.h"

#import <sys/utsname.h>

@implementation ISViewController

@synthesize scrollView;
@synthesize scrollContainer;
@synthesize activityView;
@synthesize rootView;
@synthesize locationManager;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary* pageData = (NSDictionary*) self.dataObject;
    
    // Initialioze view parameters
    NSNumber* latitudeNumber = [pageData valueForKey: @"latitude"];
    NSNumber* longitudeNumber = [pageData valueForKey: @"longitude"];
    latitude = [latitudeNumber doubleValue];
    longitude = [longitudeNumber doubleValue];
    
    lastDataRefresh = nil;
    radialDistance = 3000.0f; //2000.0f;
    triggerRefeshFromLocationChange = YES;
    
    CLLocationCoordinate2D coord = {.latitude =  latitude, .longitude =  longitude};
    MKCoordinateSpan span = {.latitudeDelta =  0.02, .longitudeDelta =  0.02};
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];
    
    instagram = [[ISInstagram alloc] init: self];
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    bool defaultLocationCreated = [ISCommonActions getSetting:@"defaultLocationCreated" withDefault:false];
    
    if (!defaultLocationCreated && !appDelegate.recordLocationOnce) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager setPausesLocationUpdatesAutomatically:NO];
        
        if (![CLLocationManager locationServicesEnabled])
        {
            //You need to enable Location Services
        }
        if (![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
        {
            //Region monitoring is not available for this Class;
        }
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
           [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
        }
        
        NSLog(@"Authorization Status: %i", [CLLocationManager authorizationStatus]);
        
        [locationManager startUpdatingLocation];
    }
    
    [self refreshData];
    
    scrollView.delegate = self;
    
    [self.scrollContainer setUserInteractionEnabled:YES];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    // [locationManager stopUpdatingLocation];
}

- (IBAction)refreshMoreRecent
{
    
}

- (IBAction)refreshData
{
    [Flurry logEvent:@"ListRefreshed"];
    
    [self prepareViewForData];
    [activityView setHidden:NO];

    if (latitude == 0 || longitude == 0)
    {
        UIAlertView * oopsAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Oops!"
                                   message:@"Yikes! Can't figure out your location :( Lets try San Francisco for now."
                                   delegate:nil
                                   cancelButtonTitle:@"Bye"
                                   otherButtonTitles:nil];
        
        [oopsAlert show];
        [instagram getDataWithLatitude: 37.777119 longitud: -122.41964 triggerRefresh: YES radialDistance:radialDistance];
    }
    else
    {
        [instagram getDataWithLatitude: latitude longitud: longitude triggerRefresh:YES radialDistance:radialDistance];
    }
    
    lastDataRefresh = [[NSDate alloc] init];
}

- (void)appendData
{
    if (appendingData)
        return;
    
    appendingData = YES;
    [activityView setHidden:NO];
    
    [instagram getDataWithLatitude: latitude longitud: longitude triggerRefresh:NO radialDistance:radialDistance];
    
    lastDataRefresh = [[NSDate alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.scrollView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([ISCommonActions totalLocations] == 0) {
        [self performSegueWithIdentifier: @"SegueToSettings" sender: self];
        return; 
    }
    
    NSDictionary* pageData = (NSDictionary*) self.dataObject;
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.navigationHeader.title = [pageData valueForKey: @"name"];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(deviceShaken) name:@"DeviceShaken" object:nil];
    
    if (appDelegate.dataNeedsRefresh) {
        [self refreshData];
        appDelegate.dataNeedsRefresh = false;
    }
}

-  (void)imageTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    if ([dataArray count] <= recognizer.view.tag)
        return;
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.selectedData = [dataArray objectAtIndex:recognizer.view.tag];
    
    [appDelegate.navigationViewController performSegueWithIdentifier:@"segueToDetails" sender:self];
}

- (void)imageLongPressed: (UILongPressGestureRecognizer *)recognizer
{
    [Flurry logEvent:@"ListLongPress"];
    
    if (recognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    if ([dataArray count] <= recognizer.view.tag)
        return;
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Instagram", @"Log in to Instagram", @"Remove Location", @"Report and Remove", nil];
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.selectedData = [dataArray objectAtIndex:recognizer.view.tag];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *mediaId = [appDelegate.selectedData objectForKey:@"id"];
    
    switch (buttonIndex)
    {
        case 0:
            [Flurry logEvent:@"ListOpenInstagram"];
            [ISCommonActions openInInstagramForMediaId:mediaId];
            break;
        case 1:
            [Flurry logEvent:@"ListSignInstagram"];
            [appDelegate.navigationViewController performSegueWithIdentifier:@"segueToAuth" sender:self];
        case 2:
        {
            [Flurry logEvent:@"ListRemoveLocation"];
            [ISCommonActions removeLocation:self.locationsIndex];
            [appDelegate.navigationViewController.navigationController popToRootViewControllerAnimated:NO];
            [self performSegueWithIdentifier: @"SegueToMain" sender:self];
            
            break;
        }
        case 3:
        {
            [Flurry logEvent:@"ListReportContent"];
            [ISCommonActions reportContentForMediaId:mediaId];
            [self refreshData];
            break;
        }
    }
}

- (void) prepareViewForData
{
    offsetY = 0.0;
    
    // Fix Offset in iPhone 5.0
    CGRect hostRect = self.rootView.frame;
    hostRect.origin.x = 0;
    hostRect.origin.y = 0;
    [scrollView setFrame: hostRect];
    
    totalRows = 0;
    imageViews = [[NSMutableArray alloc] init];
    picNumber = 0;
    dataArray = [[NSMutableArray alloc] init];
    appendingData = NO;
    radialDistance = 3000.0f; //1500.0f;
    
    self.scrollContainer = [[UIView alloc] init];
    UITapGestureRecognizer *viewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    viewTapGesture.delegate = self;
    [self.scrollView addGestureRecognizer:viewTapGesture];
    
    [self.scrollView addSubview:self.scrollContainer];
}

- (void) addDataToView:(NSArray *)data
{
    // Error?
    if (data == nil || [data count] == 0)
    {
        foundNothing = YES;
    }
    
    [dataArray addObjectsFromArray: data];
    
    int hostWidth = self.view.frame.size.width;
        
    float smallImageSizeUnit = 95.0 * hostWidth / 315.0;
    float imageSizeUnit = 200.0 * hostWidth / 315.0;
    float imageSpacing = 10 * hostWidth / 315.0;

    float imageSizeWithSpacing = imageSizeUnit + imageSpacing;
    float smallImageSizeWithSpacing = smallImageSizeUnit + imageSpacing;
    
    totalRows = ceil(1.0f * [dataArray count] / 3);
    CGRect containerRect = CGRectMake(0, 0, 320.0f, 100.0 + imageSizeWithSpacing * totalRows + 10);
    
    [self.scrollContainer setFrame:containerRect];
    
    if (dataArray.count == 0) {
        if (self.emptyResults == nil) {
            self.emptyResults = [self.storyboard instantiateViewControllerWithIdentifier: @"ISEmptyResults"];
        }
        [self addChildViewController:self.emptyResults];
        self.emptyResults.locationsIndex = self.locationsIndex;
        self.emptyResults.view.userInteractionEnabled = YES;
        self.scrollView.userInteractionEnabled = YES;
        self.scrollView.clipsToBounds = YES;
        
        self.emptyResults.view.frame = self.view.bounds;
        [self.scrollView setContentSize:self.emptyResults.view.frame.size];
        
        [self.scrollContainer addSubview: self.emptyResults.view];
    }
    else if (self.emptyResults != nil) {
        [self.emptyResults removeFromParentViewController];
        [self.emptyResults.view removeFromSuperview];
        self.emptyResults = nil;
    }
     
    while(picNumber < dataArray.count) {
        NSDictionary *dataEntry = [dataArray objectAtIndex:picNumber];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageViews addObject:imageView];
        [imageView setBackgroundColor:[[UIColor alloc]initWithRed:0.30f green:0.30f blue:0.30f alpha:1]];
        
        NSString* picturePath = [[[dataEntry valueForKey:@"images"] valueForKey:@"low_resolution"] valueForKey:@"url"];
        
        NSString* thumbnailPath = [[[dataEntry valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"];
        
        // Is ipad?
        if (hostWidth > 400) {
            picturePath = [[[dataEntry valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"];
            thumbnailPath = [[[dataEntry valueForKey:@"images"] valueForKey:@"low_resolution"] valueForKey:@"url"];
        }
        
        NSLog(@"%@, %@", picturePath, thumbnailPath);
        
        
        NSMutableDictionary* loadImageData = [[NSMutableDictionary alloc] init];
        [loadImageData setObject:[[NSNumber alloc]initWithInt:picNumber] forKey:@"imageViewIndex"];
        if (picNumber % 3 == 0)
        {
            [loadImageData setValue:picturePath forKey:@"path"];
        }
        else
        {
            [loadImageData setValue:thumbnailPath forKey:@"path"];
        }
        [self performSelectorInBackground: @selector(backgroundLoadImage:) withObject:loadImageData];
        
        float offsetX = 7;
        float x = offsetX, y = offsetY, width = smallImageSizeUnit, height = smallImageSizeUnit;
        if (picNumber % 6 == 0)
        {
            width = imageSizeUnit;
            height = imageSizeUnit;
        }
        else if (picNumber % 6 == 1)
        {
            x = imageSizeWithSpacing + offsetX;
        }
        else if (picNumber % 6 == 2)
        {
            x = imageSizeWithSpacing + offsetX;
            y += smallImageSizeWithSpacing;
            offsetY += imageSizeWithSpacing;
        }
        else if (picNumber % 6 == 3)
        {
            x = smallImageSizeWithSpacing + offsetX;
            width = imageSizeUnit;
            height = imageSizeUnit;
        }
        else if (picNumber % 6 == 4)
        {
        }
        else
        {
            y += smallImageSizeWithSpacing;
            offsetY += imageSizeWithSpacing;
        }
        
        UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        imageTapGesture.numberOfTapsRequired=1;
        imageTapGesture.numberOfTouchesRequired=1;
        imageTapGesture.view.tag = picNumber;
        
        UILongPressGestureRecognizer *imageLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPressed:)];
        imageTapGesture.view.tag = picNumber;
        
        imageView.tag = picNumber;
        imageView.userInteractionEnabled = YES;
        
        [imageView sizeThatFits:CGSizeMake(x,y)];
        [imageView setFrame:CGRectMake(x,y,width,height)];
        [imageView addGestureRecognizer:imageTapGesture];
        [imageView addGestureRecognizer:imageLongPressGesture];
        [self.scrollContainer addSubview:imageView];
        
        picNumber++;
    }
    
    self.scrollView.contentSize = containerRect.size;
    [activityView setHidden:YES];
    appendingData = NO;
}

-(void)backgroundLoadImage:(NSDictionary*)data {
    NSData* dato = [NSData dataWithContentsOfURL:[NSURL URLWithString:[data valueForKey:@"path"]]];
    
    UIImage* image = [UIImage imageWithData:dato];
    NSUInteger picViewIndex = [[data valueForKey:@"imageViewIndex"] integerValue];
    
    if ([imageViews count] > picViewIndex) {
        [[imageViews objectAtIndex: picViewIndex] performSelectorOnMainThread:@selector(setImage:) withObject:  image waitUntilDone:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [Flurry logEvent:@"ListAppeared"];
    
    [super viewDidAppear:animated];
    
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)centerScrollViewContents
{
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer
{
}

-(BOOL)canBecomeFirstResponder{
	return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.subtype == UIEventSubtypeMotionShake)
	{
        [self refreshData];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    bool defaultLocationCreated = [ISCommonActions getSetting:@"defaultLocationCreated" withDefault:false];
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    if (defaultLocationCreated || appDelegate.recordLocationOnce) {
        return;
    }
    
    CLLocation *currentLocation = [locations lastObject];
    
    appDelegate.recordLocationOnce = true;
    //[locationManager stopUpdatingLocation];
    
    // Make sure something changed.
    //if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude
    //    && newLocation.coordinate.longitude == oldLocation.coordinate.longitude)
    //    return;
    
    NSLog(@"(%@, %@)",
        [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude],
        [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude]);
    
    latitude = currentLocation.coordinate.latitude;
    longitude = currentLocation.coordinate.longitude;
    
    // Don't refresh too frequently
//    if (lastDataRefresh != nil)
//    {
//        NSTimeInterval secondsBetween = [[[NSDate alloc] init] timeIntervalSinceDate:lastDataRefresh];
//        if (secondsBetween < 60)
//            return;
//    }
    
    // Ignore minor deviations
//    if (abs(newLocation.coordinate.latitude - oldLocation.coordinate.latitude) < 0.0002f
//        && abs(newLocation.coordinate.longitude - oldLocation.coordinate.longitude) < 0.0002f)
//        return;
    
    // lastDataRefresh = [[NSDate alloc] init];
    
    //if (triggerRefeshFromLocationChange)
    //{
    //    triggerRefeshFromLocationChange = NO;
    //    [self refreshData];
    //}
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    [ceo reverseGeocodeLocation:loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         [Flurry logEvent:@"GotUserLocation"];
         
         if (error != nil) {
             [Flurry logEvent:@"GotUserLocationError"];
             return;
         }
             
         
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark %@",placemark);
         NSLog(@"placemark %@",placemark.region);
         NSLog(@"placemark %@",placemark.country);
         NSLog(@"placemark %@",placemark.locality); // Extract the city name
         NSLog(@"location %@",placemark.name);
         NSLog(@"location %@",placemark.ocean);
         NSLog(@"location %@",placemark.postalCode);
         NSLog(@"location %@",placemark.subLocality);
         
         NSString* locaitonName = [NSString stringWithFormat:@"(%f, %f)", latitude, longitude];
         if (placemark.locality != nil || [placemark.locality length] > 0) {
             locaitonName =placemark.locality;
         } else if (placemark.name != nil || [placemark.name length] > 0) {
             [Flurry logEvent:@"GotUserLocationNoLocality"];
             locaitonName =placemark.name;
         } else {
             [Flurry logEvent:@"GotUserLocationNoName"];
         }
         
         [ISCommonActions addLocation:locaitonName withLatitude:loc.coordinate.latitude andLongitude:loc.coordinate.longitude];
         
         [ISCommonActions saveSetting:@"defaultLocationCreated" withValue:true];
         
         ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
         [appDelegate.navigationViewController.navigationController popToRootViewControllerAnimated:NO];
         [self performSegueWithIdentifier: @"SegueToMain" sender: self];
         
         [Flurry logEvent:@"AutomatedLocationAdded"];
     }];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIScrollView class]]) {
        return NO;
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollViewInstance {
    NSLog(@"%f, %f, %f",
          scrollView.contentSize.height,
          rootView.frame.size.height,
          scrollView.contentOffset.y);
    
    NSInteger pullingDetectFrom = -600;
    if (scrollView.contentSize.height <= rootView.frame.size.height && scrollView.contentOffset.y > pullingDetectFrom) {
        NSLog(@"Pull Up");
        [self appendData];
    } else if (scrollView.contentSize.height > rootView.frame.size.height &&
               scrollView.contentSize.height-rootView.frame.size.height-scrollView.contentOffset.y < -pullingDetectFrom) {
        NSLog(@"Pull Up");
        [self appendData];
    }
    
    if (scrollView.contentOffset.y < -60) {
        triggerRefreshFromPullDown = true;
    }
    if (triggerRefreshFromPullDown && scrollView.contentOffset.y > -10) {
        triggerRefreshFromPullDown = false;
        [self refreshData];
    }
}

- (IBAction)handleAddLocationButton:(id)sender {
    [self performSegueWithIdentifier: @"SegueToSettings" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToDetails"]) {
        //[segue.destinationViewController setData: currentDataElement];
    }
}

@end

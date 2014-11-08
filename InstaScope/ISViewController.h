//
//  ISViewController.h
//  InstaScope
//
//  Created by Javier Luraschi on 10/5/12.
//  Copyright (c) 2012 Javier Luraschi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ISInstagram.h"
#import "ISEmptyResultsViewController.h"

@interface ISViewController : UIViewController<UIScrollViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIAccelerometerDelegate>
{
    NSMutableArray* serviceData;
    ISInstagram* instagram;
    
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    
    NSDate* lastDataRefresh;
    
    // Data that supports infinite scroll
    NSMutableArray* imageViews;
    NSMutableArray* dataArray;
    float offsetY;
    int totalRows;
    int picNumber;
    BOOL appendingData;
    double radialDistance;
    
    BOOL triggerRefeshFromLocationChange;
    BOOL foundNothing;
    
    BOOL triggerRefreshFromPullDown;
    NSString* selectedMediaId;
}

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIView* scrollContainer;
@property (nonatomic, strong) IBOutlet UIView* activityView;
@property (nonatomic, strong) IBOutlet UIView* rootView;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) id dataObject;
@property (nonatomic) int locationsIndex;

@property (nonatomic, strong) ISEmptyResultsViewController *emptyResults;

@property (nonatomic, strong) CLLocationManager* locationManager;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

- (IBAction)refreshData;
- (void)appendData;
- (void)prepareViewForData;
- (void)addDataToView:(NSArray *)data;
- (void)imageTapped:(UITapGestureRecognizer *)recognizer;
- (void)imageLongPressed: (UILongPressGestureRecognizer *)recognizer;

-(BOOL)canBecomeFirstResponder;

- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager
didFailWithError:(NSError *)error;

-(void)backgroundLoadImage:(UIImageView*)imageView fromPath:(NSString*)path;

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

-(void)applicationDidEnterBackground:(UIApplication *)application;

- (IBAction)handleAddLocationButton:(id)sender;

@end

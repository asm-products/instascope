//
//  ISInstagram.h
//  InstaScope
//
//  Created by Javier Luraschi on 10/5/12.
//  Copyright (c) 2012 Javier Luraschi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ISInstagram : NSObject
{
    id delegate;
    NSMutableData* receivedData;
    
    double mostRecentCreatedTime;
    BOOL retryingRefreshForLongerDistance;
    
    double lastCreatedTime;
    double lastDistance;
    
    CLLocationDegrees lastLatitude;
    CLLocationDegrees lastLongitude;
    bool lastOperationWasRefesh;
    
    // Only one refresh at a time
    BOOL performingOperation;
}

- (id) init: CGInstagramDelegate;

- (void) getDataWithLatitude:(CLLocationDegrees) lat longitud:(CLLocationDegrees) lng triggerRefresh:(BOOL)refresh radialDistance:(double)distance;

- (NSString*)printDictionary: (NSDictionary*) dictionary;

- (void)populateEntries: (NSDictionary*)dictionary entriesToBePopulated: (NSMutableArray*) entries isInsidePicture: (BOOL) insidePicutureNode;

@end

@interface CGInstagramDelegate : NSObject
- (void) addDataToView: (NSArray*) data;
@end

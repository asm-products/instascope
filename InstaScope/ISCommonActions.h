//
//  ISCommonActions.h
//  InstaScope
//
//  Created by Javier Porras Luraschi on 10/3/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <CoreLocation/CLPlacemark.h>
#import <CoreLocation/CLGeocoder.h>

@interface ISCommonActions : NSObject

+(void) reportContentForMediaId: (NSString*)mediaId;
+(void) openInInstagramForMediaId: (NSString*)mediaId;

+(void) updateAccessToken: (NSString*)accessToken;
+(void) loadAccessToken;

+(NSInteger) totalLocations;
+(void) removeLocation: (NSUInteger)locationIndex;
+(void) addLocation: (NSString*)name withLatitude: (double)latitude andLongitude: (double)longitude;

+(bool) getSetting: (NSString*)name withDefault: (bool)value;
+(void) saveSetting: (NSString*)name withValue: (bool)value;

+(void) clearTemporaryFiles;

@end

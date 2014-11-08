//
//  ISCommonActions.m
//  InstaScope
//
//  Created by Javier Porras Luraschi on 10/3/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISCommonActions.h"
#import "ISAppDelegate.h"

@implementation ISCommonActions

+(void) reportContentForMediaId: (NSString*)mediaId
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* blockedMediaIds = [defaults objectForKey:@"blockedMediaKeys"];
    NSMutableDictionary* mutableBlockedMediaIds = [[NSMutableDictionary alloc] init];
    
    [mutableBlockedMediaIds addEntriesFromDictionary:blockedMediaIds];
    [mutableBlockedMediaIds setValue:@"" forKey:mediaId];
    
    [defaults setObject:mutableBlockedMediaIds forKey:@"blockedMediaKeys"];
    [defaults synchronize];
}

+(void) openInInstagramForMediaId: (NSString*)mediaId
{
    NSMutableString* instagramUrl = [[NSMutableString alloc] initWithString:@"instagram://media?id="];
    [instagramUrl appendString: mediaId];
    
    NSLog(@"%@", instagramUrl);
    
    NSURL *instagramURL = [NSURL URLWithString:instagramUrl];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

+(void) updateAccessToken: (NSString*)accessToken
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"instagramAccessToken"];
    [defaults synchronize];
    
    [self loadAccessToken];
}

+(void) loadAccessToken
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* instragramAccessToken = [defaults stringForKey:@"instagramAccessToken"];
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.instagramAccessToken = instragramAccessToken;
}

+(int) totalLocations
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* locations = [defaults objectForKey:@"locations"];
    
    return [locations count];
}

+(void) removeLocation: (int)locationIndex
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* locations = [defaults objectForKey:@"locations"];
    
    NSMutableArray* mutableLocations = [[NSMutableArray alloc] init];
    [mutableLocations addObjectsFromArray:locations];
    [mutableLocations removeObjectAtIndex:locationIndex];
    
    [defaults setObject:mutableLocations forKey:@"locations"];
    [defaults synchronize];
}

+(void) addLocation: (NSString*)name withLatitude: (double)latitude andLongitude: (double)longitude {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* locations = [defaults objectForKey:@"locations"];
    NSMutableArray* mutableLocations = [[NSMutableArray alloc] init];
    
    NSDictionary* newLocation = @{
                                  @"name": name,
                                  @"latitude": [NSNumber numberWithDouble: latitude],
                                  @"longitude": [NSNumber numberWithDouble: longitude]
                                  };
    
    [mutableLocations addObject:newLocation];
    [mutableLocations addObjectsFromArray:locations];
    
    [defaults setObject:mutableLocations forKey:@"locations"];
    [defaults synchronize];
}

+(bool) getSetting: (NSString*)name withDefault: (bool)value {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    bool settingValue = [defaults boolForKey:name];

    return settingValue;
}

+(void) saveSetting: (NSString*)name withValue: (bool)value {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    [defaults setBool:value forKey:name];
    [defaults synchronize];
}

+(void) clearTemporaryFiles
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
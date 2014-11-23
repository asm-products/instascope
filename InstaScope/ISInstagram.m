//
//  ISInstagram.m
//  InstaScope
//
//  Created by Javier Luraschi on 10/5/12.
//  Copyright (c) 2012 Javier Luraschi. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "ISInstagram.h"
#import "ISAppDelegate.h"
#import "Flurry.h"

@implementation ISInstagram

- (id) init: CGInstagramDelegate
{
    if (self = [super init])
    {
        delegate = CGInstagramDelegate;
        lastCreatedTime = 0;
        lastDistance = 0;
    }
    
    return self;
}

- (void) getDataWithLatitude:(CLLocationDegrees) lat longitud:(CLLocationDegrees) lng triggerRefresh:(BOOL) refresh radialDistance:(double)distance
{
    if (performingOperation)
    {
        // Block operation until the current one finishes.
        return;
    }
    performingOperation = YES;
    
    // Preserve state
    lastLatitude = lat;
    lastLongitude = lng;
    lastOperationWasRefesh = refresh;
    
    if (lastDistance != distance)
    {
        lastDistance = distance;
        lastCreatedTime = 0;
        mostRecentCreatedTime = 0;
        retryingRefreshForLongerDistance = NO;
    }
    
    ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *accessTokenParams = @"";
    if (appDelegate.instagramAccessToken != nil)
    {
        accessTokenParams = [[NSString alloc] initWithFormat:@"&access_token=%@", appDelegate.instagramAccessToken];
    }
    
    NSString* urlData = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/media/search?distance=%.0f&lat=%f&lng=%f&max_timestamp=%@&client_id=c0511d29e7444c1880abd68b4d55a809%@",
        distance,
        lat,
        lng,
        refresh || lastCreatedTime == 0 ? @"" : [[NSString alloc] initWithFormat:@"%.0f",
        lastCreatedTime],
        accessTokenParams];
    
    NSLog(@"%@", urlData);
    NSURL* url = [NSURL URLWithString:urlData];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSRunLoopCommonModes];
    [connection start];
    
    if (connection) {
        receivedData = [NSMutableData data];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        int remaining = [[dictionary objectForKey:@"X-Ratelimit-Remaining"] intValue];
        if (remaining < 100) {
            ISAppDelegate *appDelegate = (ISAppDelegate *)[UIApplication sharedApplication].delegate;
            
            [Flurry logEvent:@"InstagramApiLowRate"];
            [appDelegate.navigationViewController performSegueWithIdentifier:@"segueToAuth" sender:self];
        }
    }
    
    [receivedData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    UIAlertView * oopsAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Oops!"
//                               message:[error description]
//                               delegate:nil
//                               cancelButtonTitle:@"Bye"
//                               otherButtonTitles:nil];
//    
//    [oopsAlert show];
    NSLog(@"ISInstagram.didFailWithEror: Operation failed: %@", [error description]);
    performingOperation = NO;
    [delegate addDataToView: nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[receivedData length]);
    
    NSError* e = nil;
    NSDictionary* dataDictionary = [NSJSONSerialization JSONObjectWithData: receivedData options: NSJSONReadingMutableContainers error: &e];
    
    NSArray* dataArray = [dataDictionary valueForKey:@"data"];
    NSMutableArray* dataMutableArray = [[NSMutableArray alloc] initWithArray:dataArray];
    
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[receivedData length]);
    
    // Find last created_time
    NSUInteger totalEntries = [dataArray count];
    if (totalEntries > 0)
    {
        NSDictionary* lastEntry = [dataArray objectAtIndex: totalEntries-1];
        NSString* lastCreatedTimeRaw = [lastEntry objectForKey:@"created_time"];
        lastCreatedTime = [lastCreatedTimeRaw doubleValue] - 2000;
        
        NSString* mostRecentCreatedTimeRaw = [lastEntry objectForKey:@"created_time"];
        double newMostRecentCreatedTime = [mostRecentCreatedTimeRaw doubleValue];
        if (!retryingRefreshForLongerDistance && newMostRecentCreatedTime == mostRecentCreatedTime)
        {
            // We refreshed but there was nothing new :( Trying with a wider radialDistance!
            performingOperation = NO;
            
            [self getDataWithLatitude: lastLatitude longitud:lastLongitude triggerRefresh:lastOperationWasRefesh radialDistance: 5000];
            
            return;
        }
        
        mostRecentCreatedTime = newMostRecentCreatedTime;
    }
    
    // Remove blocked content
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* blockedMediaIds = [defaults objectForKey:@"blockedMediaKeys"];
    bool removedElement = false;
    do {
        removedElement = false;
        for (id dataEntry in dataMutableArray) {
            NSString* blockedId = [dataEntry valueForKey:@"id"];
            if ([blockedMediaIds valueForKey:blockedId] != nil) {
                NSLog(@"Blocked media id");
                [dataMutableArray removeObject:dataEntry];
                removedElement = true;
                break;
            }
        }
    } while(removedElement);
    
    performingOperation = NO;
    [delegate addDataToView: dataMutableArray];
}

- (void)populateEntries: (NSDictionary*)dictionary entriesToBePopulated: (NSMutableArray*) entries isInsidePicture: (BOOL) insidePicutureNode
{
    NSArray * allKeys = [dictionary allKeys];
    
    for (NSString * key in allKeys) {
        NSLog(@"%@", key);
        
        if (insidePicutureNode && [key isEqualToString:@"url"])
        {
            id value = [dictionary objectForKey:key];
            [entries addObject:value];
            NSLog(@"%@", value);
        }
        
        BOOL willBeInsidePictureNode = ([key isEqualToString:@"low_resolution"]);
        
        if ([[dictionary objectForKey:key] isKindOfClass:[NSDictionary class]])
        {
            [self populateEntries:[dictionary objectForKey:key] entriesToBePopulated:entries isInsidePicture: willBeInsidePictureNode];
        }
        else if ([[dictionary objectForKey:key] isKindOfClass:[NSArray class]])
        {
            NSArray* dataArray = [dictionary objectForKey:key];
            for (id arrayEntry in dataArray)
            {
                if ([arrayEntry isKindOfClass:[NSDictionary class]])
                {
                    [self populateEntries:arrayEntry entriesToBePopulated:entries isInsidePicture: willBeInsidePictureNode];
                }
            }
        }
    }
}

- (NSString*)printDictionary: (NSDictionary*) dictionary
{
    NSMutableString * outputString = [NSMutableString stringWithCapacity:256];
    NSArray * allKeys = [dictionary allKeys];
    
    for (NSString * key in allKeys) {
        NSLog(@"%@", key);
        
        if ([[dictionary objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            [outputString appendString: [self printDictionary: [dictionary objectForKey:key]]];
        }
        else {
            [outputString appendString: key];
            [outputString appendString: @": "];
            [outputString appendString: [[dictionary objectForKey: key] description]];
        }
        
        [outputString appendString: @"\n"];
    }
    
    return outputString;
}

@end


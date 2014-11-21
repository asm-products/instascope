//
//  ISInstagramEntry.m
//  InstaScope
//
//  Created by Javier Luraschi on 10/5/12.
//  Copyright (c) 2012 Javier Luraschi. All rights reserved.
//

#import "ISInstagramEntry.h"

@implementation ISInstagramEntry

- (id)initWithpictureLowRes:(NSString*) aPicLow pictureThumbnail:(NSString*) aPicThumb instagramMediaId:(NSString*)aMediaId
{
    if (self = [super init])
    {
        pictureUrlLowRes = aPicLow;
        pictureUrlThumbnail = aPicThumb;
        mediaId = aMediaId;
    }
    
    return self;
}

@end

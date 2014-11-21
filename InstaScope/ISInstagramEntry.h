//
//  ISInstagramEntry.h
//  InstaScope
//
//  Created by Javier Luraschi on 10/5/12.
//  Copyright (c) 2012 Javier Luraschi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISInstagramEntry : NSObject
{
    NSString* pictureUrlLowRes;
    NSString* pictureUrlThumbnail;
    NSString* mediaId;
}

- (id)initWithpictureLowRes:(NSString*) aPicLow pictureThumbnail:(NSString*) aPicThumb instagramMediaId:(NSString*)aMediaId;

@end

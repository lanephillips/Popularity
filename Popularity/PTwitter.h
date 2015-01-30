//
//  PTwitter.h
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"

@interface PTwitter : NSObject

+ (instancetype)shared;

- (void)getPostsNearVenue:(Venue*)venue query:(NSString*)query radiusK:(float)radiusK
                  sinceId:(NSString*)sinceId maxId:(NSString*)maxId
               completion:(void(^)(NSArray* posts))completion;

@end

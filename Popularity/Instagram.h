//
//  Instagram.h
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"

@interface Instagram : NSObject

+ (instancetype)shared;

- (void)getPostsNearVenue:(Venue*)venue radiusK:(float)radiusK
                     from:(NSDate*)fromDate to:(NSDate*)toDate
               completion:(void(^)(NSArray* venues))completion;

@end

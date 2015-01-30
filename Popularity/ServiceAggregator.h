//
//  ServiceAggregator.h
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "Venue.h"

extern NSString* const PostsReceivedNotification;
extern NSString* const PostsReceivedVenueKey;
extern NSString* const PostsReceivedPostsKey;

@interface VenuesRequest : NSObject

- (void)cancel;

@end

@interface PostsRequest : NSObject

- (void)cancel;

@end

@interface ServiceAggregator : NSObject

+ (instancetype)shared;

// completion handlers may get called more than once
- (VenuesRequest*)getVenuesInRegion:(MKCoordinateRegion)region completion:(void(^)(NSArray* venues))completion;

- (PostsRequest*)getPostsNearVenue:(Venue*)venue completion:(void(^)(NSArray* posts))completion;

@end

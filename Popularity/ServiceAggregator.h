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

@interface VenuesRequest : NSObject

- (void)cancel;

@end

@interface ServiceAggregator : NSObject

+ (instancetype)shared;

// completion handlers may get called more than once
- (VenuesRequest*)getVenuesInRegion:(MKCoordinateRegion)region completion:(void(^)(NSArray* venues))completion;

- (void)getPostsNearVenue:(Venue*)venue completion:(void(^)(NSArray* posts))completion;
- (void)cancelPostsRequest:(Venue*)venue;

@end

//
//  ServiceAggregator.m
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "ServiceAggregator.h"
#import "PTwitter.h"
#import "Instagram.h"
#import "Foursquare.h"
#import "Yelp.h"

@interface VenuesRequest ()

@property (nonatomic) NSURLSessionDataTask* foursquareTask;
@property (nonatomic) NSURLSessionDataTask* yelpTask;

@end

@implementation ServiceAggregator

+ (instancetype)shared {
    static ServiceAggregator* f = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        f = [[ServiceAggregator alloc] init];
    });
    
    return f;
}

- (VenuesRequest *)getVenuesInRegion:(MKCoordinateRegion)region completion:(void (^)(NSArray *))completion {
    VenuesRequest* r = [[VenuesRequest alloc] init];
    r.foursquareTask = [[Foursquare shared] getVenuesInRegion:region completion:completion];
    r.yelpTask = [[Yelp shared] getVenuesInRegion:region completion:completion];
    return r;
}

- (void)getPostsNearVenue:(Venue *)venue completion:(void (^)(NSArray *))completion {
    // TODO:
}

- (void)cancelPostsRequest:(Venue *)venue {
    // TODO:
}

@end

@implementation VenuesRequest

- (void)cancel {
    [self.foursquareTask cancel];
    self.foursquareTask = nil;
    [self.yelpTask cancel];
    self.yelpTask = nil;
}

@end
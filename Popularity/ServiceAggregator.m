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
#import "AppDelegate.h"

@interface VenuesRequest ()

@property (nonatomic) NSURLSessionDataTask* foursquareTask;
@property (nonatomic) NSURLSessionDataTask* yelpTask;

@end

@interface ServiceAggregator ()

@property (nonatomic) NSMutableDictionary* venueTasks;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.venueTasks = [NSMutableDictionary dictionary];
    }
    return self;
}


- (VenuesRequest *)getVenuesInRegion:(MKCoordinateRegion)region completion:(void (^)(NSArray *))completion {
    VenuesRequest* r = [[VenuesRequest alloc] init];
    r.foursquareTask = [[Foursquare shared] getVenuesInRegion:region completion:completion];
    r.yelpTask = [[Yelp shared] getVenuesInRegion:region completion:completion];
    return r;
}

// TODO: allow nil handler
- (void)getPostsNearVenue:(Venue *)venue completion:(void (^)(NSArray *))completion {
    // TODO: starting from most recent tweet or 7 days ago request as many tweets as possible until we get < limit
    // TODO: ditto for instagram, except I don't know if there is a limit, stop when we get 0
}

- (void)cancelPostsRequest:(Venue *)venue {
    NSMutableArray* tasks = self.venueTasks[[self venueKey:venue]];
    for (NSURLSessionDataTask* task in tasks) {
        [task cancel];
    }
    [self.venueTasks removeObjectForKey:[self venueKey:venue]];
}

- (Post*)mostRecentTweetForVenue:(Venue*)venue {
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fr.predicate = [NSPredicate predicateWithFormat:@"twitterId != NIL AND %@ in venues", venue];
    fr.fetchLimit = 1;
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
    
    NSError* err = nil;
    NSArray* a = [APP.managedObjectContext executeFetchRequest:fr error:&err];
    if (!a) {
        NSLog(@"%@", err);
        return nil;
    }
    return a.firstObject;
}

- (Post*)mostRecentInstagramForVenue:(Venue*)venue {
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fr.predicate = [NSPredicate predicateWithFormat:@"instagramId != NIL AND %@ in venues", venue];
    fr.fetchLimit = 1;
    fr.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
    
    NSError* err = nil;
    NSArray* a = [APP.managedObjectContext executeFetchRequest:fr error:&err];
    if (!a) {
        NSLog(@"%@", err);
        return nil;
    }
    return a.firstObject;
}

- (NSString*)venueKey:(Venue*)venue {
    return [NSString stringWithFormat:@"%@::%@", venue.foursquareId, venue.yelpId];
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
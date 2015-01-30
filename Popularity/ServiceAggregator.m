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
#import "Post.h"

NSString* const PostsReceivedNotification = @"PostsReceivedNotification";
NSString* const PostsReceivedVenueKey = @"PostsReceivedVenueKey";
NSString* const PostsReceivedPostsKey = @"PostsReceivedPostsKey";

@interface VenuesRequest ()

@property (nonatomic) NSURLSessionDataTask* foursquareTask;
@property (nonatomic) NSURLSessionDataTask* yelpTask;

@end

@interface PostsRequest ()

@property (nonatomic) Venue* venue;
@property (nonatomic, copy) void (^completion)(NSArray* posts);

@property (nonatomic) NSMutableArray* gatheredPosts;
@property (nonatomic) NSDate* oneWeekAgo;
@property (nonatomic) NSString* sinceTwitterId;
@property (nonatomic) NSString* maxTwitterId;

@property (nonatomic) NSDate* minInstagramDate;
@property (nonatomic) NSDate* maxInstagramDate;

- (void)startTwitterSearch;
- (void)startInstagramSearch;

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
- (PostsRequest*)getPostsNearVenue:(Venue *)venue completion:(void (^)(NSArray *))completion {
    PostsRequest* pr = [[PostsRequest alloc] init];
    pr.venue = venue;
    pr.completion = completion;
    [pr startTwitterSearch];
    [pr startInstagramSearch];
    return pr;
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

@implementation PostsRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.gatheredPosts = [NSMutableArray array];
        self.oneWeekAgo = [NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 60 * 60];
    }
    return self;
}

- (void)cancel {
    // doesn't seem to be a way to cancel the twitter requests, zero these out and we'll know not to make more requests
    self.venue = nil;
    self.completion = nil;
}

- (void)startTwitterSearch {
    // query for nearby tweets going back in time, until previous most recent tweet
    Post* tweet = [self mostRecentTweetForVenue:self.venue];
    NSString* sinceId = tweet ? tweet.twitterId : nil;
    
    // first find all the tweets within 20 meters of location
    self.sinceTwitterId = sinceId;
    self.maxTwitterId = nil;
    [self runTwitterSearch:@"" radiusK:0.020f completion:^{
        // now try searching the name of the biz within 1km
        self.sinceTwitterId = sinceId;
        self.maxTwitterId = nil;
        [self runTwitterSearch:self.venue.name radiusK:1 completion:^{
            if (self.completion) {
                self.completion(self.gatheredPosts);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:PostsReceivedNotification
                                                                object:self
                                                              userInfo:@{ PostsReceivedVenueKey: self.venue,
                                                                          PostsReceivedPostsKey: self.gatheredPosts }];
        }];
    }];
}

- (void)startInstagramSearch {
    // query for nearby media going back in time, until previous most recent media
    Post* post = [self mostRecentInstagramForVenue:self.venue];
    self.minInstagramDate = post ? post.date : self.oneWeekAgo;
    self.maxInstagramDate = nil;
    
    // instagram doesn't let us query captions, so just get all posts in 20m radius
    [self runInstagramSearchRadiusK:0.020f completion:^{
        if (self.completion) {
            self.completion(self.gatheredPosts);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:PostsReceivedNotification
                                                            object:self
                                                          userInfo:@{ PostsReceivedVenueKey: self.venue,
                                                                      PostsReceivedPostsKey: self.gatheredPosts }];
    }];
}

- (void)runTwitterSearch:(NSString*)query radiusK:(float)radius completion:(void(^)())completion {
    [[PTwitter shared] getPostsNearVenue:self.venue
                                   query:query
                                 radiusK:radius
                                 sinceId:self.sinceTwitterId
                                   maxId:self.maxTwitterId
                              completion:^(NSArray *posts)
     {
         if (!self.venue) {
             // we were cancelled
             return;
         }
         NSLog(@"q: %@, r: %f, since: %@, max: %@, got %lu tweets", query, radius, self.sinceTwitterId, self.maxTwitterId,
               (unsigned long)posts.count);
         
         // TODO: could be some dupes, problem?
         [self.gatheredPosts addObjectsFromArray:posts];
         
         posts = [posts sortedArrayUsingComparator:^NSComparisonResult(Post* obj1, Post* obj2) {
             return [obj1.date compare:obj2.date];
         }];
         //NSLog(@"%@", posts);
         Post* earliest = posts.firstObject;
         
         if (posts.count < 100 ||
             [earliest.date compare:self.oneWeekAgo] == NSOrderedAscending) {
             // either we found all the tweets there are to find, or we've gone back the whole week
             completion();
             return;
         }
         
         // get the next batch earlier than these
         self.maxTwitterId = earliest.twitterId;
         [self runTwitterSearch:query radiusK:radius completion:completion];
     }];
}

- (void)runInstagramSearchRadiusK:(float)radius completion:(void(^)())completion {
    [[Instagram shared] getPostsNearVenue:self.venue
                                  radiusK:radius
                                     from:self.minInstagramDate
                                       to:self.maxInstagramDate
                               completion:^(NSArray *posts)
     {
         if (!self.venue) {
             // we were cancelled
             return;
         }
         NSLog(@"r: %f, from: %@, to: %@, got %lu media", radius, self.minInstagramDate, self.maxInstagramDate,
               (unsigned long)posts.count);
         
         // TODO: could be some dupes, problem?
         [self.gatheredPosts addObjectsFromArray:posts];
         
         posts = [posts sortedArrayUsingComparator:^NSComparisonResult(Post* obj1, Post* obj2) {
             return [obj1.date compare:obj2.date];
         }];
         //NSLog(@"%@", posts);
         Post* earliest = posts.firstObject;
         Post* latest = posts.lastObject;
         NSLog(@"earliest: %@, latest: %@", earliest.date, latest.date);
         
         // I haven't seen Instagram paginate these results, so we're done
         completion();
     }];
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

@end
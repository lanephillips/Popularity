//
//  PTwitter.m
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "PTwitter.h"
#import <TwitterKit/TwitterKit.h>
#import "AppDelegate.h"
#import "Post.h"

@interface PTwitter ()

@property (nonatomic) TWTRGuestSession *twitterSession;

@end

@implementation PTwitter

+ (instancetype)shared {
    static PTwitter* f = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        f = [[PTwitter alloc] init];
    });
    
    return f;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[Twitter sharedInstance] logInGuestWithCompletion:^
         (TWTRGuestSession *session, NSError *error) {
             if (session) {
                 self.twitterSession = session;
             } else {
                 NSLog(@"error: %@", [error localizedDescription]);
                 self.twitterSession = nil;
             }
         }];
    }
    return self;
}

- (void)getPostsNearVenue:(Venue*)venue query:(NSString*)query radiusK:(float)radiusK
                  sinceId:(NSString*)sinceId maxId:(NSString*)maxId
               completion:(void(^)(NSArray* posts))completion {

    if (!self.twitterSession) {
        completion(@[]);
        return;
    }
    
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    
    NSMutableDictionary *params = [ @{@"q": query ?: @"",
                                      @"geocode": [NSString stringWithFormat:@"%@,%@,%fkm", venue.latitude, venue.longitude, radiusK],
                                      @"result_type": @"recent",
                                      @"count": @"100"} mutableCopy];
    if (sinceId.length > 0) {
        params[@"since_id"] = sinceId;
    }
    if (maxId.length > 0) {
        params[@"max_id"] = maxId;
    }
    
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             NSArray* posts = @[];
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 if (!jsonError) {
                     //NSLog(@"%@", json);
                     posts = json[@"statuses"];
                 }
                 else {
                     NSLog(@"Error: %@", jsonError);
                 }
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
             
             NSMutableArray* posts2 = [NSMutableArray arrayWithCapacity:posts.count];
             for (NSDictionary* post in posts) {
                 [posts2 addObject:[self findOrAddTweet:post atVenue:venue]];
             }
             completion(posts2);
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        completion(@[]);
    }
}

- (Post*)findOrAddTweet:(NSDictionary*)tweet atVenue:(Venue*)venue {
    //NSLog(@"%@", tweet);
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fr.predicate = [NSPredicate predicateWithFormat:@"twitterId LIKE %@", tweet[@"id_str"]];
    
    NSError* err = nil;
    NSArray* a = [APP.managedObjectContext executeFetchRequest:fr error:&err];
    if (err) {
        NSLog(@"%@", err);
    }
    
    Post* p = a.firstObject;
    if (!p) {
        NSEntityDescription* ed = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:APP.managedObjectContext];
        p = [[Post alloc] initWithEntity:ed insertIntoManagedObjectContext:APP.managedObjectContext];
    }
    [venue addPostsObject:p];
    
    p.twitterId = tweet[@"id_str"];
    p.text = tweet[@"text"];
    if (tweet[@"geo"] && tweet[@"geo"][@"coordinates"]) {
        p.latitude = @([tweet[@"geo"][@"coordinates"][0] doubleValue]);
        p.longitude = @([tweet[@"geo"][@"coordinates"][1] doubleValue]);
    }
    
    NSDateFormatter *fromTwitter = [[NSDateFormatter alloc] init];
    // here we set the DateFormat  - note the quotes around +0000
    [fromTwitter setDateFormat:@"EEE MMM dd HH:mm:ss '+0000' yyyy"];
    // We need to set the locale to english - since the day- and month-names are in english
    [fromTwitter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
    p.date = [fromTwitter dateFromString:tweet[@"created_at"]];
    
    return p;
}

@end

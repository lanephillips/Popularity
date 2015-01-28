//
//  PTwitter.m
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "PTwitter.h"
#import <TwitterKit/TwitterKit.h>

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

- (void)getPostsNearVenue:(Venue *)venue completion:(void (^)(NSArray *))completion {
    if (!self.twitterSession) {
        completion(@[]);
        return;
    }
    
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{
                             @"q": venue.name,
                             @"geocode": [NSString stringWithFormat:@"%@,%@,1km", venue.latitude, venue.longitude],
                             @"result_type": @"recent",
                             @"count": @"100"
                             };
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
             completion(posts);
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        completion(@[]);
    }
}

@end

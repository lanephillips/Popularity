//
//  Instagram.m
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "Instagram.h"

static const NSString* ClientID = @"645221ed88c34da2bea9cae2bce61904";

@implementation Instagram

+ (instancetype)shared {
    static Instagram* f = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        f = [[Instagram alloc] init];
    });
    
    return f;
}

// TODO: instagram supports foursquare ids
- (void)getPostsNearVenue:(Venue *)venue completion:(void (^)(NSArray *))completion {
    NSDate* oneWeekAgo = [NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 60 * 60];
    NSString* urlStr = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/search"
                        "?client_id=%@&lat=%@&lng=%@&min_timestamp=%llu", ClientID,
                        venue.latitude, venue.longitude, (UInt64)oneWeekAgo.timeIntervalSince1970];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr]
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      NSHTTPURLResponse* httpr = (NSHTTPURLResponse*)response;
                                      NSLog(@"%ld %@", (long)httpr.statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                      
                                      NSArray* venues = @[];
                                      if (error) {
                                          NSLog(@"%@", error);
//                                      } else if (data) {
//                                          NSError* err = nil;
//                                          NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
//                                                                                               options:0 error:&err];
//                                          if (err) {
//                                              NSLog(@"%@", err);
//                                          } else {
//                                              venues = json[@"response"][@"venues"];
//                                          }
                                      }
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          NSMutableArray* ven2 = [NSMutableArray arrayWithCapacity:venues.count];
//                                          for (NSDictionary* dict in venues) {
//                                              [ven2 addObject:[self findOrAddVenue:dict]];
//                                          }
                                          completion(ven2);
                                      });
                                  }];
    [task resume];
}

@end

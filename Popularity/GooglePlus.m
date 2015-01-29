//
//  GooglePlus.m
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "GooglePlus.h"

static const NSString* APIKey = @"AIzaSyCTMVwSm8SmDy-Cl81M0wT5MjNiS3s7Q8E";

@implementation GooglePlus

+ (instancetype)shared {
    static GooglePlus* f = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        f = [[GooglePlus alloc] init];
    });
    
    return f;
}

- (void)getPostsNearVenue:(Venue *)venue completion:(void (^)(NSArray *))completion {
//    NSDate* oneWeekAgo = [NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 60 * 60];
    // TODO: google paginates results
    NSString* urlStr = [NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/activities"
                        "?key=%@&orderBy=recent&maxResults=20&query=%@", APIKey,
                        venue.name];
    
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

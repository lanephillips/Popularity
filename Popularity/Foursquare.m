//
//  Foursquare.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "Foursquare.h"

static const NSString* ClientID = @"1IDYJHMTUEP5TKNHXP2HXQYIIDVAM1FLW0SG5MH3O3WD3D5T";
static const NSString* ClientSecret = @"HX1LI1TBA3T0LIWHYNLVRPVMCSUJWVH4JD3MVRPW1LGEBQ3U";

@implementation Foursquare

+ (instancetype)shared {
    static Foursquare* f = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        f = [[Foursquare alloc] init];
    });
    
    return f;
}

// TODO: intent=browse ? radius?
- (void)getVenuesNear:(CLLocationCoordinate2D)ll radius:(float)radius completion:(void (^)(NSArray *))completion {
    NSString* urlStr = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search"
                        "?client_id=%@&client_secret=%@&ll=%f,%f&v=20150124", ClientID, ClientSecret,
                        ll.latitude, ll.longitude];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr]
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      //NSHTTPURLResponse* httpr = (NSHTTPURLResponse*)response;
                                      //NSLog(@"%ld %@", (long)httpr.statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

                                      NSArray* venues = @[];
                                      if (error) {
                                          NSLog(@"%@", error);
                                      } else if (data) {
                                          NSError* err = nil;
                                          NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                               options:0 error:&err];
                                          if (err) {
                                              NSLog(@"%@", err);
                                          } else {
                                              venues = json[@"response"][@"venues"];
                                          }
                                      }
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          completion(venues);
                                      });
                                  }];
    [task resume];
}

@end

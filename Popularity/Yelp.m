//
//  Yelp.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "Yelp.h"
#import "Venue.h"
#import "NSURLRequest+OAuth.h"
// TODO: I'm not liking this coupling here
#import "AppDelegate.h"

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";

@implementation Yelp

+ (instancetype)shared {
    static Yelp* f = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        f = [[Yelp alloc] init];
    });
    
    return f;
}

- (void)getVenuesInRegion:(MKCoordinateRegion)region completion:(void (^)(NSArray *))completion {
    
    NSURLRequest* request = [NSURLRequest requestWithHost:kAPIHost
                                                     path:kSearchPath
                                                   params:@{ @"bounds": [NSString stringWithFormat:@"%f,%f|%f,%f",
                                                                         region.center.latitude - region.span.latitudeDelta / 2,
                                                                         region.center.longitude - region.span.longitudeDelta / 2,
                                                                         region.center.latitude + region.span.latitudeDelta / 2,
                                                                         region.center.longitude + region.span.longitudeDelta / 2]
                                                             }];
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request
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

//- (Venue*)findOrAddVenue:(NSDictionary*)venue {
//    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
//    fr.predicate = [NSPredicate predicateWithFormat:@"foursquareId LIKE %@", venue[@"id"]];
//    
//    NSError* err = nil;
//    NSArray* a = [APP.managedObjectContext executeFetchRequest:fr error:&err];
//    if (err) {
//        NSLog(@"%@", err);
//    }
//    
//    Venue* v = a.firstObject;
//    if (!v) {
//        NSEntityDescription* ed = [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:APP.managedObjectContext];
//        v = [[Venue alloc] initWithEntity:ed insertIntoManagedObjectContext:APP.managedObjectContext];
//    }
//    
//    v.foursquareId = venue[@"id"];
//    v.name = venue[@"name"];
//    v.latitude = @([venue[@"location"][@"lat"] doubleValue]);
//    v.longitude = @([venue[@"location"][@"lng"] doubleValue]);
//    v.currentFoursquare = @([venue[@"hereNow"][@"count"] integerValue]);
//    
//    return v;
//}

@end

//
//  Foursquare.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "Foursquare.h"
#import "Venue.h"
// TODO: I'm not liking this coupling here
#import "AppDelegate.h"

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

- (void)getVenuesInRegion:(MKCoordinateRegion)region completion:(void (^)(NSArray *))completion {
    // TODO: could narrow categories
    NSString* urlStr = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search"
                        "?client_id=%@&client_secret=%@&ne=%f,%f&sw=%f,%f&intent=browse&v=20150124", ClientID, ClientSecret,
                        region.center.latitude + region.span.latitudeDelta / 2,
                        region.center.longitude + region.span.longitudeDelta / 2,
                        region.center.latitude - region.span.latitudeDelta / 2,
                        region.center.longitude - region.span.longitudeDelta / 2];
    
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
                                          NSMutableArray* ven2 = [NSMutableArray arrayWithCapacity:venues.count];
                                          for (NSDictionary* dict in venues) {
                                              [ven2 addObject:[self findOrAddVenue:dict]];
                                          }
                                          completion(ven2);
                                      });
                                  }];
    [task resume];
}

- (Venue*)findOrAddVenue:(NSDictionary*)venue {
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    fr.predicate = [NSPredicate predicateWithFormat:@"foursquareId LIKE %@", venue[@"id"]];
    
    NSError* err = nil;
    NSArray* a = [APP.managedObjectContext executeFetchRequest:fr error:&err];
    if (err) {
        NSLog(@"%@", err);
    }
    
    Venue* v = a.firstObject;
    if (!v) {
        NSEntityDescription* ed = [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:APP.managedObjectContext];
        v = [[Venue alloc] initWithEntity:ed insertIntoManagedObjectContext:APP.managedObjectContext];
    }
    
    v.foursquareId = venue[@"id"];
    v.name = venue[@"name"];
    v.latitude = @([venue[@"location"][@"lat"] doubleValue]);
    v.longitude = @([venue[@"location"][@"lng"] doubleValue]);
    v.currentFoursquare = @([venue[@"hereNow"][@"count"] integerValue]);
    
    return v;
}

@end

//
//  Instagram.m
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "Instagram.h"
#import "AppDelegate.h"
#import "Post.h"

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
                                      
                                      NSArray* posts = @[];
                                      if (error) {
                                          NSLog(@"%@", error);
                                      }
                                      else if (httpr.statusCode != 200) {
                                          NSLog(@"%ld %@", (long)httpr.statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                      }
                                      else if (data) {
                                          NSError *jsonError;
                                          NSDictionary *json = [NSJSONSerialization
                                                                JSONObjectWithData:data
                                                                options:0
                                                                error:&jsonError];
                                          if (!jsonError) {
                                              posts = json[@"data"];
                                          }
                                          else {
                                              NSLog(@"Error: %@", jsonError);
                                          }
                                      }
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          NSMutableArray* posts2 = [NSMutableArray arrayWithCapacity:posts.count];
                                          for (NSDictionary* post in posts) {
                                              [posts2 addObject:[self findOrAddMedia:post atVenue:venue]];
                                          }
                                          completion(posts2);
                                      });
                                  }];
    [task resume];
}

- (Post*)findOrAddMedia:(NSDictionary*)post atVenue:(Venue*)venue {
    //NSLog(@"%@", post);
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fr.predicate = [NSPredicate predicateWithFormat:@"instagramId LIKE %@", post[@"id"]];
    
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
    
    p.instagramId = post[@"id"];
    if (post[@"caption"] && [post[@"caption"] isKindOfClass:[NSDictionary class]]) {
        p.text = post[@"caption"][@"text"];
    }
    p.date = [NSDate dateWithTimeIntervalSince1970:[post[@"created_time"] doubleValue]];

    if (post[@"location"] && [post[@"location"] isKindOfClass:[NSDictionary class]]) {
        p.latitude = @([post[@"location"][@"latitude"] doubleValue]);
        p.longitude = @([post[@"location"][@"longitude"] doubleValue]);
    }
    
    return p;
}

@end

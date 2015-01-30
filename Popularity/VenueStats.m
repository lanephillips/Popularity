//
//  VenueStats.m
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "VenueStats.h"
#import "AppDelegate.h"

@implementation VenueStats

+ (instancetype)statsForVenue:(Venue *)venue {
    VenueStats* stats = [[VenueStats alloc] init];
    stats.venue = venue;
    [stats analyzePosts];
    return stats;
}

- (void)analyzePosts {
    // count posts in hour buckets
    self.hours = [NSMutableArray arrayWithCapacity:7 * 24];
    NSDate* end = [NSDate date];
    for (NSInteger h = 0; h < 7 * 24; h++) {
        Hour* hour = [[Hour alloc] init];
        hour.start = [NSDate dateWithTimeInterval:-60 * 60 sinceDate:end];
        hour.postsCount = [self countPostsForVenue:self.venue from:hour.start to:end];
        [self.hours addObject:hour];
        end = hour.start;
    }
    
    // TODO: stats
}

- (NSUInteger)countPostsForVenue:(Venue*)venue from:(NSDate*)begin to:(NSDate*)end {
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fr.predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@ AND %@ in venues", begin, end, venue];
    
    NSError* err = nil;
    NSUInteger count = [APP.managedObjectContext countForFetchRequest:fr error:&err];
    if (count == NSNotFound) {
        NSLog(@"%@", err);
        count = 0;
    }
    return count;
}

@end

@implementation Hour

- (float)floatValue {
    return self.postsCount;
}

@end
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

    NSArray* sorted = [self.hours sortedArrayUsingComparator:^NSComparisonResult(Hour* obj1, Hour* obj2) {
        if (obj1.postsCount < obj2.postsCount) {
            return NSOrderedAscending;
        }
        if (obj1.postsCount > obj2.postsCount) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    // for each hour count the number of hours with less activity
    NSUInteger lessCount = 0;
    NSUInteger sameCount = 0;
    NSUInteger sameLevel = 0;
    for (Hour* h in sorted) {
        if (h.postsCount > sameLevel) {
            lessCount += sameCount;
            sameLevel = h.postsCount;
            sameCount = 0;
        }
        sameCount++;
        h.percentile = lessCount / (float)sorted.count;
    }
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

- (float)barHeight {
    return self.postsCount;
}

- (float)barColor {
    return self.percentile;
}

@end
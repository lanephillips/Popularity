//
//  VenueStats.h
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"
#import "Post.h"
#import "BarChartView.h"

@interface Hour : NSObject<Bar>

@property (nonatomic) NSDate* start;
@property (nonatomic) NSUInteger postsCount;
@property (nonatomic) float percentile;

@end

@interface VenueStats : NSObject

@property (nonatomic) Venue* venue;
@property (nonatomic) NSMutableArray* hours;

+ (instancetype)statsForVenue:(Venue*)venue;

@end

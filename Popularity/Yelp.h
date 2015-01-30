//
//  Yelp.h
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface Yelp : NSObject

+ (instancetype)shared;

- (NSURLSessionDataTask*)getVenuesInRegion:(MKCoordinateRegion)region completion:(void(^)(NSArray* venues))completion;

@end

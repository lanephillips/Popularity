//
//  Foursquare.h
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface Foursquare : NSObject

+ (instancetype)shared;

- (void)getVenuesNear:(CLLocationCoordinate2D)ll radius:(float)radius completion:(void(^)(NSArray* venues))completion;

@end

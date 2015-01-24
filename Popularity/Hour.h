//
//  Hour.h
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Business;

@interface Hour : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * facebook;
@property (nonatomic, retain) NSNumber * twitter;
@property (nonatomic, retain) NSNumber * swarm;
@property (nonatomic, retain) NSNumber * yelp;
@property (nonatomic, retain) Business *business;

@end

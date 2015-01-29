//
//  Post.h
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Venue;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * twitterId;
@property (nonatomic, retain) NSString * instagramId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *venues;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addVenuesObject:(Venue *)value;
- (void)removeVenuesObject:(Venue *)value;
- (void)addVenues:(NSSet *)values;
- (void)removeVenues:(NSSet *)values;

@end

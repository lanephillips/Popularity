//
//  Business.h
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Venue : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * foursquareId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSOrderedSet *checkins;

@end

@interface Venue (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inCheckinsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCheckinsAtIndex:(NSUInteger)idx;
- (void)insertCheckins:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCheckinsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCheckinsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceCheckinsAtIndexes:(NSIndexSet *)indexes withCheckins:(NSArray *)values;
- (void)addCheckinsObject:(NSManagedObject *)value;
- (void)removeCheckinsObject:(NSManagedObject *)value;
- (void)addCheckins:(NSOrderedSet *)values;
- (void)removeCheckins:(NSOrderedSet *)values;

@end

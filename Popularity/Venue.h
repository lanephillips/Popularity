//
//  Venue.h
//  Popularity
//
//  Created by Lane Phillips on 1/28/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Venue : NSManagedObject

@property (nonatomic, retain) NSNumber * currentFoursquare;
@property (nonatomic, retain) NSString * foursquareId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * yelpId;
@property (nonatomic, retain) NSOrderedSet *posts;
@end

@interface Venue (CoreDataGeneratedAccessors)

- (void)insertObject:(Post *)value inPostsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPostsAtIndex:(NSUInteger)idx;
- (void)insertPosts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePostsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPostsAtIndex:(NSUInteger)idx withObject:(Post *)value;
- (void)replacePostsAtIndexes:(NSIndexSet *)indexes withPosts:(NSArray *)values;
- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSOrderedSet *)values;
- (void)removePosts:(NSOrderedSet *)values;
@end

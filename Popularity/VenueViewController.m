//
//  BusinessViewController.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "VenueViewController.h"
#import "AppDelegate.h"
#import "PTwitter.h"
#import "Instagram.h"
#import "Post.h"
#import "BarChartView.h"

@interface VenueViewController ()

@property (weak, nonatomic) IBOutlet UILabel *venueLbl;
@property (weak, nonatomic) IBOutlet UILabel *checkinLbl;
@property (weak, nonatomic) IBOutlet UITextView *debugTextView;
@property (weak, nonatomic) IBOutlet BarChartView *barChart;

@end

@implementation VenueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.barChart prepareForInterfaceBuilder]; // random bars
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.venueLbl.text = self.venue.name;
    self.checkinLbl.text = [NSString stringWithFormat:@"%@ checkins", self.venue.currentFoursquare];
    
    self.debugTextView.text = @"";
    [[PTwitter shared] getPostsNearVenue:self.venue completion:^(NSArray *posts) {
        [self analyzePosts];
    }];
    [[Instagram shared] getPostsNearVenue:self.venue completion:^(NSArray *posts) {
        [self analyzePosts];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat longer = MAX(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.barChart.barWidth = longer / self.barChart.bars.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)analyzePosts {
    // count posts in hour buckets
    NSMutableArray* buckets = [NSMutableArray arrayWithCapacity:7 * 24];
    NSDate* end = [NSDate date];
    for (NSInteger h = 0; h < 7 * 24; h++) {
        NSDate* begin = [NSDate dateWithTimeInterval:-60 * 60 sinceDate:end];
        [buckets addObject:@([self countPostsBetween:begin and:end])];
        end = begin;
    }
    self.barChart.bars = buckets;
    
//    NSMutableString* s = [NSMutableString string];
//    for (Post* post in self.venue.posts) {
//        [s appendFormat:@"%@ %@\n", post.date, post.text];
//    }
//    self.debugTextView.text = s;
}

- (NSUInteger)countPostsBetween:(NSDate*)begin and:(NSDate*)end {
    NSFetchRequest* fr = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    fr.predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", begin, end];
    
    NSError* err = nil;
    NSUInteger count = [APP.managedObjectContext countForFetchRequest:fr error:&err];
    if (count == NSNotFound) {
        NSLog(@"%@", err);
        count = 0;
    }
    return count;
}

@end

//
//  VenueViewController.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "VenueViewController.h"
#import "AppDelegate.h"
#import "ServiceAggregator.h"
#import "Post.h"
#import "BarChartView.h"
#import "VenueStats.h"

@interface VenueViewController ()

@property (weak, nonatomic) IBOutlet UILabel *venueLbl;
@property (weak, nonatomic) IBOutlet UILabel *checkinLbl;
@property (weak, nonatomic) IBOutlet UILabel *percentileLbl;
@property (weak, nonatomic) IBOutlet UITextView *debugTextView;
@property (weak, nonatomic) IBOutlet BarChartView *barChart;

@property (nonatomic) VenueStats* stats;
@property (nonatomic) id postsObserver;

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
    
    self.debugTextView.text = @"";

    self.stats = [VenueStats statsForVenue:self.venue];
    [self showAllPosts];
    
    self.postsObserver = [[NSNotificationCenter defaultCenter] addObserverForName:PostsReceivedNotification
                                                                           object:nil
                                                                            queue:[NSOperationQueue mainQueue]
                                                                       usingBlock:^(NSNotification *note)
                          {
                              //NSLog(@"got more");
                              self.stats = [VenueStats statsForVenue:self.venue];
                              [self showAllPosts];
                          }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self.postsObserver];
    self.postsObserver = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // bar width is constant so the whole week fits in the longer dimension
    CGFloat longer = MAX(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.barChart.barWidth = longer / self.barChart.bars.count;
    
//    self.debugTextView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.barChart.bounds), 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setStats:(VenueStats *)stats {
    _stats = stats;
    self.barChart.bars = stats.hours;
    
    NSMutableString* checkinText = [NSMutableString string];
    if (self.venue.currentFoursquare.integerValue >= 0) {
        [checkinText appendFormat:@"%@ Foursquare checkins\n", self.venue.currentFoursquare];
    }
    
    Hour* lastHour = stats.hours.firstObject;
    [checkinText appendFormat:@"%lu recent posts on Instagram and Twitter", (unsigned long)lastHour.postsCount];
    self.checkinLbl.text = checkinText;
    
    self.percentileLbl.text = [NSString stringWithFormat:@"%.0f%%", lastHour.percentile];
}

- (void)showAllPosts {
    NSArray* allPosts = [[self.venue.posts allObjects] sortedArrayUsingComparator:^NSComparisonResult(Post* obj1, Post* obj2) {
        return [obj2.date compare:obj1.date];   // newest first
    }];
    
    NSMutableString* s = [NSMutableString string];
    for (Post* p in allPosts) {
        if (p.text.length > 0) {
            [s appendFormat:@"%@\n\n", p.text];
        }
    }
    self.debugTextView.text = s;
}

@end

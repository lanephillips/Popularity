//
//  VenueViewController.m
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
#import "VenueStats.h"

@interface VenueViewController ()

@property (weak, nonatomic) IBOutlet UILabel *venueLbl;
@property (weak, nonatomic) IBOutlet UILabel *checkinLbl;
@property (weak, nonatomic) IBOutlet UITextView *debugTextView;
@property (weak, nonatomic) IBOutlet BarChartView *barChart;

@property (nonatomic) VenueStats* stats;

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
    // TODO: need some sort of notification system
    self.stats = [VenueStats statsForVenue:self.venue];
    self.barChart.bars = self.stats.hours;
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

@end

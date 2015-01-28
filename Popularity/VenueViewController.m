//
//  BusinessViewController.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "VenueViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "AppDelegate.h"

@interface VenueViewController ()

@property (weak, nonatomic) IBOutlet UILabel *venueLbl;
@property (weak, nonatomic) IBOutlet UILabel *checkinLbl;
@property (weak, nonatomic) IBOutlet UITextView *debugTextView;

@end

@implementation VenueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.venueLbl.text = self.venue.name;
    self.checkinLbl.text = [NSString stringWithFormat:@"%@ checkins", self.venue.currentFoursquare];
    
    self.debugTextView.text = @"";
    [self searchFacebookNearVenu:self.venue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - nearby activity

- (void)searchTwitterNearVenu:(Venue*)venue {
    if (!APP.twitterSession) {
        return;
    }

    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{
                             @"q": venue.name,
                             @"geocode": [NSString stringWithFormat:@"%@,%@,1km", venue.latitude, venue.longitude],
                             @"result_type": @"recent",
                             @"count": @"100"
                             };
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 if (!jsonError) {
                     NSLog(@"%@", json);
                     
                     NSMutableString* s = [NSMutableString string];
                     for (NSDictionary* tweet in json[@"statuses"]) {
                         [s appendFormat:@"%@\n", tweet[@"text"]];
                     }
                     self.debugTextView.text = s;
                 }
                 else {
                     NSLog(@"Error: %@", jsonError);
                 }
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

- (void)searchFacebookNearVenu:(Venue*)venue {
    [FBRequestConnection startWithGraphPath:@"me/events?fields=cover,name,start_time"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Sucess! Include your code to handle the results here
                                  NSLog(@"user events: %@", result);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"%@", error);
                              }
                          }];
}

@end

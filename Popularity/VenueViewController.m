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
    
    if (APP.twitterSession) {
        NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/show.json";
        NSDictionary *params = @{@"id" : @"20"};
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
                     NSLog(@"%@", json);
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

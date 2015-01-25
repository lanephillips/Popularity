//
//  ViewController.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "ViewController.h"
#import "Foursquare.h"
@import CoreLocation;
@import MapKit;

@interface ViewController ()
<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) CLLocationManager* locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doCenter:(id)sender {
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self getLocation];
    }
}

- (void)getLocation {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // TODO: start a spinner
    [self.locationManager startUpdatingLocation];
}

#pragma mark - location delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self getLocation];
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    NSLog(@"got location: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
    // TODO: save last map location for startup next time
    
    // go ahead and update the map
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.map regionThatFits:viewRegion];
    self.map.showsUserLocation = YES;
    [self.map setRegion:adjustedRegion animated:YES];
    
    // but wait until we have a fresh result to run the query
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        [self.locationManager stopUpdatingLocation];
        
        [[Foursquare shared] getVenuesInRegion:adjustedRegion completion:^(NSArray *venues) {
            // TODO: put on map
            NSLog(@"%@", venues);
            
            
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [self.locationManager stopUpdatingLocation];
}

@end

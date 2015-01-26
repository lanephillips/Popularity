//
//  ViewController.m
//  Popularity
//
//  Created by Lane Phillips on 1/24/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "ViewController.h"
#import "Foursquare.h"
#import "Venue.h"
@import CoreLocation;
@import MapKit;

@interface Venue (MapKit) <MKAnnotation>

@end

@interface ViewController ()
<CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) CLLocationManager* locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.map.delegate = self;
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
    
    // wait until we have a fresh result to update the map
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        [self.locationManager stopUpdatingLocation];
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500);
        MKCoordinateRegion adjustedRegion = [self.map regionThatFits:viewRegion];
        self.map.showsUserLocation = YES;
        [self.map setRegion:adjustedRegion animated:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - map view delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [[Foursquare shared] getVenuesInRegion:mapView.region completion:^(NSArray *venues) {
        // TODO: put on map
        //NSLog(@"%@", venues);
        
        for (Venue* v in venues) {
            [self.map addAnnotation:v];
        }
    }];
}

@end

@implementation Venue (MapKit)

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (NSString *)title {
    return self.name;
}

@end

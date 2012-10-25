//
//  MapViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/9/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "MapViewController.h"
#import "CheckinViewController.h"
#import "SFNativeRestAppDelegate.h"
#import "AppDelegate.h"

@implementation MapViewController

@synthesize mapView = _mapView, checkinButton = _checkinButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_locationManager == nil){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 10.0f;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
        
    [_locationManager startUpdatingLocation];
    
    _mapView.showsUserLocation = YES;
    
    [self setupNavbar];
    
}

- (void)viewDidUnload
{
    _mapView = nil;
    _checkinButton = nil;
}

- (void)dealloc
{
    [_mapView release];
    [_checkinButton release];
    
    [super dealloc];
}

- (void)setupNavbar
{
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Map"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    UIBarButtonItem *checkinBtn = [[UIBarButtonItem alloc]initWithTitle:@"Checkin" style:UIBarButtonItemStyleBordered target:self action:@selector(performCoordinateGeocode:)];
    [self.navigationItem setRightBarButtonItem:checkinBtn];
    [checkinBtn release];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    [logoutButton release];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // we have received our current location, so enable the "Get Current Address" button
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.01;
    mapRegion.span.longitudeDelta = 0.01;
    
    [_mapView setRegion:mapRegion animated: YES];
    
    _currentLocation = [userLocation coordinate];
    
    [_checkinButton setEnabled:YES];
}

- (IBAction)performCoordinateGeocode:(id)sender
{
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    
    CLLocationCoordinate2D coord = _currentLocation;
    
    CLLocation *location = [[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude] autorelease];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            [self displayError:error];
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
        
        [self displayCheckin:placemarks];

    }];
}

- (void)displayCheckin:(NSArray *)placemarks
{
    CheckinViewController *cvc = [[CheckinViewController alloc] initWithNibName:@"CheckinViewController" bundle:nil];
    
    [cvc setPlacemarks:placemarks];
    
    [self.navigationController pushViewController:cvc animated:YES];
    [cvc release];
}

- (void)logout {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app logout];
    [app login];
}

- (void)displayError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled: message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            default: message = [error description];
                break;
        }
        
        UIAlertView *alert =  [[[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil] autorelease];;
        [alert show];
    });   
}

#pragma mark - CLLocationManagerDelegate

- (void)startUpdatingCurrentLocation
{
    NSLog(@"startUpdatingCurrentLocation");
}


- (void)stopUpdatingCurrentLocation
{
    NSLog(@"stopUpdatingCurrentLocation");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation");
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    NSLog(@"%@", error);
    
    [self stopUpdatingCurrentLocation];
    
    _currentLocation = kCLLocationCoordinate2DInvalid;
    
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    alert.title = @"Error updating location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

@end

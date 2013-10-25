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
#import "Annotation.h"

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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString* ShopAnnotationIdentifier = @"shopAnnotationIdentifier";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ShopAnnotationIdentifier];
    if (!pinView) {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ShopAnnotationIdentifier] autorelease];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
    }
    return pinView;
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
    mapRegion.span.latitudeDelta = 0.05;
    mapRegion.span.longitudeDelta = 0.05;
    
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

- (void)getUsersCustom
{
	SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];
    [request setEndpoint:@"/services/"];
    
    NSString *pathString = [NSString stringWithFormat:@"/services/apexrest/jgifford/UserLocations"];
    
    request.path = pathString;
    
    _startTime = [[NSDate date] retain];

    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)getUsersNative
{
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"select id, firstname, lastname, jgifford__latitude__c, jgifford__longitude__c from user"];
    
    _startTime = [[NSDate date] retain];

    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    _endTime = [NSDate date];
    
    double milliseconds = (double)[_endTime timeIntervalSinceDate:_startTime];
    NSLog(@"Milliseconds: %f",milliseconds);
    NSString *time = [NSString stringWithFormat:@"%f milliseconds",milliseconds];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Response Time" message: [NSString stringWithFormat:@"%f milliseconds",milliseconds] delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [self writeToLogFile:time];
}

-(void) writeToLogFile:(NSString*)content{
    content = [NSString stringWithFormat:@"%@\n",content];
    
    //get the documents directory:
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [NSString stringWithFormat:@"%@/results.txt", documentsDirectory];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (fileHandle){
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else{
        [content writeToFile:fileName
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
}

- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


- (void)displayCheckin:(NSArray *)placemarks
{
    CheckinViewController *cvc = [[CheckinViewController alloc] initWithNibName:@"CheckinViewController" bundle:nil];
    
    [cvc setPlacemarks:placemarks];
    
    [self.navigationController pushViewController:cvc animated:YES];
    [cvc release];
}

- (void)logout {
    UIAlertView *alert =  [[[UIAlertView alloc] initWithTitle:@"Please Confirm!"
                                                      message:@"Are you sure you want to log out?"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:@"Cancel",nil] autorelease];
    [alert setTag:123];
    [alert show];

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app logout];
        [app login];
    }
    
    return;
}

- (IBAction)locateFriends:(id)sender {
    [self setAnnotations];

    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    if ([[button title] isEqualToString:@"Find Coworkers"]) {
        [self getUsersNative];
    } else {
        [self getUsersCustom];
    }
}

- (void)setAnnotations {
    id userLocation = [_mapView userLocation];
    for (NSArray *annotation in _mapView.annotations) {
        if ((id)annotation != userLocation) {
            [_mapView removeAnnotation:(id<MKAnnotation>)annotation];
        }
    }
    
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = 37.78584545;
    ctrpoint.longitude =-122.40652160;
    Annotation *addAnnotation = [[Annotation alloc] initWithCoordinate:ctrpoint];
    [addAnnotation setTitle:@"Prakash"];
    [addAnnotation setSubtitle:@"Dandapani"];
    [_mapView addAnnotation:addAnnotation];
    [addAnnotation release];
    
    ctrpoint.latitude = 37.8267;
    ctrpoint.longitude =-122.4233;
    addAnnotation = [[Annotation alloc] initWithCoordinate:ctrpoint];
    [addAnnotation setTitle:@"Jason"];
    [addAnnotation setSubtitle:@"Barker"];
    [_mapView addAnnotation:addAnnotation];
    [addAnnotation release];
    
    ctrpoint.latitude = 37.8025;
    ctrpoint.longitude =-122.4058;
    addAnnotation = [[Annotation alloc] initWithCoordinate:ctrpoint];
    [addAnnotation setTitle:@"John"];
    [addAnnotation setSubtitle:@"Lyne"];
    [_mapView addAnnotation:addAnnotation];
    [addAnnotation release];
    
    ctrpoint.latitude = 37.7833365;
    ctrpoint.longitude =-122.4026377;
    addAnnotation = [[Annotation alloc] initWithCoordinate:ctrpoint];
    [addAnnotation setTitle:@"Mark"];
    [addAnnotation setSubtitle:@"Benioff"];
    [_mapView addAnnotation:addAnnotation];
    [addAnnotation release];
}

@end

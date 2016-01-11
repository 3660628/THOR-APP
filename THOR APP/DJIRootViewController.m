//
//  DJIRootViewController.m
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/6/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "DJIRootViewController.h"

@interface DJIRootViewController ()
@property (nonatomic, assign)BOOL isEditingPoints;
@end

@implementation DJIRootViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initDrone];
}

//initialize UI status bar
-(void)initUI
{
    self.modeLabel.text = @"Mode: N/A";
    self.gpsLabel.text = @"GPS: 0";
    self.vsLabel.text = @"VS: 0.0 M/S";
    self.hsLabel.text = @"HS: 0.0 M/S";
    self.altitudeLabel.text = @"Alt: 0 M";
}

-(void)initDrone
{
    //test when connecting to Drone simulation and drone
    
    self.phantomDrone = [[DJIDrone alloc]initWithType:DJIDrone_Phantom3Advanced];
    self.phantomDrone.delegate = self;
    
    self.navigationManager = self.phantomDrone.mainController.navigationManager;
    self.navigationManager.delegate = self;
    
    self.phantomMainController = (DJIPhantom3AdvancedMainController *)self.phantomDrone.mainController;
    self.phantomMainController.mcDelegate = self;
    
    [self registerApp];
    
}

-(void)registerApp
{
    //regesiter succeeded
    NSString *appKey = @"ae1ba4d5b0c6ce707e4ecc6d";
    [DJIAppManager registerApp:appKey withDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Before view appears, must initialize location manager
    [self startUpdateLocation];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    
    [self.phantomDrone.mainController stopUpdateMCSystemState];
    [self.phantomDrone disconnectToDrone];
}

-(void)initData
{
    self.mapview.delegate = self;
    
    self.droneLocation = kCLLocationCoordinate2DInvalid;
    self.userLocation = kCLLocationCoordinate2DInvalid;
    
    self.mapcontroller = [[DJIMapController alloc]init];
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addWaypoints:)];
    [self.mapview addGestureRecognizer:self.tapGesture];
}

#pragma mark DJIAppManagerDelegate Method
-(void)appManagerDidRegisterWithError:(int)error
{
    NSString *message = @"Register App Success!";
    if(error != RegisterSuccess) {
        message = @"Register App Failed! Please enter your app key and check the network";
    }
    else {
        [self.phantomDrone connectToDrone];
        [self.phantomDrone.mainController startUpdateMCSystemState];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Register App" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark DJIMainControllerDelegate Method
-(void)mainController:(DJIMainController *)mc didUpdateSystemState:(DJIMCSystemState *)state
{
    self.droneLocation = state.droneLocation;
    
    if(!state.isMultipleFlightModeOpen) {
        [self.phantomMainController setMultipleFlightModeOpen:YES withResult:nil];
    }
    
    self.modeLabel.text = state.flightModeString;
    self.gpsLabel.text = [NSString stringWithFormat:@"%d", state.satelliteCount];
    self.vsLabel.text = [NSString stringWithFormat:@"%0.1f M/S", state.velocityZ];
    self.hsLabel.text = [NSString stringWithFormat:@"%0.1f M/S", (sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY))];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%0.1f M", state.altitude];
    
    [self.mapcontroller updateAircraftLocation:self.droneLocation withMapview:self.mapview];
    double radianYaw = (state.attitude.yaw * M_PI/180);
    [self.mapcontroller updateAircraftHeading:radianYaw];
}

-(void)enterNavigationMode
{
    [self.navigationManager enterNavigationModeWithResult:^(DJIError *error) {
        if(error.errorCode != ERR_Succeeded) {
            NSString *message = [NSString stringWithFormat:@"Enter Navigation Mode Failed:%@", error.errorDescription];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Navigation Mode" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSString *message = @"Enter Navigation Mode Success";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Navigation Mode" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            [self enterNavigationMode];
        }
    }];
}

#pragma mark DJIDroneDelegate Method
-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if(status == ConnectionSucceeded) {
        [self enterNavigationMode];
    }
}


-(BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark CLLocation Methods
-(void) startUpdateLocation
{
    if([CLLocationManager locationServicesEnabled]) {
        if(self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc]init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 0.1;
            if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            [self.locationManager startUpdatingLocation];
        }
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services not available" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)focusMapAction:(id)sender
{
    //change to self.droneLocation, when connecting to Drone
    if(CLLocationCoordinate2DIsValid(self.userLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.userLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapview setRegion:region animated:YES];
    }
}

#pragma mark CLLocationManager Delgate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    self.userLocation = location.coordinate;
}

#pragma mark Custom Methods

-(void)addWaypoints:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.mapview];
    if(tapGesture.state == UIGestureRecognizerStateEnded) {
        if(self.isEditingPoints) {
            [self.mapcontroller addPoint:point withMapView:self.mapview];
        }
    }
}

-(IBAction)editButtonAction:(id)sender
{
    if(self.isEditingPoints) {
        [self.mapcontroller cleanAllPointsWithMapView:self.mapview];
        [self.editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else {
        [self.editBtn setTitle:@"Reset" forState:UIControlStateNormal];
    }
    
    self.isEditingPoints = !self.isEditingPoints;
}

#pragma mark MKMapViewDelegate Method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Pin_Annotation"];
        pinView.pinTintColor = [UIColor purpleColor];
        return  pinView;
        
    }
    //if its a DJIAnnotation, make it the aircraft image
    else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]]) {
        DJIAircraftAnnotationView *annoView = [[DJIAircraftAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Aircraft_Annotation"];
        ((DJIAircraftAnnotation*)annotation).annotationView = annoView;
        return annoView;
    }
    return nil;
}

@end
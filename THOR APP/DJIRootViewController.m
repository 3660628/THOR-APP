//
//  DJIRootViewController.m
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/6/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "DJIRootViewController.h"
#import "DJIGSButtonViewController.h"
#import "DJIWaypointConfigViewController.h"

#define kEnterNaviModeFailedAlertTag 1001


@interface DJIRootViewController ()<DJIGSButtonViewControllerDelegate, DJIWaypointConfigViewControllerDelegate>
@property (nonatomic, assign)BOOL isEditingPoints;
@property (nonatomic, strong)DJIGSButtonViewController *gsButtonVC;
@property (nonatomic, strong)DJIWaypointConfigViewController *waypointConfigVC;
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
    //Initialize Header Drone Status Info
    self.modeLabel.text = @"Mode: N/A";
    self.gpsLabel.text = @"GPS: 0";
    self.vsLabel.text = @"VS: 0.0 M/S";
    self.hsLabel.text = @"HS: 0.0 M/S";
    self.altitudeLabel.text = @"Alt: 0 M";
    
    //Initialize Ground Station Button View Controller
    self.gsButtonVC = [[DJIGSButtonViewController alloc]initWithNibName:@"DJIGSButtonViewController" bundle:[NSBundle mainBundle]];
    [self.gsButtonVC.view setFrame:CGRectMake(0, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.gsButtonVC.view.frame.size.width, self.gsButtonVC.view.frame.size.height)];
    self.gsButtonVC.delegate = self;
    [self.view addSubview:self.gsButtonVC.view];
    
    //Initialize Waypoint View Controller
    self.waypointConfigVC = [[DJIWaypointConfigViewController alloc]initWithNibName:@"DJIWaypointConfigViewController" bundle:[NSBundle mainBundle]];
    self.waypointConfigVC.view.alpha = 0;
    
    self.waypointConfigVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    CGFloat configVCOriginX = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.waypointConfigVC.view.frame))/2;
    CGFloat configVCOriginY = CGRectGetHeight(self.topBarView.frame) + CGRectGetMinY(self.topBarView.frame) + 8;
    [self.waypointConfigVC.view setFrame:CGRectMake(configVCOriginX, configVCOriginY, CGRectGetWidth(self.waypointConfigVC.view.frame), CGRectGetHeight(self.waypointConfigVC.view.frame))];
    
    //if using an iPAD, center Waypoint View Controller
    if( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.waypointConfigVC.view.center = self.view.center;
    }
    //if using a iPhone, center Waypoint View Controller
    else if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.waypointConfigVC.view.center = self.view.center;
    }
    
    self.waypointConfigVC.delegate = self;
    [self.view addSubview:self.waypointConfigVC.view];
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
    
    self.waypointMission = self.navigationManager.waypointMission;
    
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

#pragma mark DJIWaypointConfigViewControllerDelegate Methods
-(void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    __weak DJIRootViewController *weakSelf = self;
    
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
}

-(void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    __weak DJIRootViewController *weakSelf = self;
    
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
    for(int i = 0; i<self.waypointMission.waypointCount; i++) {
        DJIWaypoint *waypoint = [self.waypointMission waypointAtIndex:i];
        waypoint.altitude = [self.waypointConfigVC.altitudeTextField.text floatValue];
    }
    
    //Setting entered parameters to be uploaded from WaypointController
    self.waypointMission.maxFlightSpeed = [self.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
    self.waypointMission.autoFlightSpeed = [self.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
    self.waypointMission.finishedAction = (DJIWaypointMissionFinishedAction)self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex;
    
    //
    if(self.waypointMission.isValid) {
        if(weakSelf.uploadViewProgress == nil) {
            weakSelf.uploadViewProgress = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:weakSelf.uploadViewProgress animated:YES completion:nil];
        }
        
        [self.waypointMission setUploadProgressHandler:^(uint8_t progress) {
            [weakSelf.uploadViewProgress setTitle:@"Mission Uploading"];
            NSString *message = [NSString stringWithFormat:@"%d%%", progress];
            [weakSelf.uploadViewProgress setMessage:message];
        }];
        
        [self.waypointMission uploadMissionWithResult:^(DJIError *error) {
            
            [weakSelf.uploadViewProgress setTitle:@"Mission Upload Finished"];
            
            if(error.errorCode != ERR_Succeeded) {
                [weakSelf.uploadViewProgress setTitle:@"Mission Invalid"];
            }
            
            [weakSelf.waypointMission setUploadProgressHandler:nil];
            [weakSelf performSelector:@selector(hideProgressView) withObject:nil afterDelay:3.0];
            
            [weakSelf.waypointMission startMissionWithResult:^(DJIError *error) {
                if(error.errorCode != ERR_Succeeded) {
                    NSString *message = @"Start Mission Failed";
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Start Mission Failed" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
            
        }];
    }
    else {
        UIAlertController *invalidMissionAlert = [UIAlertController alertControllerWithTitle:@"Waypoint Mission Failed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [invalidMissionAlert addAction:okAction];
        [self presentViewController:invalidMissionAlert animated:YES completion:nil];
    }
}

-(void)hideProgressView
{
    if(self.uploadViewProgress) {
        [self.uploadViewProgress dismissViewControllerAnimated:YES completion:nil];
        self.uploadViewProgress = nil;
    }
}

#pragma mark GroundStationDelegate
-(void) groundStation:(id<DJIGroundStation>)gs didExecuteWithResult:(GroundStationExecuteResult *)result
{
    if(result.currentAction == GSActionStart) {
        if(result.executeStatus == GSExecStatusFailed) {
            [self hideProgressView];
            NSLog(@"Mission Start Failed...");
        }
    }
    if(result.currentAction == GSActionUploadTask) {
        if(result.executeStatus == GSExecStatusFailed) {
            [self hideProgressView];
            NSLog(@"Upload Mission Failed");
        }
    }
}

-(void) groundStation:(id<DJIGroundStation>)gs didUploadWaypointMissionWithProgress:(uint8_t)progress
{
    if(self.uploadViewProgress == nil) {
        self.uploadViewProgress = [UIAlertController alertControllerWithTitle:@"Mission Uploading" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:self.uploadViewProgress animated:YES completion:nil];
    }
    
    NSString *message = [NSString stringWithFormat:@"%d%%", progress];
    [self.uploadViewProgress setMessage:message];
}

#pragma mark DJIGSButtonViewController Delegate Methods
-(void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.waypointMission stopMissionWithResult:^(DJIError *error) {
        if(error == ERR_Succeeded) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Stop Mission Success" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}
-(void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.mapcontroller cleanAllPointsWithMapView:self.mapview];
}
-(void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self focusMap];
}
-(void)configBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    __weak DJIRootViewController *weakSelf = self;
    
    //waypoints array, from the waypoints places and stored by mapcontroller
    NSArray *wayPoints = self.mapcontroller.waypoints;
    
    if(wayPoints == nil || wayPoints.count < DJIWaypointMissionMinimumWaypointCount) {
        NSString *message = @"Not enough waypoints for mission";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not enough waypoints for mission" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //checks current GPS satellite lock, which is being updated by didUpdateSystemState using the mainController, in a perfect route, GPS satellite count must be 10
    //only check not in simulation
//    int satelliteCountBeforeMission = [self.gpsLabel.text intValue];
//    if(satelliteCountBeforeMission < 6) {
//        NSString *message = @"Not enough satellites locked in for safe flight";
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not enough satellites locked in for safe flight" message:message preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {}];
//        [alert addAction:okAction];
//        [self presentViewController:alert animated:YES completion:nil];
//        return;
//    }
    
    
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.waypointConfigVC.view.alpha = 1.0;
    }];
    
    [self.waypointMission removeAllWaypoints];
    
    for(int i = 0; i<wayPoints.count; i++) {
        CLLocation *location = [wayPoints objectAtIndex:i];
        if(CLLocationCoordinate2DIsValid(location.coordinate)) {
            DJIWaypoint *waypoint = [[DJIWaypoint alloc] initWithCoordinate:location.coordinate];
            [self.waypointMission addWaypoint:waypoint];
        }
    }
}
-(void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.waypointMission startMissionWithResult:^(DJIError *error) {
        if(error.errorCode != ERR_Succeeded) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Start Mission Failed" message:error.errorDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}
-(void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if(mode == DJIGSViewMode_EditMode) {
        [self focusMap];
    }
}
-(void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if(self.isEditingPoints) {
        self.isEditingPoints = NO;
        [button setTitle:@"Add" forState:UIControlStateNormal];
    }
    else {
        self.isEditingPoints = YES;
        [button setTitle:@"Finished" forState:UIControlStateNormal];
    }
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

-(void)focusMap
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
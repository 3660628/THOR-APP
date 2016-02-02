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
#import "ImageViewController.h"

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

-(void)registerApp
{
    //regesiter succeeded
    NSString *appKey = @"ae1ba4d5b0c6ce707e4ecc6d";
    [DJIAppManager registerApp:appKey withDelegate:self];
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
    self.batteryLabel.text = @"Power Level: ?";
    self.batteryPercentage.text = @"Battery: ?%";
    
    //Initialize Ground Station Button View Controller
    self.gsButtonVC = [[DJIGSButtonViewController alloc]initWithNibName:@"DJIGSButtonViewController" bundle:[NSBundle mainBundle]];
    [self.gsButtonVC.view setFrame:CGRectMake(0, self.topBarView.frame.origin.y + self.topBarView.frame.size.height + 260, self.gsButtonVC.view.frame.size.width, self.gsButtonVC.view.frame.size.height)];
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
    
    //Edit top nav bar and status labels
    UIColor *myColorBlue = [UIColor colorWithRed:45/255.0 green:188/255.0 blue:220/255.0 alpha:1.0];
    self.topBarView.barTintColor = myColorBlue;
    self.modeLabel.textColor = [UIColor whiteColor];
    self.gpsLabel.textColor = [UIColor whiteColor];
    self.hsLabel.textColor = [UIColor whiteColor];
    self.vsLabel.textColor = [UIColor whiteColor];
    self.altitudeLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"thorbar.png"]];
    
}

-(void)initData
{
    self.mapview.delegate = self;
    //self.mapview.mapType = MKMapTypeSatellite;
    self.mapview.mapType = MKMapTypeSatelliteFlyover;
    self.mapview.showsBuildings = YES;
    self.mapCamera = [[MKMapCamera alloc]init];

    self.droneLocation = kCLLocationCoordinate2DInvalid;
    self.userLocation = kCLLocationCoordinate2DInvalid;
    
    self.mapcontroller = [[DJIMapController alloc]init];
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addWaypoints:)];
    [self.mapview addGestureRecognizer:self.tapGesture];
}

-(void)initDrone
{
    //test when connecting to Drone simulation and drone
    
    self.phantomDrone = [[DJIDrone alloc]initWithType:DJIDrone_Phantom3Professional];
    self.phantomDrone.delegate = self;
    
    self.navigationManager = self.phantomDrone.mainController.navigationManager;
    self.navigationManager.delegate = self;
    
    self.phantomMainController = (DJIPhantom3ProMainController *)self.phantomDrone.mainController;
    self.phantomMainController.mcDelegate = self;
    
    self.waypointMission = self.navigationManager.waypointMission;
    
    self.cameraMain = (DJIPhantom3ProCamera *)_phantomDrone.camera;
    self.cameraMain.delegate = self;
    
    [self registerApp];
    
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
    
    
    
    //enter in constant altitude that was entered in WaypointVC in for all the waypoints on mission
    for(int i = 0; i<self.waypointMission.waypointCount; i++) {
        DJIWaypoint *waypoint = [self.waypointMission waypointAtIndex:i];
        waypoint.altitude = [self.waypointConfigVC.altitudeTextField.text floatValue];
    }
    
    //Setting entered parameters to be uploaded from WaypointController into a "WaypointMission"
    //Waypoint Missions are uploaded to drone
    self.waypointMission.maxFlightSpeed = [self.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
    self.waypointMission.autoFlightSpeed = [self.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
    
    //Heading Mode during mission
    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
    
    //Should select Go Home or None right now
    self.waypointMission.finishedAction = (DJIWaypointMissionFinishedAction)self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex;
    
    //The drone will move from waypoint to waypoint in a straight line
    self.waypointMission.flightPathMode = DJIWaypointMissionFlightPathNormal;
    
    //Enter in action (take picture) linked with each waypoint add to waypoint mission
    //Take picture at every waypoint set
    for(int i = 0; i<self.waypointMission.waypointCount; i++) {
        DJIWaypointAction *snapPicture = [[DJIWaypointAction alloc]initWithActionType:DJIWaypointActionStartTakePhoto param:0];
        DJIWaypoint *waypoint = [self.waypointMission waypointAtIndex:i];
        [waypoint addAction:snapPicture];
    }
    
    //Should store waypoint missions between sessions, this way we can find the optimal mission for image stitching, and then load that mission, NSMutable Array
    
    
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

#pragma  mark CameraDelegate Methods
-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState
{
    
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

//Config launches view to enter parameters for the upcoming waypoint mission
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
    
    /***********
     Safety Checks before takeoff/User can enter flight parameters
     Comment out when testing with Simulation
     1. Must have greater than 6 satellites locked in
     2. GPS Signal should be 2 or above in order for it to go home after mission is finished
     3. Battery level should be above 40% for a mission
     ********/
    
    /***
    if(self.gpsSatelliteCount < 6) {
        NSString *message = @"Not enough satellites locked in for safe flight";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not enough satellites locked in for safe flight" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if(self.gpsSignalLevel == GpsSignalLevel0 && self.gpsSignalLevel == GpsSignalLevel1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Weak GPS Signal" message:@"Retry when stronger signal" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
     
    if(self.batteryInfo.remainPowerPercent < 40) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not enough battery %" message:@"recharge battery" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
     ***/
    
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
        [self.cameraMain startCameraSystemStateUpdates];
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
    
    [self.batteryInfo updateBatteryInfo:^(DJIError *error) {
        if(error.errorCode == ERR_Succeeded) {
            self.batteryPercentage.text = [NSString stringWithFormat:@"%ld", (long)self.batteryInfo.remainPowerPercent];
        }
    }];
    
    self.modeLabel.text = state.flightModeString;
    self.gpsLabel.text = [NSString stringWithFormat:@"%d", state.satelliteCount];
    self.gpsSatelliteCount = state.satelliteCount;
    self.vsLabel.text = [NSString stringWithFormat:@"%0.1f M/S", state.velocityZ];
    self.hsLabel.text = [NSString stringWithFormat:@"%0.1f M/S", (sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY))];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%0.1f M", state.altitude];
    self.batteryLabel.text = [NSString stringWithFormat:@"%0d", state.powerLevel];
    self.gpsSignalLevel = state.gpsSignalLevel;
    
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
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self enterNavigationMode];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
            [alert addAction:retryAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSString *message = @"Enter Navigation Mode Success";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Navigation Mode" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark DJIDroneDelegate Method
//add more detailed connection info
-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if(status == ConnectionSucceeded) {
        [self enterNavigationMode];
    }
    else if (status == ConnectionFailed ) {
        NSString *message = @"Connection Failed";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection to Drone" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if(status == ConnectionStartConnect) {
        NSString *message = @"Connection Reconnect";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Try Reconnecting" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if(status == ConnectionBroken) {
        NSString *message = @"Connection Broken";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Try Reconnecting" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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
        //For 3D maps, center location by camera, rather than region
        self.mapCamera.centerCoordinate = self.userLocation;
        self.mapCamera.pitch = 45;
        self.mapCamera.heading = 45;
        self.mapCamera.altitude = 250;
        [self.mapview setCamera:self.mapCamera animated:YES];
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
            CLLocationCoordinate2D coordinate = [self.mapview convertPoint:point toCoordinateFromView:self.mapview];
            CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            CLLocation *userLocationTemp = [[CLLocation alloc]initWithLatitude:self.userLocation.latitude longitude:self.userLocation.longitude];
            CLLocationDistance meters = [location distanceFromLocation:userLocationTemp];
            //With Wifi extender there is a 2000m range, so do not allow user to place unacceptable waypoints that would cause the drone to go out of range
            if(meters < 1000) {
                [self.mapcontroller addPoint:point withMapView:self.mapview];
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Out of Range" message:@"Pick closer Waypoint" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action ) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

#pragma mark MKMapViewDelegate Method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    UIColor *myColorBlue = [UIColor colorWithRed:45/255.0 green:188/255.0 blue:220/255.0 alpha:1.0];
    if([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Pin_Annotation"];
        pinView.pinTintColor = myColorBlue;
        return pinView;
        
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
//
//  DJIRootViewController.h
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/6/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <Mapkit/Mapkit.h>
#import <DJISDK/DJISDK.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIMapController.h"


@interface DJIRootViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, DJIDroneDelegate, DJIMainControllerDelegate, DJIAppManagerDelegate, GroundStationDelegate, DJINavigationDelegate, DJICameraDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UINavigationBar *topBarView;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) DJIMapController *mapcontroller;
@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (atomic) DJIGpsSignalLevel gpsSignalLevel;
@property (atomic) int gpsSatelliteCount;
@property (atomic) int powerLevel;
@property (atomic) long powerPercent;
@property (nonatomic, strong) MKMapCamera *mapCamera;

//status bar labels
@property (nonatomic, strong) IBOutlet UILabel *modeLabel;
//gpsLabel measures amount of satellites locked in
@property (nonatomic, strong) IBOutlet UILabel *gpsLabel;
@property (nonatomic, strong) IBOutlet UILabel *hsLabel;
@property (nonatomic, strong) IBOutlet UILabel *vsLabel;
@property (nonatomic, strong) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *batteryPercentage;

@property (weak, nonatomic) IBOutlet UIView *batterySymbol;
@property (weak, nonatomic) IBOutlet UIView *batterySymbolBackground;
@property (weak, nonatomic) IBOutlet UIView *batteryBorder;

@property(nonatomic, strong) DJIBattery *batteryInfo;
@property(nonatomic, strong) DJIDrone *phantomDrone;
@property(nonatomic, strong) DJIPhantom3ProMainController *phantomMainController;
@property(nonatomic, strong)DJIPhantom3ProCamera *cameraMain;

@property(nonatomic, weak) NSObject<DJINavigation> *navigationManager;
@property(nonatomic, weak) NSObject<DJIWaypointMission> *waypointMission;
@property(nonatomic, strong) UIAlertController *uploadViewProgress;

-(void) startUpdateLocation;

@end



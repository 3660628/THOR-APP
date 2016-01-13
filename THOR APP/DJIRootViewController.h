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

@interface DJIRootViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, DJIDroneDelegate, DJIMainControllerDelegate, DJIAppManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UINavigationBar *topBarView;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) DJIMapController *mapcontroller;

//status bar labels
@property (nonatomic, strong) IBOutlet UILabel *modeLabel;
@property (nonatomic, strong) IBOutlet UILabel *gpsLabel;
@property (nonatomic, strong) IBOutlet UILabel *hsLabel;
@property (nonatomic, strong) IBOutlet UILabel *vsLabel;
@property (nonatomic, strong) IBOutlet UILabel *altitudeLabel;

@property(nonatomic, strong) DJIDrone *phantomDrone;
@property(nonatomic, strong) DJIPhantom3AdvancedMainController *phantomMainController;
@property(nonatomic, weak) NSObject<DJINavigation> *navigationManager;

@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;


@end



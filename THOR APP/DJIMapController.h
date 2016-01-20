//
//  DJIMapController.h
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/6/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DJIAircraftAnnotation.h"

@interface DJIMapController : NSObject

@property (strong, nonatomic) NSMutableArray *editPoints;
@property (nonatomic, strong) DJIAircraftAnnotation *aircraftAnnotation;

//Add Waypoints to the Map
- (void)addPoint:(CGPoint)point withMapView:(MKMapView *)mapview;

//Remove all Waypoints on the map
- (void)cleanAllPointsWithMapView:(MKMapView *)mapview;

//Current edit Points
//@ return Return as NSarray containing multiple CClocation objects
- (NSArray *)waypoints;

//Update Aircraft's location in mapview
-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapview:(MKMapView *)mapView;

//Update Aircraft's Heading in mapview
-(void)updateAircraftHeading:(float)heading;

@property (nonatomic, strong) UIViewController *alertController;


@end

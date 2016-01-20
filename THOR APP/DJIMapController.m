//
//  DJIMapController.m
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/6/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "DJIMapController.h"
#import "DJIRootViewController.h"

@implementation DJIMapController

//initializer will set editPoints mutable array to an empty mutable array
-(instancetype)init
{
    if(self = [super init]) {
        self.editPoints = [[NSMutableArray alloc] init];
    }
    return self;
}



-(void)addPoint:(CGPoint)point withMapView:(MKMapView *)mapview
{
    CLLocationCoordinate2D coordinate = [mapview convertPoint:point toCoordinateFromView:mapview];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [_editPoints addObject:location];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = location.coordinate;
    [mapview addAnnotation:annotation];
    
}

-(void)cleanAllPointsWithMapView:(MKMapView *)mapview
{
    [_editPoints removeAllObjects];
    NSArray *annos = [NSArray arrayWithArray:mapview.annotations];
    for( int i = 0; i< annos.count; i++) {
        id<MKAnnotation> ann = [annos objectAtIndex:i];
        //make sure not to remove the Aircraft annotation marker
        if(![ann isEqual:self.aircraftAnnotation]) {
            [mapview removeAnnotation:ann];
        }
    }
    
}

-(NSArray *)waypoints
{
    return self.editPoints;
}

-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapview:(MKMapView *)mapView
{
    if( self.aircraftAnnotation == nil) {
        self.aircraftAnnotation = [[DJIAircraftAnnotation alloc]initWithCoordinate:location];
        [mapView addAnnotation:self.aircraftAnnotation];
    }
    
    [self.aircraftAnnotation setCoordinate:location];
}

-(void)updateAircraftHeading:(float)heading
{
    if(self.aircraftAnnotation) {
        [self.aircraftAnnotation updateHeading:heading];
    }
}

@end

//
//  DJIAircraftAnnotation.h
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/8/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DJIAircraftAnnotationView.h"

@interface DJIAircraftAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) DJIAircraftAnnotationView* annotationView;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

-(void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(void) updateHeading:(float)heading;

@end

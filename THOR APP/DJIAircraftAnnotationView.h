//
//  DJIAircraftAnnotationView.h
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/8/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIAircraftAnnotationView : MKAnnotationView

-(void) updateHeading:(float)heading;

@end

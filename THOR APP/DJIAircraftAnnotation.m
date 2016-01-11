//
//  DJIAircraftAnnotation.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/10/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "DJIAircraftAnnotation.h"

@implementation DJIAircraftAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

-(void)updateHeading:(float)heading
{
    if (self.annotationView) {
        [self.annotationView updateHeading:heading];
    }
}
@end
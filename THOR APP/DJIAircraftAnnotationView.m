//
//  DJIAircraftAnnotationView.m
//  THOR_APP
//
//  Created by Dan Vasilyonok on 1/8/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "DJIAircraftAnnotationView.h"

@implementation DJIAircraftAnnotationView

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifiers
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifiers];
    if (self) {
        self.enabled = NO;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"aircraft.png"];
    }
    
    return self;
}

-(void) updateHeading:(float)heading
{
    self.transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformMakeRotation(heading);
}

@end

//
//  DJIWaypointConfigViewController.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/12/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "DJIWaypointConfigViewController.h"

@interface DJIWaypointConfigViewController ()

@end

@implementation DJIWaypointConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initUI
{
    self.altitudeTextField.text = @"100";
    self.autoFlightSpeedTextField.text = @"8";
    self.maxFlightSpeedTextField.text = @"10";
    
    //set finish action to DJIWaypointMissionFinishedGoHome
    [self.actionSegmentedControl setSelectedSegmentIndex:1];
    //set the headingMode to DJIWaypointMissionHeadingAuto
    [self.headingSegmentedControl setSelectedSegmentIndex:0];
}

- (IBAction)cancelBtnAction:(id)sender
{
    if([_delegate respondsToSelector:@selector(cancelBtnActionInDJIWaypointConfigViewController:)]) {
        [_delegate cancelBtnActionInDJIWaypointConfigViewController:self];
    }
}

- (IBAction)finishBtnAction:(id)sender
{
    if( [_delegate respondsToSelector:@selector(finishBtnActionInDJIWaypointConfigViewController:)]) {
        [_delegate finishBtnActionInDJIWaypointConfigViewController:self];
    }
}
@end

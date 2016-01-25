//
//  ImageViewController.h
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/16/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface ImageViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *processBtn;

-(IBAction)onDownloadButtonClicked:(id)sender;


@property (strong, nonatomic) DJIPhantom3ProCamera *cameraDownload;
@property(strong,nonatomic) DJIDrone *phantomDroneTwo;
@property(strong,nonatomic) NSMutableArray *imageArray;
@property(strong,nonatomic) UIAlertController *downloadProgressAlert;


@end

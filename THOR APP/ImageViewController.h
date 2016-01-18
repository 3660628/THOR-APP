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

-(IBAction)onDownloadButtonClicked:(id)sender;

@property (strong, nonatomic) DJIPhantom3ProCamera *camera;
@property(strong,nonatomic) NSMutableArray *imageArray;
@property(strong,nonatomic) UIAlertController *downloadProgressAlert;


@end

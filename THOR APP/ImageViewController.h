//
//  ImageViewController.h
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/16/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@property(strong,nonatomic) NSMutableArray *imageArray;


-(IBAction)onDownloadButtonClicked:(id)sender;


@end

//
//  ImageStitchingViewController.h
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/21/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageStitchingViewController : UIViewController

@property(strong, nonatomic) NSMutableArray *imageArray;
@property(strong, nonatomic)IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;




@end

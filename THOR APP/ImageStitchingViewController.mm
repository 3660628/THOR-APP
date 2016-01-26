//
//  ImageStitchingViewController.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/21/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "ImageStitchingViewController.h"
#import "Stitching.h"
#import "OpenCVConversion.h"

@interface ImageStitchingViewController ()

@end

@implementation ImageStitchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]init];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cv::Mat stitchMat;
        
        //Find out how to call this function in the cloud
        //Perhaps using AWS Lambda function to execute in cloud
        //If I can do this, then no need to compress images, because image processing no
        //longer done locally
        
        //run AWS lamda function in response to uploading image array into S3 bucket
        [Stitching stitchImageWithArray:_imageArray andResult:stitchMat];
        
        UIImage *stitchImage = [OpenCVConversion UIImageFromCVMat:stitchMat];
        UIImageWriteToSavedPhotosAlbum(stitchImage, nil, nil, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
            _imageView.image = stitchImage;
        });
    });
}

@end

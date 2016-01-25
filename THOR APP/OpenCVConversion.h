//
//  OpenCVConversion.h
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/25/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OpenCVConversion : NSObject

//conver UIImage to cv::Mat
+(cv::Mat)cvMatFromUIImage:(UIImage *)image;

//convert UIImage to gray cv::Mat
+(cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

//convert UIImage to cv::Mat without alpha channel
+(cv::Mat)cvmat3FromUIImage:(UIImage *)image;

//convert cv::Mat to UIImage
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
@end

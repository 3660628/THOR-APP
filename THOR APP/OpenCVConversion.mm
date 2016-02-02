//
//  OpenCVConversion.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/25/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "OpenCVConversion.h"

@implementation OpenCVConversion

+(cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    //8 bits per component, 1 channel(s)
    cv::Mat cvMat(rows, cols, CV_8UC1);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                     //Pointer to data
                                                    cols,                           //Width of bitMap
                                                    rows,                           //Height of bitMap
                                                    8,                              //bits per component
                                                    cvMat.step[0],                  //bytes per row
                                                    colorSpace,                     //colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);     //bitMaps info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0,0,cols,rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;

}

+(cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    //8 bits per component, 1 channel(s)
    cv::Mat cvMat(rows, cols, CV_8UC1);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                     //Pointer to data
                                                    cols,                           //Width of bitMap
                                                    rows,                           //Height of bitMap
                                                    8,                              //bits per component
                                                    cvMat.step[0],                  //bytes per row
                                                    colorSpace,                     //colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);     //bitMaps info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0,0,cols,rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+(cv::Mat)cvmat3FromUIImage:(UIImage *)image
{
    cv::Mat result = [self cvMatFromUIImage:image];
    //cv::cvtColor(result, result, CV_RGBA2RGB);
    return result;
}

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if(cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    //Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,             //width
                                        cvMat.rows,             //height
                                        8,                      //bits per component
                                        8*cvMat.elemSize(),     //bits per pixel
                                        cvMat.step[0],          //bytes per row
                                        colorSpace,             //colorspace
                                        kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault,  //bitmap        info
                                        provider,               //CGDataProviderRef
                                        NULL,                   //decode
                                        false,                  //should interpolate
                                        kCGRenderingIntentDefault   //intent
                                        );
    
    //Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end

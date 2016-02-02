//
//  Stitching.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/25/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "Stitching.h"

#define COMPRESS_RATIO 0.2

@implementation Stitching

+(bool)stitchImageWithArray:(NSMutableArray *)imageArray andResult:(cv::Mat &)result
{
    NSMutableArray *compressedImageArray = [NSMutableArray new];
    for(UIImage *rawImage in imageArray) {
        UIImage *compressedImage = [self compressedToRatio:rawImage ratio:COMPRESS_RATIO];
        [compressedImageArray addObject:compressedImage];
    }
    [imageArray removeAllObjects];
    
    if([compressedImageArray count] == 0) {
        NSLog(@"imageArray is empty");
        return false;
    }
    
    cv::vector<cv::Mat> matArray;
    
    for(id image in compressedImageArray) {
        if([image isKindOfClass:[UIImage class]]) {
            cv::Mat matImage = [OpenCVConversion cvmat3FromUIImage:image];
            matArray.push_back(matImage);
        }
    }
    
    
    NSLog(@"Stitching...");
    if(!stitch(matArray, result)) {
        return false;
    }
    
    return true;
}

//while testing locally, compress images
+(UIImage *)compressedToRatio:(UIImage *)img ratio:(float)ratio
{
    CGSize compressedSize;
    compressedSize.width = img.size.width*ratio;
    compressedSize.height = img.size.height*ratio;
    UIGraphicsBeginImageContext(compressedSize);
    [img drawInRect:CGRectMake(0, 0, compressedSize.width, compressedSize.height)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImage;
}

@end

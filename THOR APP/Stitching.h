//
//  Stitching.h
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/25/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenCVConversion.h"
#import "StitchingWrapper.h"

@interface Stitching : NSObject

+(bool)stitchImageWithArray:(NSMutableArray *)imageArray andResult:(cv::Mat &)result;

@end

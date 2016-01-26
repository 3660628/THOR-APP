//
//  StitchingWrapper.hpp
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/25/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#ifndef StitchingWrapper_h
#define StitchingWrapper_h

//returns if stitching is succesful or not
bool stitch(const cv::vector <cv::Mat> & images, cv::Mat &result);

#endif

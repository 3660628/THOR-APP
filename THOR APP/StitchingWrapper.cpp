//
//  StitchingWrapper.cpp
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/25/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#include "StitchingWrapper.h"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/stitching/stitcher.hpp"
#include <iostream>

using namespace cv;

/***
Actual stitching done here in wrapper

The OpenCV Stitcher class default works for a rotating camera, but
in this case we are stitching aerial imagery
so we must fly high enough so that height of objects very small in relation to flying height
to have a better approximation of a planar scene, should take "nadir" shots(
shots taken towards the center of the earth)
 
To accomplish the above, set warper to PlaneWarper for aerial shots,
and use Surf Feature Finder

***/
bool stitch(const cv::vector <cv::Mat> & images, cv::Mat &result)
{
    Stitcher stitcher = Stitcher::createDefault(false);
    
    //For aerial imagery
    stitcher.setWarper(new PlaneWarper());
    stitcher.setFeaturesFinder(new detail::SurfFeaturesFinder(1000,3,4,3,4));
    stitcher.setRegistrationResol(0.1);
    stitcher.setSeamEstimationResol(0.1);
    stitcher.setCompositingResol(1);
    stitcher.setPanoConfidenceThresh(1);
    stitcher.setWaveCorrection(true);
    stitcher.setWaveCorrectKind(detail::WAVE_CORRECT_HORIZ);
    stitcher.setFeaturesMatcher(new detail::BestOf2NearestMatcher(false,0.3));
    stitcher.setBundleAdjuster(new detail::BundleAdjusterRay());
    
    Stitcher::Status status = Stitcher::ERR_NEED_MORE_IMGS;
    try {
        status = stitcher.stitch(images, result);
    }
    catch (cv::Exception e) {}
    
    //std::cout << status << std::endl;
    if(status != Stitcher::OK) {
        return false;
    }
    
    return true;
}
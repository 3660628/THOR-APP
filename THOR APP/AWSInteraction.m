//
//  AWSIdentityManager.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 2/1/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "AWSInteraction.h"

@implementation AWSInteraction

-(instancetype)init
{
    if(self == [super init]) {
        //To begin interaction with AWS S3, need transfer manager client, entry point into S3 API
        self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    }
    return self;
}

-(void)setUpIdentity
{
    //Initialize Amazon Cognito Credentials
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:30a77d75-4c46-4712-8dba-ce47f8403f0f"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    //Retreieve unique id for current user
    NSString *cognitoId = credentialsProvider.identityId;
    
}

-(void)downloadImageFromS3
{
    //download path
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-image1.JPG"];
    //location where it will be downloaded
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    //download request
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    //set up download request with bucket name, image name, and location to download
    downloadRequest.bucket = @"imagesgraminor";
    downloadRequest.key = @"image1.JPG";
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    //Download file
    [[self.transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if(task.error) {
            if([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch(task.error.code) {
                        case AWSS3TransferManagerErrorCancelled:
                        case AWSS3TransferManagerErrorPaused:
                            break;
                        default:
                            NSLog(@"Error: %@", task.error);
                            break;
                }
            }
            else {
                //Unknown error
                NSLog(@"Error: %@", task.error);
            }
        }
        if(task.result) {
            AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
            //File download success
        }
        return nil;
    }];
}

-(void)uploadImageToS3
{
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    //create upload request
    NSURL *testFileURL = [[NSURL alloc]init];
    uploadRequest.bucket = @"imagesgraminor";
    uploadRequest.key = @"testFile.txt";
    uploadRequest.body = testFileURL;
    
    //upload File using transferManager, and pass uploadRequest
    [[self.transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if(task.error) {
            if([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch(task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                    
                        default:
                            NSLog(@"Error: %@", task.error);
                            break;
                }
            }
            else {
                //Unknown error
                NSLog(@"Error: %@", task.error);
            }
        }
        
        if(task.result) {
            AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
            //File upload success
        }
        return nil;
    }];
}

@end

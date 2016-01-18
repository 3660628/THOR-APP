//
//  ImageViewController.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/16/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "ImageViewController.h"
#import <DJISDK/DJISDK.h>

#import "THOR_APP-Swift.h"

@interface ImageViewController () <DJICameraDelegate> {
    __block int _selectedPhotoNumber;
    __block NSMutableData *_downloadedFileData;
    __block long totalFileSize;
    __block NSString *targetFileName;
}

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"thorbar.png"]];
  
    UIColor *myColorGreen = [UIColor colorWithRed:104/255.0 green:175/255.0 blue:97/255.0 alpha:1.0];
    self.downloadBtn.backgroundColor = myColorGreen;
    [self.downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Update number of selected Photos
-(void) camera:(DJICamera *)camera didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState
{
    _selectedPhotoNumber = playbackState.numbersOfSelected;
}

-(void) camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState
{
    
}

//Enter Playback mode, allows user to select photos
//Currently Not entered into setCameraWorkMode loop
- (IBAction)onDownloadButtonClicked:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [_camera setCameraWorkMode:CameraWorkModePlayback withResult:^(DJIError *error){
        if(error.errorCode == ERR_Succeeded) {
            [weakSelf selectPhotos];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Work Mode" message:@"Enter Playback mode failed" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:okAction];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    }];
}

-(void)selectPhotos
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.camera enterMultiplePreviewMode];
        sleep(1);
        [self.camera enterMultipleEditMode];
        sleep(1);
        
        [self.camera selectAllFilesInPage];
        [self downloadPhotos];
    });
}

-(void)downloadPhotos
{
    __block int finishedFileCount = 0;
    __weak typeof(self) weakSelf = self;
    __block NSTimer *timer;
    _imageArray = [NSMutableArray new];
    
    [_camera downloadAllSelectedFilesWithPreparingBlock:^(NSString* fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL *skip) {
        totalFileSize = (long)fileSize;
        targetFileName = fileName;
        _downloadedFileData = [NSMutableData new];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showDownloadProgressAlert];
            [weakSelf.downloadProgressAlert setTitle:[NSString stringWithFormat:@"Download:%d", finishedFileCount + 1]];
            [weakSelf.downloadProgressAlert setMessage:[NSString stringWithFormat:@"FileName:%@ FileSize:%0.1fKB Downloaded:0.0KB", fileName, fileSize/1024.0]];
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDownloadProgress) userInfo:nil repeats:YES];
            [timer fire];
            
        });
    } dataBlock:^(NSData *data, NSError *error) {
        [_downloadedFileData appendData:data];
    } completionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [timer invalidate];
            finishedFileCount++;
            if(finishedFileCount >= _selectedPhotoNumber) {
                [self.downloadProgressAlert dismissViewControllerAnimated:YES completion:nil];
                self.downloadProgressAlert = nil;
                [_camera setCameraWorkMode:CameraWorkModeCapture withResult:nil];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Download (%d)", finishedFileCount] message:@"download Finished" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            UIImage *downloadPhoto = [UIImage imageWithData:_downloadedFileData];
            [_imageArray addObject:downloadPhoto];
            UIImageWriteToSavedPhotosAlbum(downloadPhoto, nil, nil, nil);
        });
    }];
}

-(void)updateDownloadProgress
{
    [self.downloadProgressAlert setMessage:[NSString stringWithFormat:@"FileName:%@ FileSize:%0.1fKB Downloaded:%0.1fKB", targetFileName, totalFileSize/1024.0, _downloadedFileData.length/1024.0]];
}

-(void)showDownloadProgressAlert
{
    if(self.downloadProgressAlert == nil) {
        self.downloadProgressAlert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:self.downloadProgressAlert animated:YES completion:nil];
    }
}

@end

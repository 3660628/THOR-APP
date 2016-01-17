//
//  ImageViewController.m
//  THOR APP
//
//  Created by Dan Vasilyonok on 1/16/16.
//  Copyright © 2016 Dan Vasilyonok. All rights reserved.
//

#import "ImageViewController.h"
#import <DJISDK/DJISDK.h>

@interface ImageViewController () <DJICameraDelegate> {
    __block int _selectedPhotoNumber;
}
@property (strong, nonatomic) DJIPhantom3AdvancedCamera *camera;
//@property (strong, nonatomic) DJIPhantom3ProCamera *camera;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Enter Playback mode, allows user to select photos
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
        //[self.camera enterMultiplePreviewMode];
        sleep(1);
        //[self.camera enterMultipleEditMode];
        sleep(1);
    });
}

@end

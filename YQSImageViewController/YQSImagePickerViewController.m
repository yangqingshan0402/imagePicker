//
//  LKRecordVideoViewController.m
//  EZFun2
//
//  Created by jason Yang on 2017/8/9.
//  Copyright © 2017年 lenkeng. All rights reserved.
//

#import "YQSImagePickerViewController.h"
#import "GPUImage.h"
#import "UIViewExt.h"
#import "YQSPlayVideoViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "YQSImagePrefix.pch"
#import "ViewController.h"
#import "GPUImageBeautifyFilter.h"
#import "YQSImageMovieWriter.h"

@interface YQSImagePickerViewController ()

@property (nonatomic , strong) GPUImageVideoCamera* videoCamera;
@property (nonatomic , strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic , strong) YQSImageMovieWriter* movieWriter;
@property (nonatomic , strong) NSTimer* timer;
@property (nonatomic , strong) UIButton* recordButton;
@property (nonatomic , assign) NSInteger time;
@property (nonatomic , strong) UILabel* timerLabel;
@property (nonatomic, strong) CMMotionManager* motionManager;
@property (nonatomic, assign)UIDeviceOrientation orientationNew;
@property (nonatomic, strong)UIView* preview;
@property (nonatomic, strong)UIButton* cancelButton;
@property (nonatomic, strong)UIButton* switchCameraButton;

@property (nonatomic , assign) BOOL recording;

@end

@implementation YQSImagePickerViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeRight;
            
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeLeft;
            
            break;
            
        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    _videoCamera.outputImageOrientation = orient;
    if (orient == UIInterfaceOrientationLandscapeRight || orient == UIInterfaceOrientationLandscapeLeft) {
        _recordButton.frame = CGRectMake(KMAIN_SCREEN_WIDTH - 100, 0, 100, 50);
        _recordButton.center = CGPointMake(_recordButton.center.x, KMAIN_SCREEN_HEIGHT/2);;
        _timerLabel.frame = CGRectMake(KMAIN_SCREEN_WIDTH - 100, _recordButton.bottom, 100, 20);
    }else{
       _recordButton.frame = CGRectMake(0, 0, 100, 50);
        _recordButton.center = CGPointMake(KMAIN_SCREEN_WIDTH/2, KMAIN_SCREEN_HEIGHT - 40 - 20);
        _timerLabel.frame = CGRectMake(0, _recordButton.top - 20, 100, 20);
        _timerLabel.center = CGPointMake(KMAIN_SCREEN_WIDTH/2, _timerLabel.center.y);
    }

}
-(void)loadView{
    [super loadView];
//    self.view = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, KMAIN_SCREEN_WIDTH, KMAIN_SCREEN_HEIGHT)];
}
-(void)setControlButton{
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.height - 40 - 20, 60, 40)];
    [backButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:backButton];
    _cancelButton = backButton;
    
    UIButton* change_video_capture_direction_button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 70, self.view.height - 40 - 20, 60, 40)];
//        UIImage* image = BundleImage(@"sj_record_video_capture_direction");
    [change_video_capture_direction_button setImage:BundleImage(@"sj_record_video_capture_direction") forState:UIControlStateNormal];
    [self.view addSubview:change_video_capture_direction_button];
    [change_video_capture_direction_button addTarget:self action:@selector(changeDirection:) forControlEvents:UIControlEventTouchUpInside];
    _switchCameraButton = change_video_capture_direction_button;

}

-(void)changeDirection:(UIButton*)button{
    [_videoCamera rotateCamera];
    if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        [((GPUImageView*)self.preview) setInputRotation:kGPUImageFlipHorizonal atIndex:0];
    }else{
        [((GPUImageView*)self.preview) setInputRotation:kGPUImageNoRotation atIndex:0];
    }
}

-(void)back{
   
    [_filter removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter cancelRecording];
    [_timer invalidate];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObserverForAppState];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    _movieWriter = [[YQSImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(540, 960)];
    _movieWriter.encodingLiveVideo = YES;
    [_movieWriter configure];//每次都需要配置
    
    _recordButton.selected = NO;
    _time = 0;
    _timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", _time/60, _time%60];
    [_filter addTarget:_movieWriter];
    
    _videoCamera.audioEncodingTarget = _movieWriter;
    
    
    GPUImageView *filterView = (GPUImageView *)self.preview;
    [_filter addTarget:filterView];
    
//    if (_videoCamera -> capturePaused == YES) {}
    
    
    
    [self.view bringSubviewToFront:_recordButton];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        if (error) {
            NSLog(@"no --------- motionManager");
        }else{
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }
        
    }];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}


-(void)timerOfRecord{
    _time++;
    _timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", _time/60, _time%60];
//    if (_time == 5) {
//        [_movieWriter configure];
//        [_movieWriter pause];
//    } else if (_time == 10) {
//        [_movieWriter configure];
//        [_movieWriter continueWrite];
//    }
    if (_time == 15) {
        /*
        [_filter removeTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
        [_timer invalidate];
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
        [self encodeVideoOrientation:[NSURL fileURLWithPath:pathToMovie]];
         */
        [self recordFinished];
//        YQSPlayVideoViewController* vc = [[YQSPlayVideoViewController alloc] init];
//        vc.imagePicker = self;
//        [self presentViewController:vc animated:YES completion:^{
//
//        }];
//        [self.navigationController pushViewController:vc animated:NO];
    }
}

-(void)changeTheOrientaionOfWriter{

//        CGSize movieWriteSize = CGSizeMake(480, 640);
//        UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
        CGAffineTransform transform = CGAffineTransformIdentity;
        switch (_orientationNew) {
            case UIDeviceOrientationLandscapeLeft:
            {
//                orientation = UIInterfaceOrientationLandscapeRight;
                if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
                    transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
                }else{
                    transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
                }
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
                    transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
                }else{
                    transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
                }
//                orientation = UIInterfaceOrientationLandscapeLeft;
                
            }
                break;
            case UIDeviceOrientationPortrait:
                
            case UIDeviceOrientationPortraitUpsideDown:
            {
                
//                orientation = UIInterfaceOrientationPortrait;
               
            }
                break;
                
            default:
                break;
                
        }

        _movieWriter.transform = transform;

}
-(void)recordFinished{
    _switchCameraButton.hidden = NO;
    _cancelButton.hidden = NO;
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter finishRecordingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            YQSPlayVideoViewController* vc = [[YQSPlayVideoViewController alloc] init];
            vc.imagePicker = self;
            [self presentViewController:vc animated:NO completion:^{
                
            }];
            
        });
    }];
    //        __weak typeof(self) weakSelf = self;
    //        [_movieWriter setCompletionBlock:^{
    //            [weakSelf.filter removeTarget:weakSelf.movieWriter];
    //        }];
    [_filter removeTarget:_movieWriter];
    
    [_timer invalidate];
    
    
}
-(void)recordVideo:(UIButton*)button{
    if (!button.selected) {
        button.selected = YES;
        _switchCameraButton.hidden = YES;
        _cancelButton.hidden = YES;
        [self changeTheOrientaionOfWriter];
        
        [_movieWriter startRecording];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerOfRecord) userInfo:nil repeats:YES];
    }else{
        
        [self recordFinished];
//        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//        [self encodeVideoOrientation:[NSURL fileURLWithPath:pathToMovie]];
//
    }

}

-(void)encodeVideoOrientation:(NSURL*)anOutputFileURL{
    
    AVURLAsset * videoAsset = [[AVURLAsset alloc]initWithURL:anOutputFileURL options:nil];
    
    AVAssetExportSession * assetExport = [[AVAssetExportSession alloc] initWithAsset:videoAsset
                                                                          presetName:AVAssetExportPresetMediumQuality];
    NSString* mp4Path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    
    NSFileManager* defaultFileManager = [NSFileManager defaultManager];
    if ([defaultFileManager fileExistsAtPath:mp4Path]) {
        [defaultFileManager removeItemAtPath:mp4Path error:nil];
    }
    
    assetExport.outputURL = [NSURL fileURLWithPath: mp4Path];
    assetExport.shouldOptimizeForNetworkUse = YES;
    assetExport.outputFileType = AVFileTypeMPEG4;
//    assetExport.videoComposition = [self getVideoComposition:videoAsset];
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        switch ([assetExport status]) {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"AVAssetExportSessionStatusFailed!");
                break;
            }
                
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                NSLog(@"Successful!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    YQSPlayVideoViewController* vc = [[YQSPlayVideoViewController alloc] init];
                    vc.imagePicker = self;
                    [self presentViewController:vc animated:NO completion:^{

                    }];

                });

            }

                break;
            default:
                break;
        }
    }];
}
#pragma mark - 解决录像保存角度问题

-(AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    if(isPortrait_) {
        NSLog(@"video is lanscape ");
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    // videoComposition.renderSize = videoTrack.naturalSize; //
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}
-(BOOL) isVideoPortrait:(AVAsset *)asset
{
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = FALSE;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = FALSE;
        }
    }
    return isPortrait;
}
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            // UIDeviceOrientationPortraitUpsideDown;
            _orientationNew = UIDeviceOrientationPortraitUpsideDown;
        }
        else{
            // UIDeviceOrientationPortrait;
            _orientationNew = UIDeviceOrientationPortrait;
        }
    }
    else
    {
        if (x >= 0){
            // UIDeviceOrientationLandscapeRight;
            _orientationNew = UIDeviceOrientationLandscapeRight;
            
        }
        else{
            // UIDeviceOrientationLandscapeLeft;
            _orientationNew = UIDeviceOrientationLandscapeLeft;
        }
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.preview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.preview.contentMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:_preview];
    _recording = NO;
    [self setControlButton];
    _time = 0;
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    button.center = CGPointMake(KMAIN_SCREEN_WIDTH/2, KMAIN_SCREEN_HEIGHT - 50);
    
//    NSString* bundPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"images.Bundle"];

    [button setImage:BundleImage(@"sj_record_video_start") forState:UIControlStateNormal];
    [button setImage:BundleImage(@"sj_record_video_pause")forState:UIControlStateSelected];
    
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(recordVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _recordButton = button;
    
    UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, button.top - 20, 100, 20)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:timeLabel];
    timeLabel.center = CGPointMake(KMAIN_SCREEN_WIDTH/2, timeLabel.center.y);
    timeLabel.text = @"00:00";
    timeLabel.textColor = [UIColor whiteColor];
    _timerLabel = timeLabel;
    
//    self.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);

//    self.preview.frame = CGRectMake( (self.view.width - self.view.height)/2, (self.view.height - self.view.width)/2, self.view.height, self.view.width);
//    _preview.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    
//    [_filter setInputRotation:kGPUImageRotateLeft atIndex:0];
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];

//    [_motionManager startDeviceMotionUpdates];
//     Do any additional setup after loading the view.
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.2;
    self.motionManager.gyroUpdateInterval = 0.2;
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [_videoCamera addAudioInputsAndOutputs];////该句可防止允许声音通过的情况下，避免录制第一帧黑屏闪屏(====)
    
    _filter = [[GPUImageSepiaFilter alloc] init];
    ((GPUImageSepiaFilter*)_filter).intensity = 0.0;
    [_videoCamera addTarget:_filter];
    [_videoCamera startCameraCapture];
    
    [self setupTopView];
//    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;// YES代表前置的时候不是镜像
//    _videoCamera.horizontallyMirrorRearFacingCamera = YES;//
    

//    if([self.motionManager isDeviceMotionAvailable]) {
    
        
//        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//
//            if (accelerometerData.acceleration.x >= 0.75) {//home button left
//                _orientationNew = UIDeviceOrientationLandscapeLeft;
//                _preview.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
//                _videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
//                NSLog(@"UIDeviceOrientationLandscapeRight");
//                self.preview.bounds = CGRectMake(0, 0, self.view.height, self.view.width);
//                self.preview.center = self.view.center;
//            }
//            else if (accelerometerData.acceleration.x <= -0.75) {//home button right
//                _orientationNew = UIDeviceOrientationLandscapeRight;
////                dispatch_async(dispatch_get_main_queue(), ^{
//                    _videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
////                    self.preview.frame = CGRectMake( (self.view.width - self.view.height)/2, (self.view.height - self.view.width)/2, self.view.height, self.view.width);
//                    self.preview.bounds = CGRectMake(0, 0, self.view.height, self.view.width);
//                    self.preview.center = self.view.center;
//                    _preview.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
////                });
//
////                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft  animated:NO];
//
////                self.preview.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
//            }
//            else if (accelerometerData.acceleration.y <= -0.75) {
//                _orientationNew = UIDeviceOrientationPortrait;
////                dispatch_async(dispatch_get_main_queue(), ^{
//                    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//                    _preview.bounds = self.view.bounds;
//                    self.preview.center = self.view.center;
//                    _preview.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
////                });
//
//
////                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait  animated:NO];
//            }
//            else if (accelerometerData.acceleration.y >= 0.75) {
//                _orientationNew = UIDeviceOrientationPortraitUpsideDown;
//                NSLog(@"UIDeviceOrientationPortraitUpsideDown");
//                _videoCamera.outputImageOrientation = UIInterfaceOrientationPortraitUpsideDown;
//                _preview.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
//                self.preview.bounds = self.view.bounds;
//                self.preview.center = self.view.center;//                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown  animated:NO];
//            }
//            else {
//                // Consider same as last time
//                return;
//            }
//
//        }];
//    }
//
    /*
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIDeviceOrientationLandscapeLeft;//这里可以改变旋转的方向
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
     */

}

-(void)addObserverForAppState{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)appWillResignActiveNotification{
//    _videoCamera.audioEncodingTarget = nil;
//    [_movieWriter finishRecording];
//
//    [_filter removeTarget:_movieWriter];
//
//    [_timer invalidate];
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    [self encodeVideoOrientation:[NSURL fileURLWithPath:pathToMovie]];
    [self back];

}


-(void)setupTopView{
    UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KMAIN_SCREEN_WIDTH, kStatusBarHeight + 44)];
    [self.view addSubview:topView];
    topView.backgroundColor = [UIColor blackColor];
    topView.alpha = 0.3;
    
//    UIButton* button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, 50, 30)];
//    [self.view addSubview:button1];
//    [button1 setTitle:@"灰白滤镜" forState:UIControlStateNormal];
//    [button1 addTarget:self action:@selector(changeCameraFilter:) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton* button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, 50, 30)];
//    [self.view addSubview:button2];
//    [button2 setTitle:@"灰白滤镜" forState:UIControlStateNormal];
//    [button2 addTarget:self action:@selector(changeCameraFilter:) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton* button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, 50, 30)];
//    [self.view addSubview:button1];
//    [button3 setTitle:@"灰白滤镜" forState:UIControlStateNormal];
//    [button3 addTarget:self action:@selector(changeCameraFilter:) forControlEvents:UIControlEventTouchUpInside];
    NSArray* titleArray = @[@"普通", @"美颜", @"灰白"];
    UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:titleArray];
    segment.frame = CGRectMake(0, kStatusBarHeight, KMAIN_SCREEN_WIDTH, 44);
    [self.view addSubview:segment];
    [segment addTarget:self action:@selector(changeCameraFilter:) forControlEvents:UIControlEventValueChanged];
    segment.selectedSegmentIndex = 0;
}

-(void)changeCameraFilter:(UISegmentedControl*)seg{
    NSInteger index = seg.selectedSegmentIndex;
    [self.videoCamera removeAllTargets];
    switch (index) {
        case 2:
        {
            GPUImageSepiaFilter* filter = [[GPUImageSepiaFilter alloc] init];
            [_videoCamera addTarget:filter];
            [filter addTarget:(GPUImageView*)_preview];
            filter.intensity = 1.0;
            [_videoCamera addTarget:filter];
        }
            break;
        case 1:
        {
            GPUImageBeautifyFilter* filter = [[GPUImageBeautifyFilter alloc]init];
            [_videoCamera addTarget:filter];
            [filter addTarget:(GPUImageView*)_preview];
            [filter addTarget:_movieWriter];
            
        }
            break;
        case 0:
        {
            GPUImageSepiaFilter* filter = [[GPUImageSepiaFilter alloc] init];
            [_videoCamera addTarget:filter];
            [filter addTarget:(GPUImageView*)_preview];
            filter.intensity = 0.0;
            [filter addTarget:_movieWriter];
            
        }
            break;
            
        default:
            break;
    }
}


-(void)dealloc{
    [_videoCamera stopCameraCapture];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter cancelRecording];
    [_filter removeTarget:_movieWriter];
    [_timer invalidate];
    NSLog(@"YQSImagePickerViewController dealloc");
//    [_motionManager stopDeviceMotionUpdates];
}

- (UIDeviceOrientation)realDeviceOrientation{
    CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x))    {
        if (y >= 0)
            return UIDeviceOrientationPortraitUpsideDown;
        else
            return UIDeviceOrientationPortrait;
        
    }    else    {
        if (x >= 0)
            return UIDeviceOrientationLandscapeRight;
        else
            return UIDeviceOrientationLandscapeLeft;
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

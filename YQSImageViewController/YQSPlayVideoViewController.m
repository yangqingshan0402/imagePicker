//
//  LKPlayVideoViewController.m
//  EZFun2
//
//  Created by jason Yang on 2017/8/9.
//  Copyright © 2017年 lenkeng. All rights reserved.
//

#import "YQSPlayVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YQSImagePrefix.pch"
#import <AVKit/AVKit.h>
#import "UIViewExt.h"
#import "SCItemInfoUtils.h"
//#import "StrorageCast-Prefix.h"
//#import "JSPhoto.h"
//#import "SCIPAddress.h"
//#import "SCUploaderHandle.h"

@interface YQSPlayVideoViewController ()

@property (nonatomic , strong)  AVPlayer* player;
@property (nonatomic , strong) UIButton* playButton;
@property (nonatomic , strong) UIButton* sendButton;
@property (nonatomic, strong)UIImageView* playView;
@property (nonatomic, strong) AVPlayerViewController* playerViewController;
@property (nonatomic, strong) UIImageView* simpleView;
@property (nonatomic, strong) UIView* tapView;

@end

@implementation YQSPlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self.player play];
    AVPlayerViewController* controller = [[AVPlayerViewController alloc] init];
    _playerViewController = controller;
    AVPlayerItem *item  = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:MovieFromAlumbPath]];
    //通过AVPlayerItem创建AVPlayer
    self.player = [[AVPlayer alloc]initWithPlayerItem:item];
    //给AVPlayer一个播放的layer层
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake(0, 0, self.view.width, self.view.height );
    layer.backgroundColor = [UIColor blackColor].CGColor;
    //设置AVPlayer的填充模式
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
//    _playerLayer = layer;
    [self.view.layer addSublayer:layer];
    //设置AVPlayerViewController内部的AVPlayer为刚创建的AVPlayer
    controller.player = self.player;
    
    //关闭AVPlayerViewController内部的约束
    controller.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    UIView* tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KMAIN_SCREEN_WIDTH, KMAIN_SCREEN_HEIGHT)];
    [self.view addSubview:tapView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [tapView addGestureRecognizer:tap];
    _tapView = tapView;
    
    
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(KMAIN_SCREEN_WIDTH - 70, KMAIN_SCREEN_HEIGHT - 50, 60, 50)];
    [_sendButton setTitle:@"send" forState:UIControlStateNormal];
    [self.view addSubview:_sendButton];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* retakeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, KMAIN_SCREEN_HEIGHT - 50, 60, 40)];
    [retakeButton setTitle:@"retake" forState:UIControlStateNormal];
        [retakeButton addTarget:self action:@selector(retake) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retakeButton];
    retakeButton.titleLabel.font = [UIFont systemFontOfSize:20];
    // Do any additional setup after loading the view.
    
    [_playerViewController.player play];
    
    _playView = [[UIImageView alloc] init];
    [self.view addSubview:_playView];
    _playView.frame = CGRectMake(0, 0, 100, 100);
    _playView.center = self.view.center;
    _playView.image = [UIImage imageNamed:@"play_icon"];
    _playView.hidden = YES;
}

-(void)retake{
    
    [self.playerViewController.player pause];
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

-(void)sendAction:(UIButton*)button{
    [self.imagePicker.delegate imagePickerController:self.imagePicker didFinishPickingMediaWithInfo:nil];
    [self.imagePicker dismissViewControllerAnimated:NO completion:^{

    }];
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}



//-(AVPlayer *)player{
//    if (!_player) {
//         NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
//        NSURL* url = [NSURL fileURLWithPath:pathToMovie];
//        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:url options:nil];
//        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
//        _player = player;
//        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//        playerLayer.frame = self.view.layer.bounds;
//        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//        [self.view.layer addSublayer:playerLayer];
//    }
//    return _player;
//}

-(void)playerItemDidReachEnd:(NSNotification*)notification{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [_player play];
//        [_player pause];
        
        [_playerViewController.player seekToTime:kCMTimeZero];
        _simpleView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:_simpleView belowSubview:_tapView];
        _simpleView.image = [SCItemInfoUtils getImage:MovieFromAlumbPath];
        
        _playView.hidden = NO;
    });

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ //这样在播放完毕后才会继续有界面不然就是黑屏
//        [_player pause];
//    });
}

-(void)tapAction{
    if ([_playerViewController.player timeControlStatus]==AVPlayerTimeControlStatusPlaying) {
        [_playerViewController.player pause];
        _playView.hidden = NO;
    }else{
        [_playerViewController.player play];
        _playView.hidden = YES;
        if (_simpleView) {
            [_simpleView removeFromSuperview];
        }
    }
}


-(void)dealloc{
    NSLog(@"YQSPlayVideoViewController dealloc");
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

//
//  YQSImageMovieWriter.m
//  YQSImageViewController
//
//  Created by lenkeng on 17/01/2018.
//  Copyright © 2018 lenkeng. All rights reserved.
//

#import "YQSImageMovieWriter.h"

@interface YQSImageMovieWriter(){
    BOOL _isPause;
    
//    BOOL _isAudioOn;
    CMTime _offset;
    CMTime _timeOffset;
    CMTime _last;
    BOOL _isDisCount;
}

@end

@implementation YQSImageMovieWriter

//BOOL _isDisCount = YES;
//CMTime _offset = kCMTimeZero;
//CMTime _timeOffset = CMTimeMake(0, 1);
//CMTime _isDisCount = YES;

-(void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex{
    if (_isPause) {
        return;
    }
    if (_isDisCount) {

        _isDisCount = NO;

        _offset = CMTimeSubtract(frameTime, _last);

        if (_offset.value > 0) {

            _timeOffset = CMTimeAdd(_timeOffset, _offset);

        }

    }
    _last = frameTime;

    frameTime = CMTimeSubtract(frameTime, _timeOffset);
//    NSLog(@"_timeOffset->%lf, ->%lf", _timeOffset.value, _timeOffset.timescale);
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

-(void)pause{
    _isPause = YES;

}

-(void)continueWrite{
    _isPause = NO;
//    [self configure];
}

-(void)configure{
    _timeOffset = CMTimeMake(0, 1);
    
    _isDisCount = YES;
    
    
    
//    _isAudioOn = YES;
    
    _offset = kCMTimeZero;
}

-(void)processAudioBuffer:(CMSampleBufferRef)audioBuffer{
    if (_isPause) {
        return;
    }
    
    [super processAudioBuffer:audioBuffer];
}

@end

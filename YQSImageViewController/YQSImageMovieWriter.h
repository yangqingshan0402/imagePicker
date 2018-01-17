//
//  YQSImageMovieWriter.h
//  YQSImageViewController
//
//  Created by lenkeng on 17/01/2018.
//  Copyright © 2018 lenkeng. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface YQSImageMovieWriter : GPUImageMovieWriter

-(void)pause;

-(void)continueWrite;

-(void)configure;//每次暂停或者播放之前都要调用

@end

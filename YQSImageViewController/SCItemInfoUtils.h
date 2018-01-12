//
//  Utils.h
//  Day19MusicPlayer
//
//  Created by Tarena on 13-5-2.
//  Copyright (c) 2013年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
@interface SCItemInfoUtils : NSObject
//获取音乐截图
+(UIImage *)getArtworkByPath:(NSString *)path;
//或是音乐信息
//+(NSMutableDictionary*)getMusicInfoByPath:(NSString *)directoryPath;
//获取视频截图
+(UIImage *)getImage:(NSString *)videoURL;
//获取时长
+(NSInteger)getTimeWithPath:(NSString*)movieStr;

+(NSDictionary*)getMusicInfoWithPath:(NSString*)path;
@end

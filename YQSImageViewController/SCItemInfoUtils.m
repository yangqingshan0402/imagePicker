//
//  Utils.m
//  Day19MusicPlayer
//
//  Created by Tarena on 13-5-2.
//  Copyright (c) 2013年 tarena. All rights reserved.
//

#import "SCItemInfoUtils.h"
#import <AVFoundation/AVFoundation.h>

//static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation SCItemInfoUtils

//获取专辑封面
+(UIImage *)getArtworkByPath:(NSString *)path{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    for (NSString *format in [mp3Asset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString :@"artwork"]) {
                NSData *data = (NSData*)metadataItem.value;
                return [UIImage imageWithData:data];
                break;
            }
        }
    }
    
    return nil;
}

+(UIImage *)getImage:(NSString *)videoURL

{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(1, 1);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
    
    
    
}


+(NSInteger)getTimeWithPath:(NSString*)movieStr{
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:movieStr];
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    CMTime duration = sourceAsset.duration;
    NSInteger second = duration.value / duration.timescale; // 获取视频总时长,单位秒

    return second;
}

+(NSDictionary*)getMusicInfoWithPath:(NSString*)path{

    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    //    DDLogVerbose(@"%@",mp3Asset);
    
    for (NSString *format in [mp3Asset availableMetadataFormats]) {
//        DDLogVerbose(@"format type = %@",format);
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
            
            if(metadataItem.commonKey)
            if ([metadataItem.commonKey isEqualToString:@"artist"]) {
                
                [retDic setObject:[self changeToUTF8String:(NSString*)metadataItem.value] forKey:metadataItem.commonKey];
            }
            if ([metadataItem.commonKey isEqualToString:@"albumName"]) {
                [retDic setObject:[self changeToUTF8String:(NSString*)metadataItem.value] forKey:metadataItem.commonKey];
            }

            
        }
    }
//    DDLogVerbose(@"%@", retDic);
    return retDic;
}

+(NSString*)changeToUTF8String:(NSString*)string{
//    NSString* artist = [musicInfoDic objectForKey:@"artist"];
//    NSLog(@"000000%@", artist);
    const char* art = [string cStringUsingEncoding:NSISOLatin1StringEncoding];
    printf("----------------%s", art);
    if (art == NULL) {
        return string;
    }else{
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString* chineseString = [NSString stringWithCString:art encoding:encoding];
        NSLog(@"--------------------%@", string);
        return chineseString;
    }
}



//获取歌曲信息
//+(NSMutableDictionary*)getMusicInfoByPath:(NSString *)directoryPath{
//
//
//
//    NSURL * fileURL=[NSURL fileURLWithPath:directoryPath];
//    NSString *fileExtension = [[fileURL path] pathExtension];
//    if ([fileExtension isEqual:@"mp3"]||[fileExtension isEqual:@"m4a"]||[fileExtension isEqual:@"m4r"]||[fileExtension isEqual:@"mid"]||[fileExtension isEqual:@"xmf"]||[fileExtension isEqual:@"ogg"]||[fileExtension isEqual:@"wav"]||[fileExtension isEqual:@"apc"]||[fileExtension isEqual:@"mp2"]||[fileExtension isEqual:@"wma"]||[fileExtension isEqual:@"aac"]||[fileExtension isEqual:@"amr"]||[fileExtension isEqual:@"flac"]||[fileExtension isEqual:@"mmf"])
//    {
//        AudioFileID fileID  = nil;
//        OSStatus err        = noErr;
//        
//        err = AudioFileOpenURL( (CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileID );
//        if( err != noErr ) {
//            DDLogVerbose( @"AudioFileOpenURL failed" );
//        }
//        UInt32 id3DataSize  = 0;
//        err = AudioFileGetPropertyInfo( fileID,   kAudioFilePropertyID3Tag, &id3DataSize, NULL );
//        
//        if( err != noErr ) {
//            DDLogVerbose( @"AudioFileGetPropertyInfo failed for ID3 tag" );
//        }
//        NSDictionary *piDict = nil;
//        UInt32 piDataSize   = sizeof( piDict );
//        err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict );
//        if( err != noErr ) {
//       [piDict release];
//            DDLogVerbose( @"AudioFileGetProperty failed for property info dictionary" );
//        }
//
//        UInt32 picDataSize = sizeof(picDataSize);
//        err =AudioFileGetProperty( fileID,   kAudioFilePropertyAlbumArtwork, &picDataSize, nil);
//        if( err != noErr ) {
//            DDLogVerbose( @"Get picture failed" );
//        }
//
//
//
//        NSString * Album = [(NSDictionary*)piDict objectForKey:
//                            [NSString stringWithUTF8String: kAFInfoDictionary_Album]];
//        NSString * Artist = [(NSDictionary*)piDict objectForKey:
//                             [NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
//        NSData* data = [Artist dataUsingEncoding:NSUTF8StringEncoding];
//        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        NSString*   temp = [[NSString alloc] initWithData:data encoding:encoding];
//        NSString * Title = [(NSDictionary*)piDict objectForKey:
//                            [NSString stringWithUTF8String: kAFInfoDictionary_Title]];
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        if (Title) {
//            [dic setObject:Title forKey:@"Title"];
//        }
//        if (Artist) {
//            [dic setObject:Artist forKey:@"Artist"];
//        }
//        if (Album) {
//            [dic setObject:Album forKey:@"Album"];
//        }
//        DDLogVerbose(@"%@",Title);
//        
//        DDLogVerbose(@"%@",temp);
//        
//        DDLogVerbose(@"%@",Album);
//
//        return dic;
//    }
//    
//    return nil;
//    
//
//}
@end

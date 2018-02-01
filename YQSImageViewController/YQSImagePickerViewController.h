//
//  LKRecordVideoViewController.h
//  EZFun2
//
//  Created by jason Yang on 2017/8/9.
//  Copyright © 2017年 lenkeng. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "JSSendVideoViewController.h"
//#import "LKBaseViewController.h"
#import <AVFoundation/AVFoundation.h>

@class YQSImagePickerViewController;

@protocol LKRecordVideoVidewControllerDelegate

-(void)imagePickerController:(YQSImagePickerViewController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)userInfo andResult:(AVAssetExportSessionStatus)status;

@end

@interface YQSImagePickerViewController : UIViewController

@property (nonatomic , weak) id<LKRecordVideoVidewControllerDelegate> delegate;

@end

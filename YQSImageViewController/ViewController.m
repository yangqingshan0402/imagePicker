//
//  ViewController.m
//  YQSImageViewController
//
//  Created by lenkeng on 12/01/2018.
//  Copyright © 2018 lenkeng. All rights reserved.
//

#import "ViewController.h"
#import "YQSImagePickerViewController.h"

@interface ViewController ()<LKRecordVideoVidewControllerDelegate>



@end

@implementation ViewController


-(void)imagePickerController:(YQSImagePickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)userInfo andResult:(AVAssetExportSessionStatus)status{

}

- (IBAction)sender:(id)sender {
    YQSImagePickerViewController* picker = [[YQSImagePickerViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

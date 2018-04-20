//
//  NSString+Size.m
//  EZFun2
//
//  Created by jason Yang on 16/3/16.
//  Copyright © 2016年 lenkeng. All rights reserved.
//

#import "NSString+Size.h"
#import <UIKit/UIKit.h>
#import "YQSImagePrefix.pch"

@implementation NSString (Size)
+(CGSize)estimateHeightOfLabelContent:(NSString*)string andFontSize:(CGFloat)fontSize{
    CGRect frame = [string boundingRectWithSize:CGSizeMake(KMAIN_SCREEN_WIDTH, 1000) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return (CGSize){frame.size.width + 20, frame.size.height};
}
-(CGFloat)widthOfStringWithAttributes:(NSDictionary*)attributes{
    CGRect bounds = [self boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    return bounds.size.width;
}
@end

//
//  NSString+Size.h
//  EZFun2
//
//  Created by jason Yang on 16/3/16.
//  Copyright © 2016年 lenkeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)

+(CGSize)estimateHeightOfLabelContent:(NSString*)string andFontSize:(CGFloat)fontSize;
-(CGFloat)widthOfStringWithAttributes:(NSDictionary*)attributes;
@end

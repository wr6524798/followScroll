//
//  UIColor+Extension.m
//  fllowscroll
//
//  Created by wangrui on 16/8/17.
//  Copyright © 2016年 tools. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor*)randomColor{
    CGFloat hue = (arc4random() %256/256.0);
    
    CGFloat saturation = (arc4random() %128/256.0) +0.5;
    
    CGFloat brightness = (arc4random() %128/256.0) +0.5;
    
    UIColor*color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    return color;

}

@end

//
//  UIView+Geometry.m
//  xygolf
//
//  Created by LiuC on 16/3/30.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import "UIView+Geometry.h"

@implementation UIView (Geometry)

- (CGPoint)theCenterPoint:(CGRect)rect
{
    CGPoint centerPoint = CGPointZero;
    
    centerPoint.x = CGRectGetMidX(rect);
    centerPoint.y = CGRectGetMidY(rect);
    
    return centerPoint;
}







@end

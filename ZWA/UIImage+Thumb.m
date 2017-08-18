//
//  UIImage+Thumb.m
//  Konnect
//
//  Created by yqfu on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Thumb.h"

@implementation UIImage (Thumb)

- (UIImage*)thumbImageWithSize:(CGSize)size gravity:(NSString *)gravity
{
//    UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGSize sizeToFit;
    CGFloat vScale = self.size.height / size.height;
    CGFloat hScale = self.size.width / size.width;
    
    if ([gravity isEqualToString:kCAGravityResizeAspect]) {
        if (self.size.width / vScale <= size.width) {
            sizeToFit.width = self.size.width / vScale;
            sizeToFit.height = size.height;
        }
        else {
            sizeToFit.width = size.width;
            sizeToFit.height = self.size.height / hScale;
        }
    }
    else if ([gravity isEqualToString:kCAGravityResizeAspectFill]) {
        if (self.size.width / vScale >= size.width) {
            sizeToFit.width = self.size.width / vScale;
            sizeToFit.height = size.height;
        }
        else {
            sizeToFit.width = size.width;
            sizeToFit.height = self.size.height / hScale;
        }
    }
    else {
        sizeToFit = size;
    }
    
    [self drawInRect:CGRectMake((size.width - sizeToFit.width) / 2, (size.height - sizeToFit.height) / 2, sizeToFit.width, sizeToFit.height)];
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumb;
}

@end

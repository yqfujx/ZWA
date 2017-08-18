//
//  UIImage+Thumb.h
//  Konnect
//
//  Created by yqfu on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (Thumb)
- (UIImage*)thumbImageWithSize:(CGSize)size gravity:(NSString*)gravity;
@end

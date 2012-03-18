//
//  UIImage-Tint.m
//  win7tweet
//
//  Created by b123400 on 12/02/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "UIImage-Tint.h"

@implementation UIImage (Tint)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor {
	UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
	CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
	[self drawInRect:drawRect];
	[tintColor set];
	UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
	UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return tintedImage;
}

@end

//
//  UIColor+averageColor.m
//  perSecond
//
//  Created by b123400 on 04/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "UIImage+averageColor.h"


@implementation UIImage(averageColor)

- (UIColor*) getDominantColor{
    NSUInteger red = 0;
    NSUInteger green = 0;
    NSUInteger blue = 0;
	
	
    // Allocate a buffer big enough to hold all the pixels
	
    struct pixel* pixels = (struct pixel*) calloc(1, self.size.width * self.size.height * sizeof(struct pixel));
    if (pixels != nil)
    {
		
        CGContextRef context = CGBitmapContextCreate(
													 (void*) pixels,
													 self.size.width,
													 self.size.height,
													 8,
													 self.size.width * 4,
													 CGImageGetColorSpace(self.CGImage),
													 kCGImageAlphaPremultipliedLast
													 );
		
        if (context != NULL)
        {
            // Draw the image in the bitmap
			
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), self.CGImage);
			
            // Now that we have the image drawn in our own buffer, we can loop over the pixels to
            // process it. This simple case simply counts all pixels that have a pure red component.
			
            // There are probably more efficient and interesting ways to do this. But the important
            // part is that the pixels buffer can be read directly.
			
            NSUInteger numberOfPixels = self.size.width * self.size.height;
            for (int i=0; i<numberOfPixels; i++) {
                red += pixels[i].r;
                green += pixels[i].g;
                blue += pixels[i].b;
            }
			
			
            red /= numberOfPixels;
            green /= numberOfPixels;
            blue/= numberOfPixels;
			
			
            CGContextRelease(context);
        }
		
        free(pixels);
    }
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
}

@end

//
//  UIColor+averageColor.h
//  perSecond
//
//  Created by b123400 on 04/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (averageColor)

struct pixel {
    unsigned char r, g, b, a;
};

- (UIColor*) getDominantColor;

@end

//
//  UIApplication+Frame.m
//  perSecond
//
//  Created by b123400 on 1/12/12.
//
//

#import "UIApplication+Frame.h"

@implementation UIApplication (Frame)

+(CGRect)currentFrame{
    CGRect appFrame=[UIScreen mainScreen].applicationFrame;
    appFrame.origin=CGPointZero;
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        //landscape
        appFrame.size=CGSizeMake(appFrame.size.height, appFrame.size.width);
    }
    return appFrame;
}

@end

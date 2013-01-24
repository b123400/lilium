//
//  StatusUserView.m
//  perSecond
//
//  Created by b123400 on 9/1/13.
//
//

#import "StatusUserView.h"

@implementation StatusUserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)r
{
    // Drawing code
    CGContextRef context    = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, r);
    
	UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(7, 0)];
	[path addLineToPoint:CGPointMake(17, 0)];
	[path addLineToPoint:CGPointMake(12,5)];
    [path closePath];
    [[UIColor colorWithRed:101/255.0 green:156/255.0 blue:60/255.0 alpha:1.0] set];
    [path fill];
}


@end

//
//  BRLoadingView.m
//  perSecond
//
//  Created by b123400 on 10/12/12.
//
//
#import <QuartzCore/QuartzCore.h>
#import "BRLoadingView.h"

@implementation BRLoadingView

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        innerView=[[UIView alloc] init];
        innerView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        innerView.backgroundColor=[UIColor redColor];
        [self addSubview:innerView];
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}
-(void)dealloc{
    [innerView release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)didMoveToSuperview{
    innerView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self startAnimation];
}

-(UIColor*)color{
    return innerView.backgroundColor;
}
-(void)setColor:(UIColor *)color{
    innerView.backgroundColor=color;
}

-(void)startAnimation{
    [self stopAnimation];
    
    innerView.hidden=NO;
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue=[NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];
    animation.duration=5;
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.06 :0.855 :0.16 :0.97];
    animation.repeatCount=HUGE_VALF;
    [innerView.layer addAnimation:animation forKey:@"animation"];
}
-(void)stopAnimation{
    [innerView.layer removeAllAnimations];
    innerView.hidden=YES;
}

@end

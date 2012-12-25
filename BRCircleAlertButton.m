//
//  BRCircleAlertButton.m
//  perSecond
//
//  Created by b123400 on 25/12/12.
//
//

#import "BRCircleAlertButton.h"
#import "BRCircleAlert.h"

@implementation BRCircleAlertButton
@synthesize action;

+(BRCircleAlertButton*)buttonWithAction:(void (^) (void))_action{
    BRCircleAlertButton *newButton=[[[BRCircleAlertButton alloc]init] autorelease];
    newButton.action=_action;
    
    return newButton;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake((self.frame.size.width-BUTTON_RADIUS*2)/2, (self.frame.size.height-BUTTON_RADIUS*2)/2, BUTTON_RADIUS*2, BUTTON_RADIUS*2));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor yellowColor] CGColor]));
    CGContextFillPath(ctx);
    
    [super drawRect:rect];
}


@end

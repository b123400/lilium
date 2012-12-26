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
@synthesize action,color;

+(BRCircleAlertButton*)buttonWithAction:(void (^) (void))_action{
    return [BRCircleAlertButton buttonWithAction:_action color:[UIColor colorWithWhite:0 alpha:1.0]];
}
+(BRCircleAlertButton*)buttonWithAction:(void (^) (void))_action color:(UIColor*)_color{
    BRCircleAlertButton *newButton=[[[BRCircleAlertButton alloc]init] autorelease];
    newButton.action=Block_copy(_action);
    newButton.color=_color;
    return newButton;
}

+(BRCircleAlertButton*)tickButtonWithAction:(void (^)(void))_action{
    BRCircleAlertButton *newButton=[BRCircleAlertButton buttonWithAction:_action];
    [newButton setTitle:@"✔" forState:UIControlStateNormal];
    newButton.titleLabel.font=[UIFont fontWithName:@"Arial Unicode MS" size:22];
    return newButton;
}
+(BRCircleAlertButton*)cancelButton{
    BRCircleAlertButton *newButton=[BRCircleAlertButton buttonWithAction:^{}];
    [newButton setTitle:@"✘" forState:UIControlStateNormal];
    newButton.titleLabel.font=[UIFont fontWithName:@"Arial Unicode MS" size:22];
    return newButton;
}
-(void)dealloc{
    if(action)Block_release(action);
    [super dealloc];
}
-(id)init{
    self= [super initWithFrame:CGRectMake(0, 0, BUTTON_RADIUS*2, BUTTON_RADIUS*2)];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return self;
}
-(void)setColor:(UIColor *)_color{
    
    color=[_color retain];
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextSetAlpha(ctx, 0.3);
    CGContextAddEllipseInRect(ctx, CGRectMake((self.frame.size.width-BUTTON_RADIUS*2)/2, (self.frame.size.height-BUTTON_RADIUS*2)/2, BUTTON_RADIUS*2, BUTTON_RADIUS*2));
    CGContextFillPath(ctx);
    
    [super drawRect:rect];
}


@end

//
//  CommentComposeView.m
//  perSecond
//
//  Created by b123400 on 3/1/13.
//
//

#import "CommentComposeView.h"

@implementation CommentComposeView
@synthesize textField;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        textField=[[UITextField alloc]initWithFrame:CGRectMake(14, 7, frame.size.width-28, frame.size.height-14)];
        textField.textColor=[UIColor whiteColor];
        textField.font=[UIFont systemFontOfSize:15];
        textField.backgroundColor=[UIColor colorWithRed:4/255.0 green:55/255.0 blue:108/255.0 alpha:1.0];
        textField.placeholder=@"Your comment here";
        [self addSubview:textField];
    }
    return self;
}
-(void)dealloc{
    [textField release];
    [super dealloc];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setNeedsDisplay];
    textField.frame=CGRectMake(14, 7, frame.size.width-28, frame.size.height-14);
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)r
{
    CGContextRef context    = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, r);
    
	UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(7, 0)];
	[path addLineToPoint:CGPointMake(r.size.width-7, 0)];
	[path addLineToPoint:CGPointMake(r.size.width-7, r.size.height-7)];
    [path addLineToPoint:CGPointMake(21, r.size.height-7)];
    [path addLineToPoint:CGPointMake(14, r.size.height)];
    [path addLineToPoint:CGPointMake(14, r.size.height-7)];
	[path addLineToPoint:CGPointMake(7, r.size.height-7)];
    [path closePath];
    [[UIColor colorWithRed:4/255.0 green:55/255.0 blue:108/255.0 alpha:1.0] set];
    [path fill];
	
	//[[UIColor whiteColor] set];
	
	UIGraphicsEndImageContext();

}


@end

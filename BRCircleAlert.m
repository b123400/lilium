//
//  BRCircleAlert.m
//  perSecond
//
//  Created by b123400 on 18/12/12.
//
//

#import "BRCircleAlert.h"
#import "Evaluate.h"
#import "AccelerationAnimation.h"
#import "UIApplication+Frame.h"
#import "BRFunctions.h"

@interface BRCircleAlert ()

-(float)radius;
-(float)minimumTextWidth;
-(CGSize)sizeForTextWithWidth:(float)width;

-(void)layout;

-(void)pinched:(UIGestureRecognizer*)recognizer;
-(void)buttonPressed:(BRCircleAlertButton*)sender;

@end

@implementation BRCircleAlert
@synthesize text,color,buttons;

- (id)initWithText:(NSString*)_text color:(UIColor*)_color buttons:(NSArray*)_buttons{
    self = [super initWithFrame:[UIApplication currentFrame]];
    
    if (self) {
        // Initialization code
        self.text=_text;
        self.color=_color;
        self.buttons=_buttons;
        self.backgroundColor=[UIColor clearColor];
        self.clipsToBounds=NO;
        
        self.buttons=_buttons;
        for(BRCircleAlertButton *button in self.buttons){
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
        
        _minimumTextWidth=-1;
        _radius=-1;
        
        textView=[[UITextView alloc] init];
        textView.font=[UIFont systemFontOfSize:16];
        textView.textColor=[UIColor whiteColor];
        textView.backgroundColor=[UIColor clearColor];
        textView.textAlignment=NSTextAlignmentCenter;
        textView.editable=NO;
        [self addSubview:textView];
        textView.text=_text;
        
        UIPinchGestureRecognizer *pinch=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinched:)];
        pinch.delaysTouchesBegan=NO;
        pinch.delaysTouchesEnded=NO;
        [self addGestureRecognizer:pinch];
        [pinch release];

    }
    return self;
}
-(void)dealloc{
    [textView removeFromSuperview];
    [textView release];
    [super dealloc];
}
+(BRCircleAlert*)alertWithText:(NSString*)_text{
    return [BRCircleAlert alertWithText:_text buttons:@[[BRCircleAlertButton tickButtonWithAction:^{}]]];
}
+(BRCircleAlert*)alertWithText:(NSString*)_text buttons:(NSArray*)_buttons{
    return [BRCircleAlert alertWithText:_text color:[UIColor colorWithRed:1.0 green:63/255. blue:93/255. alpha:1.0] buttons:_buttons];
}
+(BRCircleAlert*)alertWithText:(NSString*)_text color:(UIColor*)color buttons:(NSArray*)_buttons{
    return [[[BRCircleAlert alloc]initWithText:_text color:color buttons:_buttons]autorelease];
}
+(BRCircleAlert*)confirmAlertWithText:(NSString*)text action:(void (^)(void))action{
    return [BRCircleAlert alertWithText:text buttons:[NSArray arrayWithObjects:
                                                      [BRCircleAlertButton tickButtonWithAction:action],
                                                      [BRCircleAlertButton cancelButton], nil]];
}
-(void)layout{
    CGSize textViewSize=[self sizeForTextWithWidth:self.minimumTextWidth];
    float xMargin=([UIApplication currentFrame].size.width-self.minimumTextWidth)/2;
    float yMargin=([UIApplication currentFrame].size.height-textViewSize.height-_verticalBlank)/2;
    textView.frame=CGRectMake(xMargin, yMargin, textViewSize.width, textViewSize.height);
    
    
    //buttons
    float totalButtonWidth=[buttons count]*BUTTON_RADIUS*2+([buttons count]-1)*BUTTON_SPACING;
    float buttonXMargin=([UIApplication currentFrame].size.width-totalButtonWidth)/2;
    
    float buttonMargin=MIN_BUTTON_MARGIN;
//    if(([UIApplication currentFrame].size.height/2+self.radius-(textView.frame.origin.y+textView.frame.size.height)-BUTTON_RADIUS*2)/2>MIN_BUTTON_MARGIN){
        buttonMargin=([UIApplication currentFrame].size.height/2+self.radius-(textView.frame.origin.y+textView.frame.size.height)-BUTTON_RADIUS*2)/2;
    //}
    
    for(int i=0;i<[buttons count];i++){
        BRCircleAlertButton *thisButton =[buttons objectAtIndex:i];
        
        thisButton.frame=CGRectMake(buttonXMargin+i*(BUTTON_RADIUS*2+BUTTON_SPACING), textView.frame.origin.y+textView.frame.size.height+buttonMargin, BUTTON_RADIUS*2, BUTTON_RADIUS*2);
    }
    
    [self setNeedsDisplay];
}
-(void)show{
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    
    float zoomingFactor=1.5;
    SecondOrderResponseEvaluator *evaluator=[[[SecondOrderResponseEvaluator alloc] initWithOmega:14.825 zeta:0.44] autorelease];
    AccelerationAnimation *animationh =[AccelerationAnimation
                                        animationWithKeyPath:@"transform"
                                        startZoomValue:1/zoomingFactor
                                        endZoomValue:1
                                        evaluationObject:evaluator
                                        interstitialSteps:99];
    animationh.removedOnCompletion=YES;
    animationh.duration=0.5;
    
    [self layout];
    
    [self.layer addAnimation:animationh forKey:@"transform"];
    [BRFunctions playSound:@"alert"];
}
-(void)dismiss{
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.transform=CATransform3DMakeScale(0., 0., 1.0);
    } completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
}
#pragma mark - interaction
-(void)buttonPressed:(BRCircleAlertButton*)sender{
    sender.action();
    [self dismiss];
}
-(void)pinched:(UIPinchGestureRecognizer*)gestureRecognizer{
    float scale=gestureRecognizer.scale;
    if(gestureRecognizer.state==UIGestureRecognizerStateChanged){
        if(scale>1)scale=1+(scale-1)/2;
        self.layer.transform=CATransform3DMakeScale(scale, scale, 1.0);
    }else if(gestureRecognizer.state==UIGestureRecognizerStateEnded||gestureRecognizer.state==UIGestureRecognizerStateCancelled){
        if(scale<0.7){
            [self dismiss];
        }else{
            [UIView animateWithDuration:0.1 animations:^{
                self.layer.transform=CATransform3DMakeScale(1.0, 1.0, 1.0);
            } completion:^(BOOL finished) {}];
        }
    }
}
#pragma mark -
-(CGSize)sizeForTextWithWidth:(float)width{
    CGRect textViewFrame=textView.frame;
    textViewFrame.size.width=width;
    textView.frame=textViewFrame;
    textViewFrame.size.height=textView.contentSize.height;
    textView.frame=textViewFrame;
    
    return textViewFrame.size;
}
-(float)minimumTextWidth{
    if(_minimumTextWidth>0)return _minimumTextWidth;
    
    float minimumTextWidth=self.frame.size.width;
    while(true){
        CGSize textSize=[self sizeForTextWithWidth:minimumTextWidth];
        
        float currentRadius=sqrt( pow(textSize.width, 2)+pow(textSize.height, 2) )/2;
        
        float verticalBlank=0;
        if(((currentRadius*2-textSize.height)/2-BUTTON_RADIUS*2)/2<MIN_BUTTON_MARGIN){
            verticalBlank= (MIN_BUTTON_MARGIN+BUTTON_RADIUS)*2 - (currentRadius*2-textSize.height)/2;
        }
        currentRadius=sqrt( pow(textSize.width, 2)+pow(textSize.height+verticalBlank, 2) )/2;
        if(minimumTextWidth-(textSize.height+verticalBlank)<5){
            _verticalBlank=verticalBlank;
            _radius=currentRadius;
            break;
        }
        minimumTextWidth--;
    }
    _minimumTextWidth=minimumTextWidth;
    return _minimumTextWidth;
}
-(float)radius{
    return _radius;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float radius=self.radius;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect circleRect=CGRectMake((self.frame.size.width-radius*2)/2, (self.frame.size.height-radius*2)/2, radius*2, radius*2);
    
    CGRect outerCircleRect=CGRectInset(circleRect, -10, -10);
    CGContextAddEllipseInRect(ctx, outerCircleRect);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetAlpha(ctx, 0.3);
    CGContextFillPath(ctx);
    
    CGContextAddEllipseInRect(ctx, circleRect);
    CGContextSetAlpha(ctx, 1.0);
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextFillPath(ctx);

    //[super drawRect:rect];
}


@end

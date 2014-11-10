//
//  TitleButton.m
//  perSecond
//
//  Created by b123400 on 26/1/13.
//
//
#import <QuartzCore/QuartzCore.h>
#import "TitleButton.h"
#import "UIImageView+WebCache.h"
#import "UIView+Interaction.h"

@interface TitleButton ()

-(void)setup;

@end

@implementation TitleButton
@synthesize textLabel,backgroundImageView,delegate;

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self= [super initWithCoder:aDecoder];
    [self setup];
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}
-(void)dealloc{
    self.backgroundImageView=nil;
    self.textLabel=nil;
    [super dealloc];
}
-(void)setup{
    self.clipsToBounds=YES;
    [self setTouchReactionEnabled:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didRefreshedImage) name:SDWebCacheDidLoadedImageForImageViewNotification
                                              object:self.backgroundImageView];
    
    self.autoresizesSubviews=YES;
    self.textLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.textLabel.textColor=[UIColor whiteColor];
    self.textLabel.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.textLabel.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.2];
    self.textLabel.textAlignment=NSTextAlignmentCenter;
    self.textLabel.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:18];
    [self addSubview:self.textLabel];
    
    self.backgroundImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    self.backgroundImageView.backgroundColor=[UIColor redColor];
    [self addSubview:self.backgroundImageView];
    
    [self bringSubviewToFront:self.backgroundImageView];
    [self bringSubviewToFront:self.textLabel];
}
-(void)setImageWithURL:(NSURL*)url{
    [self.backgroundImageView setImageWithURL:url];
    [self layoutWithAnimation:YES];
}
-(void)didRefreshedImage{
    [self layoutWithAnimation:YES];
}
-(void)layoutWithAnimation:(BOOL)animated{
    float animationDuration=15;
    float widthScale=self.frame.size.width/self.backgroundImageView.image.size.width;
    float heightScale=self.frame.size.height/self.backgroundImageView.image.size.height;
    if(self.backgroundImageView.image.size.width==0||self.backgroundImageView.image.size.height==0){
        widthScale=heightScale=0;
    }
    [self.backgroundImageView.layer removeAllAnimations];
    if(widthScale<heightScale){
        CGSize targetSize=CGSizeMake(self.backgroundImageView.image.size.width*heightScale, self.frame.size.height);
        self.backgroundImageView.frame=CGRectMake(0, 0, targetSize.width, targetSize.height);
        [UIView animateWithDuration:animationDuration animations:^{
            self.backgroundImageView.frame=CGRectMake(self.frame.size.width-targetSize.width, 0, self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height);
        } completion:^(BOOL finished) {
            if(finished){
                if(delegate&&[delegate respondsToSelector:@selector(titleButtonDidFinishedAnimation:)]){
                    [delegate titleButtonDidFinishedAnimation:self];
                }
            }
        }];
    }else if(widthScale>heightScale){
        CGSize targetSize=CGSizeMake(self.frame.size.width, self.backgroundImageView.image.size.height*widthScale);
        self.backgroundImageView.frame=CGRectMake(0, 0, targetSize.width, targetSize.height);
        [UIView animateWithDuration:animationDuration animations:^{
            self.backgroundImageView.frame=CGRectMake(0, self.frame.size.height-self.backgroundImageView.frame.size.height, self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height);
        } completion:^(BOOL finished) {
            if(finished){
                if(delegate&&[delegate respondsToSelector:@selector(titleButtonDidFinishedAnimation:)]){
                    [delegate titleButtonDidFinishedAnimation:self];
                }
            }
        }];
    }else{
        self.backgroundImageView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.backgroundImageView.layer.transform=CATransform3DMakeScale(1.5, 1.5, 0);
        [UIView animateWithDuration:5.0 animations:^{
            self.backgroundImageView.layer.transform=CATransform3DIdentity;
        } completion:^(BOOL finished) {
            if(finished){
                if(delegate&&[delegate respondsToSelector:@selector(titleButtonDidFinishedAnimation:)]){
                    [delegate titleButtonDidFinishedAnimation:self];
                }
            }
        }];
    }
    [self setNeedsDisplay];
}
-(void)startAnimation{
    [self layoutWithAnimation:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

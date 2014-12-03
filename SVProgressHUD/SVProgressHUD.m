//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "AccelerationAnimation.h"
#import "Evaluate.h"

@interface SVProgressHUD ()

@property (nonatomic, retain) NSTimer *fadeOutTimer;
@property (nonatomic, retain) UILabel *stringLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *spinnerView;

- (void)showInView:(UIView *)view status:(NSString *)string networkIndicator:(BOOL)show posY:(CGFloat)posY;
- (void)setStatus:(NSString *)string;
- (void)dismiss;
- (void)dismissWithStatus:(NSString *)string error:(BOOL)error;

- (void)memoryWarning:(NSNotification*) notification;

@end


@implementation SVProgressHUD

@synthesize fadeOutTimer, stringLabel, imageView, spinnerView;

static SVProgressHUD *sharedView = nil;

+ (SVProgressHUD*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[SVProgressHUD alloc] initWithFrame:CGRectZero];
	
	return sharedView;
}

+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}
+ (void)setColor:(UIColor*)color{
	[[SVProgressHUD sharedView] setBackgroundColor:color];
}
#pragma mark -
#pragma mark Show Methods


+ (void)show {
	[SVProgressHUD showInView:[UIApplication sharedApplication].keyWindow status:nil];
}


+ (void)showInView:(UIView*)view {
	[SVProgressHUD showInView:view status:nil];
}


+ (void)showInView:(UIView*)view status:(NSString*)string {
	[SVProgressHUD showInView:view status:string networkIndicator:YES];
}


+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show {
	[SVProgressHUD showInView:view status:string networkIndicator:show posY:floor(CGRectGetHeight(view.bounds)/2)-100];
}


+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY {
	[[SVProgressHUD sharedView] showInView:view status:string networkIndicator:show posY:posY];
}


#pragma mark -
#pragma mark Dismiss Methods

+ (void)dismiss {
	[[SVProgressHUD sharedView] dismiss];
}


+ (void)dismissWithSuccess:(NSString*)successString {
	[[SVProgressHUD sharedView] dismissWithStatus:successString error:NO];
}


+ (void)dismissWithError:(NSString*)errorString {
	[[SVProgressHUD sharedView] dismissWithStatus:errorString error:YES];
}

#pragma mark -
#pragma mark Instance Methods

- (void)dealloc {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.layer.cornerRadius = 0;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
		self.userInteractionEnabled = NO;
		self.alpha = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(memoryWarning:) 
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
	
    return self;
}

- (void)setStatus:(NSString *)string {
	
	CGFloat stringWidth = [string sizeWithFont:stringLabel.font].width+28;
	
	if(stringWidth < 100)
		stringWidth = 100;
	
	self.bounds = CGRectMake(0, 0, ceil(stringWidth/2)*2, 100);
	//self.bounds = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 100);
	
	self.imageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, 36);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
	self.stringLabel.frame = CGRectMake(0, 66, CGRectGetWidth(self.bounds), 20);
	
	if(string)
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2), 40);
	else
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2), ceil(self.bounds.size.height/2));
}


- (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	if(show)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	else
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.imageView.hidden = YES;
	
	[self setStatus:string];
	[spinnerView startAnimating];
	
	if(![sharedView isDescendantOfView:view]) {
		[view addSubview:sharedView];
	
		posY+=(CGRectGetHeight(self.bounds)/2);
		self.center = CGPointMake(CGRectGetWidth(self.superview.bounds)/2, posY);
		
		self.layer.opacity = 1;
		self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
		AccelerationAnimation *animationh =[AccelerationAnimation
											animationWithKeyPath:@"transform"
											startZoomValue:0.1
											endZoomValue:1
											evaluationObject:[[[SecondOrderResponseEvaluator alloc] initWithOmega:14.825 zeta:0.44] autorelease]
											interstitialSteps:99];
		animationh.duration=0.5;
		[self.layer addAnimation:animationh forKey:@"transform"];
		
		/*self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 0.1, 1);
		self.layer.opacity = 1;
		
		[UIView animateWithDuration:0.15 animations:^{
			self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
			self.layer.opacity = 1;
		}];*/
	}
}


- (void)dismiss {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.layer removeAllAnimations];
	self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
	[UIView animateWithDuration:0.15
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{	
						 self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 0.1, 0.1, 1.0);
						 self.layer.opacity = 1;
					 }
					 completion:^(BOOL finished){ [sharedView removeFromSuperview]; }];
}


- (void)dismissWithStatus:(NSString*)string error:(BOOL)error {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(error)
		self.imageView.image = [UIImage imageNamed:@"svhud-error.png"];
	else
		self.imageView.image = [UIImage imageNamed:@"svhud-success.png"];
	
	self.imageView.hidden = NO;
	
	[self setStatus:string];
	
	[self.spinnerView stopAnimating];
    
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(dismiss) userInfo:nil repeats:NO] retain];
}

#pragma mark -
#pragma mark Getters

- (UILabel *)stringLabel {
    
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		stringLabel.textAlignment = NSTextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:16];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
		[self addSubview:stringLabel];
		[stringLabel release];
    }
    
    return stringLabel;
}

- (UIImageView *)imageView {
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		[self addSubview:imageView];
		[imageView release];
    }
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.contentMode = UIViewContentModeTopLeft;
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 36, 36);
		[self addSubview:spinnerView];
		[spinnerView release];
    }
    
    return spinnerView;
}

#pragma mark -
#pragma mark MemoryWarning

- (void)memoryWarning:(NSNotification *)notification {
	
    if (sharedView.superview == nil) {
        [sharedView release];
        sharedView = nil;
    }
}

@end

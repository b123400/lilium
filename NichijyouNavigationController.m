//
//  NichijyouNavigationController.m
//  NichijyouNavigationController
//
//  Created by b123400 on 08/05/2011.
//  Copyright 2011 home. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "NichijyouNavigationController.h"
#import "AccelerationAnimation.h"
#import "Evaluate.h"
#import "BRFunctions.h"

@interface NichijyouNavigationController ()

-(NSMutableArray*)centerPoints;

//push
-(void)zoomInHide:(UIView*)theView;
-(void)prepareZoomInShow:(UIView*)theView;
-(void)pushIntoViewController:(UIViewController*)viewController;
-(void)pushIntoViewController:(UIViewController*)viewController reallyPush:(BOOL)forcedPush; //Some View Controller need to wait for view to finish loading
-(void)zoomInShow:(UIView*)theView;
-(void)finishedZoomInShow:(UIViewController*)viewController;

//pop
-(void)zoomOutHide:(UIView*)theView;
-(void)popOutToViewController:(UIViewController*)viewController;
-(void)prepareZoomOutShow:(UIView*)theView;
-(void)zoomOutShow:(UIView*)theView;
-(void)finishedZoomOutShow:(UIViewController*)viewController;

-(float)timeDelayForView:(UIView*)theView atZoomingPoint:(CGPoint)point;
-(NSArray*)subviewsToAnimateForViewController:(UIViewController*)controller;

@end


@implementation NichijyouNavigationController
@synthesize disableFade;

static float zoomDelayPerPixelFromCenter=1/1100.0;
static float zoomingFactor=7;
static float zoomOutFactor=2;
static float fadeOutOpacity=0;
static float animationDuration=0.25;
static float bounceAnimationDuration=1.0;

static float pressZoomFactor=1.2;
static float pressShiftFactor=0.2;

-(id)initWithCoder:(NSCoder *)aDecoder{
	lastTouchedPoint=CGPointMake([BRFunctions screenSize].width/2, [BRFunctions screenSize].height/2);
	return [super initWithCoder:aDecoder];
}

-(NSMutableArray*)centerPoints{
	if(!centerPoints){
		centerPoints=[[NSMutableArray alloc]init];
	}
	return centerPoints;
}

-(void)viewDidLoad{
	NichijyouTransparentView *transparentView=[[NichijyouTransparentView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	transparentView.delegate=self;
	
	[self.view addSubview:transparentView];
	[transparentView release];
	[self setNavigationBarHidden:YES];
	[super viewDidLoad];
	
	UIPinchGestureRecognizer *pinch=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinched:)];
	pinch.delaysTouchesBegan=NO;
	pinch.delaysTouchesEnded=NO;
	[self.view addGestureRecognizer:pinch];
	[pinch release];
}
-(void)pinched:(UIPinchGestureRecognizer*)gestureRecognizer{
	if(gestureRecognizer.state==UIGestureRecognizerStateChanged&&gestureRecognizer.scale<1){
		if([[self viewControllers]count]<=1)return;
		if([[[self viewControllers] objectAtIndex:0]class]==[UIViewController class]&&[[self viewControllers]count]==2){
			return;
		}
		UIViewController *targetController=[[self viewControllers] objectAtIndex:[[self viewControllers] count]-2];
		
		NSArray *viewsToAnimate=[self subviewsToAnimateForViewController:[self topViewController]];
		
		int indexOfNextViewController=[[self viewControllers]indexOfObject:targetController];
		lastTouchedPoint=[((NSValue*)[[self centerPoints] objectAtIndex:indexOfNextViewController]) CGPointValue];
		
		float scale=gestureRecognizer.scale;
		
		for(UIView *thisView in viewsToAnimate){
			//thisView.layer.position
			CGPoint relativeTarget=[self.view convertPoint:lastTouchedPoint toView:thisView.superview];
			float delay=pow((578-[self timeDelayForView:thisView atZoomingPoint:lastTouchedPoint]/zoomDelayPerPixelFromCenter)/500,8)+1.0f;
			thisView.layer.transform=CATransform3DMakeTranslation((relativeTarget.x-thisView.center.x)*(1-pow(scale,delay)), (relativeTarget.y-thisView.center.y)*(1-pow(scale,delay)), 0);
			thisView.layer.transform=CATransform3DScale(thisView.layer.transform, pow(scale,delay), pow(scale,delay), pow(scale,delay));
		}
		
		//positionAnimation.toValue = [NSValue valueWithCGPoint:[self.view convertPoint:targetPosition toView:theView.superview]];
		
		// Update the layer's position so that the layer doesn't snap back when the animation completes.
		//layer.position = [positionAnimation.toValue CGPointValue];
		
		// Add the animation, overriding the implicit animation.
		
		//resizeAnimation.toValue=[NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1/zoomingFactor, 1/zoomingFactor, 1/zoomingFactor)];
		
	}else if(gestureRecognizer.state==UIGestureRecognizerStateEnded||gestureRecognizer.state==UIGestureRecognizerStateCancelled||gestureRecognizer.state==UIGestureRecognizerStateFailed){
		if(gestureRecognizer.scale<0.9){
			if([[self viewControllers] count]>1){
				if([[[self viewControllers] objectAtIndex:0]class]==[UIViewController class]&&[[self viewControllers]count]==2){
					return;
				}
				if(isAnimating)return;
				if([[self topViewController] respondsToSelector:@selector(shouldPopByPinch)]){
					if(![[self topViewController]shouldPopByPinch]){
						return;
					}
				}
				if([[self topViewController] respondsToSelector:@selector(didPinched)]){
					[[self topViewController]didPinched];
				}
				[self popViewControllerAnimated:YES];
			}
		}else{
			NSArray *viewsToAnimate=[self subviewsToAnimateForViewController:[self topViewController]];
			
			for(UIView *thisView in viewsToAnimate){
				[UIView animateWithDuration:animationDuration animations:^{
					CATransform3D transform=CATransform3DMakeTranslation(0, 0, 0);
					thisView.layer.transform=transform;
				}];
			}
		}
	}
}
-(void)didTouchedTransparentView:(id)sender atPoint:(CGPoint)point{
	if(!isAnimating){
		lastTouchedPoint=[[sender superview] convertPoint:point toView:nil];
	}
}
#pragma mark -
#pragma mark Push
-(void)viewCanBePushed:(UIViewController*)controller{
	if(controller!=[self topViewController])return;
	[self pushIntoViewController:controller reallyPush:YES];
}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
	if(!animated){
		[super pushViewController:viewController animated:animated];
		return;
	}
	[self pushViewController:viewController atCenter:lastTouchedPoint];
}

-(void)pushViewController:(UIViewController *)viewController atCenter:(CGPoint)center{
	isAnimating=YES;
	nextController=[viewController retain];
	[self topViewController].view.userInteractionEnabled=NO;
	
	NSArray *viewsToAnimate=[self subviewsToAnimateForViewController:[self topViewController]];
	
	[[self centerPoints] addObject:[NSValue valueWithCGPoint:lastTouchedPoint]];
	
	NSMutableArray *delayTimes=[NSMutableArray array];
	float minimumDelay=MAXFLOAT;
	for(UIView *thisView in viewsToAnimate){
		float thisDelay=[self timeDelayForView:thisView atZoomingPoint:lastTouchedPoint];
		[delayTimes addObject:[NSNumber numberWithFloat:thisDelay]];
		if(thisDelay<minimumDelay){
			minimumDelay=thisDelay;
		}
	}
	for(int i=0;i<[delayTimes count];i++){
		[delayTimes replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[delayTimes objectAtIndex:i]floatValue]-minimumDelay]];
	}
	
	float maxDelay=0;
	for (int i=0;i<[viewsToAnimate count];i++) {
		UIView *thisView = [viewsToAnimate objectAtIndex:i];
		float thisDelay=[[delayTimes objectAtIndex:i]floatValue];
		[self performSelector:@selector(zoomInHide:) withObject:thisView afterDelay:thisDelay];
		if(!disableFade){
			if(thisDelay>maxDelay){
				maxDelay=thisDelay;
			}
		}
	}
	maxDelay+=animationDuration;
	[self performSelector:@selector(pushIntoViewController:) withObject:nextController afterDelay:maxDelay-0.05];
	[nextController autorelease];
}
-(void)pushIntoViewController:(UIViewController*)viewController{
	UIViewController *lastController=[self topViewController];
	[self pushViewController:viewController animated:NO];
	
	NSArray *animatedViews=[self subviewsToAnimateForViewController:lastController];
	for (UIView *thisView in animatedViews) {
		[thisView.layer removeAllAnimations];
		if(!disableFade){
			thisView.layer.opacity=1;
		}
	}
	lastController.view.userInteractionEnabled=YES;
	
	[self pushIntoViewController:viewController reallyPush:NO];
}
-(void)pushIntoViewController:(UIViewController*)viewController reallyPush:(BOOL)forcedPush{
	
	BOOL reallyPush=YES;
	if(forcedPush){
		reallyPush=YES;
	}else if([viewController respondsToSelector:@selector(shouldWaitForViewToLoadBeforePush)]){
		reallyPush=![(id)viewController shouldWaitForViewToLoadBeforePush]; //Prepare only, don't push now
	}
	
	viewController.view.userInteractionEnabled=NO;
	NSArray *viewsToAnimate=[self subviewsToAnimateForViewController:[self topViewController]];
	
	NSMutableArray *delayTimes=[NSMutableArray array];
	float minimumDelay=MAXFLOAT;
	for(UIView *thisView in viewsToAnimate){
		float thisDelay=[self timeDelayForView:thisView atZoomingPoint:lastTouchedPoint];
		[delayTimes addObject:[NSNumber numberWithFloat:thisDelay]];
		if(thisDelay<minimumDelay){
			minimumDelay=thisDelay;
		}
	}
	for(int i=0;i<[delayTimes count];i++){
		[delayTimes replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[delayTimes objectAtIndex:i]floatValue]-minimumDelay]];
	}
	
	float maxDelay=0;
	for (int i=0;i<[viewsToAnimate count];i++) {
		UIView *thisView = [viewsToAnimate objectAtIndex:i];
		float thisDelay=[[delayTimes objectAtIndex:i]floatValue];
		
		[self prepareZoomInShow:thisView];
		if(reallyPush){
			[self performSelector:@selector(zoomInShow:) withObject:thisView afterDelay:thisDelay];
		}
		if(thisDelay>maxDelay){
			maxDelay=thisDelay;
		}
	}
	maxDelay+=bounceAnimationDuration;
	if(reallyPush){
		[self performSelector:@selector(finishedZoomInShow:) withObject:viewController afterDelay:maxDelay];
	}
}
-(void)zoomInHide:(UIView*)theView{
	CGRect absoluteRect=[[theView superview] convertRect:theView.frame toView:self.view];
	
	float xDifferent=(absoluteRect.origin.x+absoluteRect.size.width/2-lastTouchedPoint.x)*(zoomingFactor-1);
	float yDifferent=(absoluteRect.origin.y+absoluteRect.size.height/2-lastTouchedPoint.y)*(zoomingFactor-1);
	
	CALayer *layer=theView.layer;
	CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	positionAnimation.removedOnCompletion=NO;
	positionAnimation.duration=animationDuration;
    //animation.fromValue = [layer valueForKey:@"position"];
	CGPoint targetPosition=CGPointMake(layer.position.x+xDifferent, layer.position.y+yDifferent);
    positionAnimation.toValue = [NSValue valueWithCGPoint:targetPosition];
	positionAnimation.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.97 :0.15 :1.00 :1.00]; //smoother!
	
    // Update the layer's position so that the layer doesn't snap back when the animation completes.
    //layer.position = [positionAnimation.toValue CGPointValue];
	
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:positionAnimation forKey:@"position"];
	
	CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	resizeAnimation.removedOnCompletion=positionAnimation.removedOnCompletion;
	resizeAnimation.timingFunction=positionAnimation.timingFunction;
	resizeAnimation.toValue=[NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), zoomingFactor, zoomingFactor, zoomingFactor)];
	resizeAnimation.duration=positionAnimation.duration;
	[layer addAnimation:resizeAnimation forKey:@"bounds"];
	
	if(!disableFade){
		CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		fadeAnimation.timingFunction=positionAnimation.timingFunction;
		[fadeAnimation setToValue:[NSNumber numberWithFloat:0]];
		fadeAnimation.fillMode = kCAFillModeForwards;
		fadeAnimation.removedOnCompletion = positionAnimation.removedOnCompletion;
		fadeAnimation.duration=positionAnimation.duration;//0.13;
		//fadeAnimation.delegate=self;
		
		[layer addAnimation:fadeAnimation forKey:@"opacity"];
	}
}
-(void)prepareZoomInShow:(UIView*)theView{
	if(!disableFade){
		theView.layer.opacity=0;
	}
}
-(void)zoomInShow:(UIView*)theView{
	CALayer *layer=theView.layer;
	
	CGPoint targetPosition=lastTouchedPoint;
	
	SecondOrderResponseEvaluator *evaluator=[[[SecondOrderResponseEvaluator alloc] initWithOmega:14.825 zeta:0.44] autorelease];
	
	AccelerationAnimation *animation =[AccelerationAnimation
									   animationWithKeyPath:@"position.y"
									   startValue:targetPosition.y
									   endValue:layer.position.y
									   evaluationObject:evaluator
									   interstitialSteps:99];
	animation.duration=bounceAnimationDuration;
	[layer addAnimation:animation forKey:@"positiony"];
	
	AccelerationAnimation *animationx =[AccelerationAnimation
									   animationWithKeyPath:@"position.x"
									   startValue:targetPosition.x
									   endValue:layer.position.x
									   evaluationObject:evaluator
									   interstitialSteps:99];
	animationx.duration=animation.duration;
	[layer addAnimation:animationx forKey:@"positionx"];
	
	AccelerationAnimation *animationh =[AccelerationAnimation
										animationWithKeyPath:@"transform"
										startZoomValue:1/zoomingFactor
										endZoomValue:1
										evaluationObject:evaluator
										interstitialSteps:99];
	animationh.duration=animation.duration;
	[layer addAnimation:animationh forKey:@"transform"];
	
	if(!disableFade){
		CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		//fadeAnimation.timingFunction=positionAnimation.timingFunction;
		[fadeAnimation setToValue:[NSNumber numberWithFloat:1]];
		fadeAnimation.fillMode = kCAFillModeForwards;
		fadeAnimation.removedOnCompletion = NO;
		fadeAnimation.duration=animationDuration;//0.13;
		//fadeAnimation.delegate=self;
		
		[layer addAnimation:fadeAnimation forKey:@"opacity"];
	}
}
-(void)finishedZoomInShow:(UIViewController*)viewController{
	viewController.view.userInteractionEnabled=YES;
	NSArray *views=[self subviewsToAnimateForViewController:viewController];
	for (UIView *thisView in views) {
		if([thisView class]!=[UIActivityIndicatorView class]){
			[thisView.layer removeAllAnimations];
		}
		if(!disableFade){
			thisView.layer.opacity=1;
		}
	}
	if([viewController respondsToSelector:@selector(pushInAnimationDidFinished)]){
		[(id)viewController pushInAnimationDidFinished];
	}
	isAnimating=NO;
}
#pragma mark -
#pragma mark Pop
-(void)popViewControllerAnimated:(BOOL)animated{
	[self popToViewController:nil animated:animated];
}
-(void)popToRootViewControllerAnimated:(BOOL)animated{
	if([[self viewControllers]count]>1){
		[self popToViewController:[[self viewControllers] objectAtIndex:0] animated:animated];
	}
}
-(void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
	if([[self viewControllers]count]<=1)return;
	if(viewController){
		nextController=viewController;
	}else{
		nextController=[[self viewControllers] objectAtIndex:[[self viewControllers] count]-2];
	}
	if(!animated){
		[super popToViewController:nextController animated:animated];
	}
	
	isAnimating=YES;
	
	[self topViewController].view.userInteractionEnabled=NO;
	NSArray *viewsToAnimate=[self subviewsToAnimateForViewController:[self topViewController]];
	
	int indexOfNextViewController=[[self viewControllers]indexOfObject:nextController];
	lastTouchedPoint=[((NSValue*)[[self centerPoints] objectAtIndex:indexOfNextViewController]) CGPointValue];
	
	NSMutableArray *delayTimes=[NSMutableArray array];
	float minimumDelay=MAXFLOAT;
	for(UIView *thisView in viewsToAnimate){
		float thisDelay=[self timeDelayForView:thisView atZoomingPoint:lastTouchedPoint];
		[delayTimes addObject:[NSNumber numberWithFloat:thisDelay]];
		if(thisDelay<minimumDelay){
			minimumDelay=thisDelay;
		}
	}
	for(int i=0;i<[delayTimes count];i++){
		[delayTimes replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[delayTimes objectAtIndex:i]floatValue]-minimumDelay]];
	}
	
	float maxDelay=0;
	for (int i=0;i<[viewsToAnimate count];i++) {
		UIView *thisView = [viewsToAnimate objectAtIndex:i];
		float thisDelay=[[delayTimes objectAtIndex:i]floatValue];
		[self performSelector:@selector(zoomOutHide:) withObject:thisView afterDelay:thisDelay];
		if(!disableFade){
			if(thisDelay>maxDelay){
				maxDelay=thisDelay;
			}
		}
	}
	maxDelay+=animationDuration;
	[self performSelector:@selector(popOutToViewController:) withObject:nextController afterDelay:maxDelay];
}

-(void)zoomOutHide:(UIView*)theView{
	
	CALayer *layer=theView.layer;
	CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	positionAnimation.removedOnCompletion=NO;
	positionAnimation.duration=animationDuration;
    //animation.fromValue = [layer valueForKey:@"position"];
	CGPoint targetPosition=lastTouchedPoint;
	
    positionAnimation.toValue = [NSValue valueWithCGPoint:[self.view convertPoint:targetPosition toView:theView.superview]];
	positionAnimation.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.97 :0.15 :1.00 :1.00]; //smoother!
	
    // Update the layer's position so that the layer doesn't snap back when the animation completes.
    //layer.position = [positionAnimation.toValue CGPointValue];
	
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:positionAnimation forKey:@"position"];
	
	CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	resizeAnimation.removedOnCompletion=positionAnimation.removedOnCompletion;
	resizeAnimation.timingFunction=positionAnimation.timingFunction;
	resizeAnimation.toValue=[NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1/zoomingFactor, 1/zoomingFactor, 1/zoomingFactor)];
	resizeAnimation.duration=positionAnimation.duration;
	[layer addAnimation:resizeAnimation forKey:@"bounds"];
	
	if(!disableFade){
		CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		fadeAnimation.timingFunction=positionAnimation.timingFunction;
		[fadeAnimation setToValue:[NSNumber numberWithFloat:0]];
		fadeAnimation.fillMode = kCAFillModeForwards;
		fadeAnimation.removedOnCompletion = positionAnimation.removedOnCompletion;
		fadeAnimation.duration=positionAnimation.duration;//0.13;
		//fadeAnimation.delegate=self;
		
		[layer addAnimation:fadeAnimation forKey:@"opacity"];
	}
}
-(void)popOutToViewController:(UIViewController*)viewController{
	NSArray *animatedViews=[self subviewsToAnimateForViewController:[self topViewController]];
	for (UIView *thisView in animatedViews) {
		[thisView.layer removeAllAnimations];
		if(!disableFade){
			thisView.layer.opacity=1;
		}
	}
	[self topViewController].view.userInteractionEnabled=YES;
	[super popToViewController:viewController animated:NO];
	[self topViewController].view.userInteractionEnabled=NO;
	
	if([viewController respondsToSelector:@selector(poppedOutFromSubviewController)]){
		[(id)viewController poppedOutFromSubviewController];
	}
	
	[[self centerPoints] removeObjectsInRange:NSMakeRange([[self viewControllers]indexOfObject:viewController], [[self viewControllers] count]-[[self viewControllers]indexOfObject:viewController])];
	
	NSArray *viewsToAnimate=[self subviewsToAnimateForViewController:[self topViewController]];
	
	NSMutableArray *delayTimes=[NSMutableArray array];
	float minimumDelay=MAXFLOAT;
	for(UIView *thisView in viewsToAnimate){
		float thisDelay=[self timeDelayForView:thisView atZoomingPoint:lastTouchedPoint];
		[delayTimes addObject:[NSNumber numberWithFloat:thisDelay]];
		if(thisDelay<minimumDelay){
			minimumDelay=thisDelay;
		}
	}
	for(int i=0;i<[delayTimes count];i++){
		[delayTimes replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[delayTimes objectAtIndex:i]floatValue]-minimumDelay]];
	}
	
	float maxDelay=0;
	for (int i=0;i<[viewsToAnimate count];i++) {
		UIView *thisView = [viewsToAnimate objectAtIndex:i];
		float thisDelay=[[delayTimes objectAtIndex:i]floatValue];
		
		[self prepareZoomOutShow:thisView];
		[self performSelector:@selector(zoomOutShow:) withObject:thisView afterDelay:thisDelay];
		if(thisDelay>maxDelay){
			maxDelay=thisDelay;
		}
	}
	maxDelay+=bounceAnimationDuration;
	[self performSelector:@selector(finishedZoomOutShow:) withObject:nextController afterDelay:maxDelay];
}
-(void)prepareZoomOutShow:(UIView*)theView{
	if(!disableFade){
		theView.layer.opacity=0;
	}
}
-(void)zoomOutShow:(UIView*)theView{
	if(!disableFade){
		theView.layer.opacity=1;
	}
	
	CGRect absoluteRect=[[theView superview] convertRect:theView.frame toView:self.view];
	
	float xDifferent=(absoluteRect.origin.x+absoluteRect.size.width/2-lastTouchedPoint.x)*(zoomOutFactor-1);
	float yDifferent=(absoluteRect.origin.y+absoluteRect.size.height/2-lastTouchedPoint.y)*(zoomOutFactor-1);
	
	CALayer *layer=theView.layer;
	CGPoint targetPosition=CGPointMake(layer.position.x+xDifferent, layer.position.y+yDifferent);
	
	SecondOrderResponseEvaluator *evaluator=[[[SecondOrderResponseEvaluator alloc] initWithOmega:14.825 zeta:0.44] autorelease];
	
	AccelerationAnimation *animation =[AccelerationAnimation
									   animationWithKeyPath:@"position.y"
									   startValue:targetPosition.y
									   endValue:layer.position.y
									   evaluationObject:evaluator
									   interstitialSteps:99];
	animation.duration=bounceAnimationDuration;
	[layer addAnimation:animation forKey:@"positiony"];
	
	AccelerationAnimation *animationx =[AccelerationAnimation
										animationWithKeyPath:@"position.x"
										startValue:targetPosition.x
										endValue:layer.position.x
										evaluationObject:evaluator
										interstitialSteps:99];
	animationx.duration=animation.duration;
	[layer addAnimation:animationx forKey:@"positionx"];
	
	AccelerationAnimation *animationh =[AccelerationAnimation
										animationWithKeyPath:@"transform"
										startZoomValue:zoomOutFactor
										endZoomValue:1
										evaluationObject:evaluator
										interstitialSteps:99];
	animationh.duration=animation.duration;
	[layer addAnimation:animationh forKey:@"transform"];
	////
	
	if(!disableFade){
		CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		//fadeAnimation.timingFunction=positionAnimation.timingFunction;
		[fadeAnimation setFromValue:[NSNumber numberWithFloat:fadeOutOpacity]];
		fadeAnimation.fillMode = kCAFillModeForwards;
		fadeAnimation.removedOnCompletion = NO;
		fadeAnimation.duration=animationDuration;//0.13;
		fadeAnimation.delegate=self;
		
		[layer addAnimation:fadeAnimation forKey:@"opacity"];
	}
}
-(void)finishedZoomOutShow:(UIViewController*)viewController{
	[self topViewController].view.userInteractionEnabled=YES;
	NSArray *views=[self subviewsToAnimateForViewController:viewController];
	for (UIView *thisView in views) {
		[thisView.layer removeAllAnimations];
		if(!disableFade){
			thisView.layer.opacity=1;
		}
	}
	isAnimating=NO;
}
#pragma mark -
#pragma mark Pressing
-(void)didTouchMovedTransparentView:(id)sender atPoint:(CGPoint)point{
	NSArray *subviews=[self subviewsToAnimateForViewController:[self topViewController]];
	for(UIView *thisView in subviews){
		
		CGPoint targetPosition=CGPointMake(thisView.frame.origin.x+(point.x-thisView.frame.origin.x)*pressShiftFactor, thisView.frame.origin.y+(point.y-thisView.frame.origin.y)*pressShiftFactor) ;
		
		//thisView.layer.position=targetPosition;
		
		thisView.layer.transform=CATransform3DScale(CATransform3DMakeTranslation((point.x-thisView.frame.origin.x)*pressShiftFactor, (point.y-thisView.frame.origin.y)*pressShiftFactor, 0), 1/pressZoomFactor, 1/pressZoomFactor, 1/pressZoomFactor);
	}
}
-(void)didTouchEndedTransparentView:(id)sender atPoint:(CGPoint)point{
	NSArray *subviews=[self subviewsToAnimateForViewController:[self topViewController]];
	for(UIView *thisView in subviews){
		thisView.layer.transform=CATransform3DScale(CATransform3DMakeTranslation(0,0, 0), 1, 1, 1);
	}
}
#pragma mark -
#pragma mark Misc
-(float)timeDelayForView:(UIView*)theView atZoomingPoint:(CGPoint)point{
	CGRect absoluteRect=[[theView superview] convertRect:theView.frame toView:self.view];
	CGPoint viewCenterPoint=CGPointMake(absoluteRect.origin.x+absoluteRect.size.width/2, absoluteRect.origin.y+absoluteRect.size.height/2);
	float distance=(float)sqrt(pow(viewCenterPoint.x-point.x,2)+pow(viewCenterPoint.y-point.y, 2));
	return zoomDelayPerPixelFromCenter*distance;
}

-(NSArray*)subviewsToAnimateForViewController:(UIViewController*)controller{
	if([controller respondsToSelector:@selector(viewsForNichijyouNavigationControllerToAnimate:)]){
		return [controller viewsForNichijyouNavigationControllerToAnimate:self];
	}
	return controller.view.subviews;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	if(centerPoints)[centerPoints release];
    [super dealloc];
}


@end

//
//  NichijyouNavigationController.h
//  NichijyouNavigationController
//
//  Created by b123400 on 08/05/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NichijyouTransparentView.h"

@protocol NichijyouNavigationControllerDelegate
@optional

-(BOOL)shouldWaitForViewToLoadBeforePush;

-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender;

-(void)pushInAnimationDidFinished;
-(BOOL)shouldPopByPinch;
-(void)didStartedPinching;
-(void)didPinched;
-(void)didCancelledPinching;
-(void)willPopOutFromSubviewController:(UIViewController*)controller;
-(void)poppedOutFromSubviewController;

@end


@interface NichijyouNavigationController : UINavigationController <NichijyouTransparentViewDelegate,UIGestureRecognizerDelegate> {
	NSMutableArray *centerPoints;
	CGPoint lastTouchedPoint;
    NSMutableDictionary *tempTransfroms;
	
	UIViewController *nextController;
	BOOL disableFade;
	BOOL isAnimating;
    
    UIGestureRecognizer *pinchGestureRecognizer;
}

@property (nonatomic,assign) BOOL disableFade;
@property (nonatomic,retain) UIGestureRecognizer *pinchGestureRecognizer;

-(void)pushViewController:(UIViewController *)viewController atCenter:(CGPoint)center;

-(void)viewCanBePushed:(UIViewController*)controller;

@end

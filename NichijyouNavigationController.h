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

-(BOOL)shouldWaitForViewToLoadBeforePush;

-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender;

-(void)pushInAnimationDidFinished;
-(BOOL)shouldPopByPinch;
-(void)didPinched;
-(void)poppedOutFromSubviewController;

@end


@interface NichijyouNavigationController : UINavigationController <NichijyouTransparentViewDelegate> {
	NSMutableArray *centerPoints;
	CGPoint lastTouchedPoint;
	
	UIViewController *nextController;
	BOOL disableFade;
	BOOL isAnimating;
}

@property (nonatomic,assign) BOOL disableFade;

-(void)pushViewController:(UIViewController *)viewController atCenter:(CGPoint)center;

-(void)viewCanBePushed:(UIViewController*)controller;

@end

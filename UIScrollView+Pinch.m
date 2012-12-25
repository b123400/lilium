//
//  UIScrollView+Pinch.m
//  perSecond
//
//  Created by b123400 on 13/12/12.
//
//

#import "UIScrollView+Pinch.h"
#import "NichijyouNavigationController.h"

@implementation UIScrollView (Pinch)

-(void)didMoveToSuperview{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startedPinch) name:@"NichijyouNavigationControllerDelegateDidStartedPinchNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndedPinch) name:@"NichijyouNavigationControllerDelegateDidPinchedNotification" object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super dealloc];
}

-(void)startedPinch{
    self.scrollEnabled=NO;
}
-(void)didEndedPinch{
    self.scrollEnabled=YES;
}
@end

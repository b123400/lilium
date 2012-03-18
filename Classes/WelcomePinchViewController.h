//
//  WelcomePinchViewController.h
//  perSecond
//
//  Created by b123400 on 16/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WelcomePinchViewControllerDelegate

-(void)welcomePinchDidPinched;

@end


@interface WelcomePinchViewController : UIViewController {
	id <WelcomePinchViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id delegate;

@end

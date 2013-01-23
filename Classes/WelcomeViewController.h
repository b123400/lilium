//
//  WelcomeViewController.h
//  perSecond
//
//  Created by b123400 on 12/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WelcomeViewController : UIViewController {
	IBOutlet UIView *initialPinchView;
	IBOutlet UIView *noAccountView;
	IBOutlet UIView *mainView;
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *accountButton;
    IBOutlet UIButton *settingsButton;
    IBOutlet UIButton *aboutButton;
}

-(IBAction)getStartPressed;
-(void)refreshView;

-(IBAction)goTimeline;
-(IBAction)goAddAccount;

@end

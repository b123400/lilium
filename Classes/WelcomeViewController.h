//
//  WelcomeViewController.h
//  perSecond
//
//  Created by b123400 on 12/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleButton.h"

@interface WelcomeViewController : UIViewController <TitleButtonDelegate> {
	IBOutlet UIView *initialPinchView;
    IBOutlet UIButton *getStartedButton;
	IBOutlet UIView *noAccountView;
	IBOutlet UIView *mainView;
    IBOutlet TitleButton *timelineButton;
    IBOutlet UIButton *accountButton;
    IBOutlet UIButton *settingsButton;
    IBOutlet UIButton *aboutButton;
}

-(IBAction)getStartPressed;
-(void)refreshView;

-(IBAction)goTimeline;
-(IBAction)goAddAccount;
- (IBAction)goSettings:(id)sender;
- (IBAction)goAbout:(id)sender;

@end

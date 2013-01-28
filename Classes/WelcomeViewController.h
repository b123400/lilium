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
    
    UIAlertView *loadingAlert;
}

-(IBAction)getStartPressed;
-(void)refreshView;

-(IBAction)goTimeline;
-(IBAction)goAddAccount;
- (IBAction)goIntroducation:(id)sender;
- (IBAction)goSettings:(id)sender;

@end

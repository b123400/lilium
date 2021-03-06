//
//  WelcomeViewController.h
//  perSecond
//
//  Created by b123400 on 02/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterLoginController.h"
#import "FacebookLoginController.h"
#import "InstagramLoginViewController.h"
#import "FlickrLoginViewController.h"
#import "TumblrLoginViewController.h"

#define AccountsDidUpdatedNotification @"AccountsDidUpdatedNotification"

@interface AccountsViewController : UIViewController <TwitterLoginControllerDelegate,BRInstagramLoginViewControllerDelegate,FlickrLoginViewControllerDelegate,TumblrLoginViewControllerDelegate> {
    
    IBOutlet UILabel *titleLabel;
	IBOutlet UIButton *twitterButton;
	IBOutlet UIButton *facebookButton;
	IBOutlet UIButton *instagramButton;
	IBOutlet UIButton *flickrButton;
	IBOutlet UIButton *tumblrButton;
	
	NSMutableArray *tickImageViews;
}
@property (assign) id delegate;

-(IBAction)loginWithTwitter;
-(IBAction)loginWithFacebook;
-(IBAction)loginWithInstagram;
-(IBAction)loginWithFlickr;
-(IBAction)loginWithTumblr;
-(IBAction)loginWithPlurk;

-(void)refreshLoginStatus;

@end

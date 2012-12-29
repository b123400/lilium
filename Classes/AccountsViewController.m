//
//  WelcomeViewController.m
//  perSecond
//
//  Created by b123400 on 02/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "AccountsViewController.h"
#import "BRFunctions.h"

#import "SVProgressHUD.h"
#import "UIView+Interaction.h"
#import "UIControl+Interaction.h"
#import "BRCircleAlert.h"

#import "Status.h"

@implementation AccountsViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/
-(id)init{
	tickImageViews=[[NSMutableArray alloc]init];
	return [self initWithNibName:@"AccountsViewController" bundle:nil];
}

#pragma mark Twitter
-(void)loginWithTwitter{
    if(![BRFunctions didLoggedInTwitter]){
        TwitterLoginController *twitterController=[[TwitterLoginController alloc]init];
        twitterController.delegate=self;
        [self.navigationController pushViewController:twitterController animated:YES];
        [twitterController release];
    }else{
        [[BRCircleAlert confirmAlertWithText:@"Are you sure to logout Twitter?" action:^{
            [BRFunctions logoutTwitter];
            [self refreshLoginStatus];
        }] show];
    }
}
-(void)twitterLoginControllerDidReceivedAccessToken:(OAToken*)token{
	[BRFunctions saveTwitterToken:token];
}

#pragma mark Facebook
-(void)loginWithFacebook{
    if(![BRFunctions isFacebookLoggedIn:NO]){
        FacebookLoginController *facebookController=[[FacebookLoginController alloc]init];
        [self.navigationController pushViewController:facebookController animated:YES];
        [facebookController release];
    }else{
        [[BRCircleAlert confirmAlertWithText:@"Are you sure to logout Facebook?" action:^{
            [[BRFunctions sharedFacebook] logout:[BRFunctions sharedObject]];
            [self refreshLoginStatus];
        }] show];
    }
}

#pragma mark Instagram
-(void)loginWithInstagram{
    if(![BRFunctions didLoggedInInstagram]){
        InstagramLoginViewController *instagramController=[[InstagramLoginViewController alloc]initWithInstagramEngine:[BRFunctions sharedInstagram]];
        instagramController.delegate=self;
        [self.navigationController pushViewController:instagramController animated:YES];
        [instagramController release];
    }else{
        [[BRCircleAlert confirmAlertWithText:@"Are you sure to logout Instagram?" action:^{
            [BRFunctions logoutInstagram];
            [self refreshLoginStatus];
        }] show];
    }
}
-(void)didReceivedInstagramToken:(NSString*)token{
	[BRFunctions saveInstagramToken:token];
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)didFailedToReceiveInstagramToken{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Flickr
-(void)loginWithFlickr{
    if(![BRFunctions didLoggedInFlickr]){
        FlickrLoginViewController *flickrController=[[FlickrLoginViewController alloc]init];
        flickrController.delegate=self;
        [self.navigationController pushViewController:flickrController animated:YES];
        [flickrController release];
    }else{
        [[BRCircleAlert confirmAlertWithText:@"Are you sure to logout Flickr?" action:^{
            [BRFunctions logoutFlickr];
            [self refreshLoginStatus];
        }]show];
    }
}
-(void)flickrLoginControllerDidReceivedAccessToken:(OAToken*)token{
	[BRFunctions saveFlickrToken:token];
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark Tumblr
-(IBAction)loginWithTumblr{
    if(![BRFunctions didLoggedInTumblr]){
        TumblrLoginViewController *tumblrController=[[TumblrLoginViewController alloc]init];
        tumblrController.delegate=self;
        [self.navigationController pushViewController:tumblrController animated:YES];
        [tumblrController release];
    }else{
        [[BRCircleAlert confirmAlertWithText:@"Are you sure to logout Tumblr?" action:^{
            [BRFunctions logoutTumblr];
            [self refreshLoginStatus];
        }]show];
    }
}
-(void)tumblrLoginViewController:(id)sender didReceivedAccessToken:(OAToken*)token{
	[BRFunctions saveTumblrToken:token];
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)tumblrLoginViewController:(id)sender failedWithError:(NSError*)error{
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark Plurk
-(IBAction)loginWithPlurk{
	
}
#pragma mark -
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	for(int i=0;i<5;i++){
		UIImageView *imageView=[[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loggedInCover.png"]] autorelease];
		imageView.userInteractionEnabled=NO;
		imageView.hidden=YES;
		[tickImageViews addObject:imageView];
		
		switch (i) {
			case StatusSourceTypeTwitter:
				[twitterButton.imageView addSubview:imageView];
				break;
			case StatusSourceTypeFacebook:
				[facebookButton.imageView addSubview:imageView];
				break;
			case StatusSourceTypeInstagram:
				[instagramButton.imageView addSubview:imageView];
				break;
			case StatusSourceTypeFlickr:
				[flickrButton.imageView addSubview:imageView];
				break;
			case StatusSourceTypeTumblr:
				[tumblrButton.imageView addSubview:imageView];
				break;
			default:
				break;
		}
	}
	
	[self refreshLoginStatus];
	
    [super viewDidLoad];
}

-(void)refreshLoginStatus{
	((UIImageView*)[tickImageViews objectAtIndex:StatusSourceTypeTwitter]).hidden=![BRFunctions didLoggedInTwitter];
	((UIImageView*)[tickImageViews objectAtIndex:StatusSourceTypeFacebook]).hidden=![BRFunctions isFacebookLoggedIn:NO];
	((UIImageView*)[tickImageViews objectAtIndex:StatusSourceTypeInstagram]).hidden=![BRFunctions didLoggedInInstagram];
	((UIImageView*)[tickImageViews objectAtIndex:StatusSourceTypeFlickr]).hidden=![BRFunctions didLoggedInFlickr];
	((UIImageView*)[tickImageViews objectAtIndex:StatusSourceTypeTumblr]).hidden=![BRFunctions didLoggedInTumblr];
}
-(void)poppedOutFromSubviewController{
	[self refreshLoginStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountsDidUpdatedNotification object:nil];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[tickImageViews removeAllObjects];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

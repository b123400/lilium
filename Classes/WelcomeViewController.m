//
//  WelcomeViewController.m
//  perSecond
//
//  Created by b123400 on 12/07/2011.
//  Copyright 2011 home. All rights reserved.
//
#import "WelcomeViewController.h"
#import "BRFunctions.h"
#import "WelcomePinchViewController.h"
#import "AccountsViewController.h"
#import "TimelineViewController.h"
#import "BRCircleAlert.h"
#import "UIApplication+Frame.h"
#import <QuartzCore/QuartzCore.h>

@implementation WelcomeViewController

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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]     addObserver:self selector:@selector(orientationChanged:)     name:UIDeviceOrientationDidChangeNotification     object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:AccountsDidUpdatedNotification object:nil];
	return [self initWithNibName:@"WelcomeViewController" bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self refreshView];
    [super viewDidLoad];
}

-(void)refreshView{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSNumber *didPinched=[defaults objectForKey:@"initialPinched"];
	if(!didPinched||![didPinched boolValue]){
		self.view=initialPinchView;
	}else if(![BRFunctions didLoggedInFlickr]&&
			 ![BRFunctions didLoggedInTwitter]&&
			 ![BRFunctions didLoggedInInstagram]&&
			 ![BRFunctions isFacebookLoggedIn:NO]&&
			 ![BRFunctions didLoggedInTumblr]){
		self.view=noAccountView;
	}else{
		self.view=mainView;
	}
}

-(void)getStartPressed{
	WelcomePinchViewController *pinch=[[WelcomePinchViewController alloc]init];
	pinch.delegate=self;
	[self.navigationController pushViewController:pinch animated:YES];
	[pinch release];
}
-(void)welcomePinchDidPinched{
	[[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"initialPinched"];
	[self refreshView];
}

-(IBAction)goTimeline{
	TimelineViewController *timelineController=[[TimelineViewController alloc]init];
	[self.navigationController pushViewController:timelineController animated:YES];
	[timelineController release];
}

-(IBAction)goAddAccount{
	AccountsViewController *accountController=[[AccountsViewController alloc]init];
	[self.navigationController pushViewController:accountController animated:YES];
	[accountController release];
}

-(void)poppedOutFromSubviewController{
	[self refreshView];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate {
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    return [self shouldAutorotateToInterfaceOrientation:orientation];
}
- (NSUInteger)supportedInterfaceOrientations
{
    //decide number of origination tob supported by Viewcontroller.
    return UIInterfaceOrientationMaskPortrait;
}
-(void)viewWillAppear:(BOOL)animated{
    [self updateLayoutForNewOrientation: [[UIDevice currentDevice] orientation]];
}
-(void)pushInAnimationDidFinished{
    [UIView animateWithDuration:0.2 animations:^{
        [self updateLayoutForNewOrientation: [[UIDevice currentDevice] orientation]];
    }];
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation{
    if(self.view==mainView){
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:{
                timelineButton.imageView.layer.transform=
                accountButton.imageView.layer.transform=
                settingsButton.imageView.layer.transform=CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
            }
                break;
            case UIInterfaceOrientationLandscapeRight:{
                timelineButton.imageView.layer.transform=
                accountButton.imageView.layer.transform=
                settingsButton.imageView.layer.transform=CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
            }
                break;
            case UIInterfaceOrientationPortrait:{
                timelineButton.imageView.layer.transform=
                accountButton.imageView.layer.transform=
                settingsButton.imageView.layer.transform=CATransform3DIdentity;
            }
                break;
                
            default:
                break;
        }
    }
}
- (void) orientationChanged:(NSNotification *)note{
    [UIView animateWithDuration:0.2 animations:^{
        [self updateLayoutForNewOrientation:[(UIDevice*)note.object orientation]];
    }];
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [timelineButton release];
    timelineButton = nil;
    [accountButton release];
    accountButton = nil;
    [settingsButton release];
    settingsButton = nil;
    [aboutButton release];
    aboutButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timelineButton release];
    [accountButton release];
    [settingsButton release];
    [aboutButton release];
    [super dealloc];
}


@end

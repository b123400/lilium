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
#import "SettingViewController.h"
#import "TimelineManager.h"
#import "UIButton+WebCache.h"
#import "AboutViewController.h"

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
-(instancetype)init{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]     addObserver:self selector:@selector(orientationChanged:)     name:UIDeviceOrientationDidChangeNotification     object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:AccountsDidUpdatedNotification object:nil];
	return [self initWithNibName:@"WelcomeViewController" bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    getStartedButton.layer.zPosition=1000;
	[self refreshView];
    aboutButton.titleLabel.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:aboutButton.titleLabel.font.pointSize];
    [timelineButton addGestureRecognizer:[[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goTimeline)] autorelease]];
}

-(void)refreshView{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSNumber *didPinched=[defaults objectForKey:@"initialPinched"];
    [initialPinchView removeFromSuperview];
    [noAccountView removeFromSuperview];
    [mainView removeFromSuperview];
    
	if(!didPinched||![didPinched boolValue]){
		[self.view addSubview:initialPinchView];
	}else if(![BRFunctions didLoggedInFlickr]&&
			 ![BRFunctions didLoggedInTwitter]&&
			 ![BRFunctions didLoggedInInstagram]&&
			 ![BRFunctions isFacebookLoggedIn:NO]&&
			 ![BRFunctions didLoggedInTumblr]){
		[self.view addSubview:noAccountView];
	}else{
		[self.view addSubview:mainView];
        mainView.frame = self.view.bounds;
	}
    
    Status *randomStatus=[[TimelineManager sharedManager]randomStatus];
    timelineButton.delegate=self;
    [timelineButton setImageWithURL:randomStatus.thumbURL];
    timelineButton.textLabel.text=@"Timeline";
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect frame = timelineButton.frame;
    frame.origin.x = settingsButton.frame.origin.x;
    timelineButton.frame = frame;
}

-(void)titleButtonDidFinishedAnimation:(id)button{
    Status *randomStatus=[[TimelineManager sharedManager]randomStatus];
    [timelineButton setImageWithURL:randomStatus.thumbURL];
}
-(void)pushInAnimationDidFinished{
    [timelineButton startAnimation];
}
-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
    if(mainView.superview){
        return @[timelineButton,accountButton,settingsButton,aboutButton];
    }
    return self.view.subviews;
}
-(void)getStartPressed{
	WelcomePinchViewController *pinch=[[WelcomePinchViewController alloc]init];
	pinch.delegate=self;
	[self.navigationController pushViewController:pinch animated:YES];
	[pinch release];
}
-(void)welcomePinchDidPinched{
	[[NSUserDefaults standardUserDefaults]setObject:@YES forKey:@"initialPinched"];
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

- (IBAction)goSettings:(id)sender {
    SettingViewController *settingViewController=[[SettingViewController alloc]init];
    [self.navigationController pushViewController:settingViewController animated:YES];
    [settingViewController release];
}

- (IBAction)goAbout:(id)sender {
    AboutViewController *controller=[[[AboutViewController alloc]init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)poppedOutFromSubviewController{
	[self refreshView];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //decide number of origination tob supported by Viewcontroller.
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}
-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [self updateLayoutForNewOrientation: [[UIDevice currentDevice] orientation]];
}

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation{
    if(mainView.superview){
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)return;
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:{
                timelineButton.textLabel.layer.transform=
                accountButton.imageView.layer.transform=
                settingsButton.imageView.layer.transform=CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
            }
                break;
            case UIInterfaceOrientationLandscapeRight:{
                timelineButton.backgroundImageView.layer.transform=
                timelineButton.textLabel.layer.transform=
                accountButton.imageView.layer.transform=
                settingsButton.imageView.layer.transform=CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
            }
                break;
            case UIInterfaceOrientationPortrait:{
                timelineButton.backgroundImageView.layer.transform=
                timelineButton.textLabel.layer.transform=
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
    [getStartedButton release];
    getStartedButton = nil;
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
    [getStartedButton release];
    [super dealloc];
}


@end

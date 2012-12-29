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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end

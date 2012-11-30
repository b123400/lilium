//
//  FacebookLoginController.m
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "FacebookLoginController.h"
#import "BRFunctions.h"
#import "SVProgressHUD.h"

@implementation FacebookLoginController

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin) name:facebookDidLoginNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin) name:facebookDidNotLoginNotification object:nil];
	
	return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	BOOL isLoggedIn=[BRFunctions isFacebookLoggedIn:YES];
	if(!isLoggedIn){
		loggedInButton.hidden=YES;
	}
    [super viewDidLoad];
}
-(void)pushInAnimationDidFinished{
	
}
-(IBAction)didTapped{
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)fbDidLogin{
	[[BRFunctions sharedFacebook] requestWithGraphPath:@"me" andDelegate:(id)self];
	[SVProgressHUD show];
	//[self.navigationController popViewControllerAnimated:YES];
}
-(void)fbDidNotLogin{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark FB request delegate


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
	[[BRFunctions sharedFacebook] logout:[BRFunctions sharedObject]];
	[SVProgressHUD dismissWithError:@"Failed"];
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)request:(FBRequest *)request didLoad:(id)result{
	if([result respondsToSelector:@selector(objectForKey:)]){
		if([result objectForKey:@"id"]){
			NSString *idString=[NSString stringWithFormat:@"%@",[result objectForKey:@"id"]];
			[BRFunctions setFacebookCurrentUserID:idString];
			[SVProgressHUD dismissWithSuccess:@"Success"];
			[self.navigationController popViewControllerAnimated:YES];
			return;
		}
	}
	[self request:request didFailWithError:nil];
}

#pragma mark -




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
    [super dealloc];
}


@end

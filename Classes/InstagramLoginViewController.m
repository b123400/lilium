//
//  InstagramLoginViewController.m
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "InstagramLoginViewController.h"
#import "SVProgressHUD.h"

@implementation InstagramLoginViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		
    }
    return self;
}

-(id)initWithInstagramEngine:(BRInstagramEngine*)_engine{
	backgroundBorderView=[[UIView alloc]initWithFrame:CGRectMake(6, 6, 307, 448)];
	backgroundBorderView.backgroundColor=[UIColor colorWithRed:153/255.0 green:102/255.0 blue:51/255.0 alpha:1.0];
	return [super initWithInstagramEngine:_engine];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view addSubview:backgroundBorderView];
	[self.view sendSubviewToBack:backgroundBorderView];
	webView.frame=CGRectMake(14, 16, 291, 429);
	webView.multipleTouchEnabled=NO;
}

-(void)didGetAccessToken:(NSString*)token{
	[super didGetAccessToken:token];
	[SVProgressHUD show];
	[SVProgressHUD dismissWithSuccess:@"Success"];
}
-(void)didFailedToGetAccessToken{
	[super didFailedToGetAccessToken];
	[SVProgressHUD show];
	[SVProgressHUD dismissWithError:@"Failed"];	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[SVProgressHUD dismiss];
}
-(void)pushInAnimationDidFinished{
	[SVProgressHUD show];
}
-(BOOL)shouldPopByPinch{
	[SVProgressHUD dismiss];
	return YES;
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
	[backgroundBorderView release];
    [super dealloc];
}


@end

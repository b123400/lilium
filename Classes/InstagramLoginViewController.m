//
//  InstagramLoginViewController.m
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "InstagramLoginViewController.h"
#import "SVProgressHUD.h"

@interface BRInstagramLoginViewController ()

-(void)didGetAccessToken:(NSString*)token;
-(void)didFailedToGetAccessToken;

@end

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
	backgroundBorderView=[[UIView alloc]init];
	return [super initWithInstagramEngine:_engine];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view addSubview:backgroundBorderView];
	[self.view sendSubviewToBack:backgroundBorderView];
    
    webView.layer.borderColor=[UIColor colorWithRed:153/255.0 green:102/255.0 blue:51/255.0 alpha:1.0].CGColor;
    webView.layer.borderWidth=6;
    webView.frame=CGRectInset(self.view.frame, 6, 6);
	webView.multipleTouchEnabled=NO;
}
-(void)viewDidAppear:(BOOL)animated{
    
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
- (void)webViewDidStartLoad:(UIWebView *)_webView{
    [SVProgressHUD show];
    if([super respondsToSelector:@selector(webViewDidStartLoad:)]){
        [super webViewDidStartLoad:_webView];
    }
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
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

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

//
//  BRInstagramLoginViewController.m
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRInstagramLoginViewController.h"

@interface BRInstagramLoginViewController ()

-(void)didGetAccessToken:(NSString*)token;
-(void)didFailedToGetAccessToken;

@end

@implementation BRInstagramLoginViewController
@synthesize delegate;

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
-(instancetype)initWithInstagramEngine:(BRInstagramEngine*)_engine{
	engine=[_engine retain];
	return [super initWithNibName:@"BRInstagramLoginViewController" bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[webView loadRequest:[NSURLRequest requestWithURL:[engine authURL:YES]]];
	//[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.instagram.com/oauth/authorize/?client_id=3a39c9aafa4146f8a06a688cb8a9781a&response_type=token&scope=likes+comments&display=touch&redirect_uri=perSecond%3A%2F%2Fauthed"]]];
    [super viewDidLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	if([[[request URL]absoluteString] rangeOfString:[[engine redirectUri]absoluteString]].location==0){
		NSString *params=[[request URL] fragment];
		NSRange range=[params rangeOfString:@"access_token="];
		if(params&&range.location!=NSNotFound){
			NSString *accessToken=[params substringFromIndex:range.location+range.length];
			[self didGetAccessToken:accessToken];
		}else{
			[self didFailedToGetAccessToken];
		}
		return NO;
	}
	return YES;
}
-(void)didGetAccessToken:(NSString*)token{
	engine.accessToken=token;
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(didReceivedInstagramToken:)]){
			[(id)delegate didReceivedInstagramToken:token];
		}
	}
}
-(void)didFailedToGetAccessToken{
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(didFailedToReceiveInstagramToken)]){
			[delegate didFailedToReceiveInstagramToken];
		}
	}
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
	[webView stopLoading];
	webView.delegate=nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[webView stopLoading];
	webView.delegate=nil;
	
	[engine release];
    [super dealloc];
}


@end

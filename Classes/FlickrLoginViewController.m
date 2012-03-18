//
//  FlickrLoginViewController.m
//  perSecond
//
//  Created by b123400 on 07/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "FlickrLoginViewController.h"
#import "BRFunctions.h"
#import "SVProgressHUD.h"

@interface FlickrLoginViewController ()

-(void)getAccessTokenFromQuery:(NSString*)query;

@end

@implementation FlickrLoginViewController
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
-(id)init{
	getter=[[BRFlickrOAuthTokenGetter alloc]initWithConsumerKey:flickrAPIKey consumerSecret:flickrAPISecret];
	getter.delegate=self;
	return [super initWithNibName:@"FlickrLoginViewController" bundle:nil];
}
-(void)pushInAnimationDidFinished{
	[getter getRequestToken];
	[SVProgressHUD show];
}
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
-(void)didReceivedRequestTokenURL:(NSURL*)url{
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSLog([[request  URL]absoluteString]);
	NSString *scheme=[[request URL] scheme];
	NSString *query=[[request URL] query];
	
	if([[[request URL]absoluteString] rangeOfString:@"authed?denied="].location!=NSNotFound){
		[self didFailedToReceiveAccessToken:nil];
		return NO;
	}
	
	if([[scheme lowercaseString] isEqualToString:@"persecond"]){
		[self getAccessTokenFromQuery:query];
		return NO;
	}
	return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)_webView{
	[SVProgressHUD dismiss];
}
- (void)webViewDidStartLoad:(UIWebView *)_webView{
	[SVProgressHUD show];
}
-(void)getAccessTokenFromQuery:(NSString*)query{
	NSArray *pairs=[query componentsSeparatedByString:@"&"];
	
	NSString *oauthToken=nil;
	NSString *oauthVerifier=nil;
	
	for(NSString *pair in pairs){
		NSArray *thisPair=[pair componentsSeparatedByString:@"="];
		if([thisPair count]>=2){
			NSString *name=[thisPair objectAtIndex:0];
			NSString *value=[thisPair objectAtIndex:1];
			if([name isEqualToString:@"oauth_token"]){
				oauthToken=[value retain];
			}else if([name isEqualToString:@"oauth_verifier"]){
				oauthVerifier=[value retain];
			}
		}
	}
	if(oauthToken&&oauthVerifier){
		[getter getAccessTokenWithOauthToken:oauthToken verifier:oauthVerifier];
		[SVProgressHUD show];
	}
	if(oauthToken)[oauthToken release];
	if(oauthVerifier)[oauthVerifier release];
}
-(void)didReceivedAccessToken:(SSToken*)token{
	[SVProgressHUD dismissWithSuccess:@"Success"];
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(flickrLoginControllerDidReceivedAccessToken:)]){
			[delegate flickrLoginControllerDidReceivedAccessToken:token];
		}
	}
}

-(void)didFailedToReceiveRequestToken:(NSError*)error{
	if([error code]==-1001){
		[SVProgressHUD dismissWithError:@"time out"];
	}else{
		[SVProgressHUD dismissWithError:@"Failed"];
	}
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)didFailedToReceiveAccessToken:(NSError*)error{
	if([error code]==-1001){
		[SVProgressHUD dismissWithError:@"time out"];
	}else{
		[SVProgressHUD dismissWithError:@"Failed"];
	}
	[self.navigationController popViewControllerAnimated:YES];
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
	[SVProgressHUD dismiss];
	getter.delegate=nil;
	[getter release];
	
	webView.delegate=nil;
	[webView stopLoading];
    [super dealloc];
}


@end

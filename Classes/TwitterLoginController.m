//
//  TwitterLoginController.m
//  perSecond
//
//  Created by b123400 on 02/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "TwitterLoginController.h"
#import "BRFunctions.h"
#import "SVProgressHUD.h"

#define kTimeoutLimit 30

@interface TwitterLoginController ()

@property (nonatomic, retain) NSTimer *timeoutTimer;

-(void)getAccessTokenFromQuery:(NSString*)query;

- (void)startTimeoutTimer;
- (void)stopTimeoutTimer;

@end

@implementation TwitterLoginController
@synthesize delegate;

static float loadingBorder=40.0;

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
	getter=[[BRTwitterOAuthTokenGetter alloc]initWithConsumerKey:kTwitterOAuthConsumerKey consumerSecret:kTwitterOAuthConsumerSecret];
	getter.delegate=self;
    self.timeoutTimer = nil;
	
	return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}
#pragma mark -
#pragma mark request token
-(void)didReceivedRequestTokenURL:(NSURL*)url{
    [self stopTimeoutTimer];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self startTimeoutTimer];
}
#pragma mark -
#pragma mark web view
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
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
	[loading stopAnimating];
	if(webView.hidden){
        [self stopTimeoutTimer];
		[UIView animateWithDuration:0.5 animations:^{
			backgroundBorderView.frame=CGRectInset(webView.frame, -5, -5);
		} completion:^(BOOL finished){
			CGRect webFrame=webView.frame;
			CGRect frame=webView.frame;
			frame.size.height=0;
			webView.frame=frame;
			webView.hidden=NO;
			[UIView animateWithDuration:0.5 animations:^{
				webView.frame=webFrame;
			} completion:^(BOOL finished){}
			 
			 ];
		}];
	}
}
#pragma mark access token
-(void)getAccessTokenFromQuery:(NSString*)query{
	NSArray *pairs=[query componentsSeparatedByString:@"&"];
	
	NSString *oauthToken=nil;
	NSString *oauthVerifier=nil;
	
	for(NSString *pair in pairs){
		NSArray *thisPair=[pair componentsSeparatedByString:@"="];
		if([thisPair count]>=2){
			NSString *name=thisPair[0];
			NSString *value=thisPair[1];
			if([name isEqualToString:@"oauth_token"]){
				oauthToken=[value retain];
			}else if([name isEqualToString:@"oauth_verifier"]){
				oauthVerifier=[value retain];
			}
		}
	}
	if(oauthToken&&oauthVerifier){
		[getter getAccessTokenWithOauthToken:oauthToken verifier:oauthVerifier];
		
		webView.hidden=YES;
		[UIView animateWithDuration:0.5 animations:^{
			backgroundBorderView.frame=CGRectMake(loading.frame.origin.x-loadingBorder, loading.frame.origin.y-loadingBorder, loading.frame.size.width+loadingBorder*2, loading.frame.size.height+loadingBorder*2);
		} ];
		[loading startAnimating];
        [self startTimeoutTimer];
	}
	if(oauthToken)[oauthToken release];
	if(oauthVerifier)[oauthVerifier release];
}

-(void)didReceivedAccessToken:(SSToken*)token{
    [self stopTimeoutTimer];
	[delegate twitterLoginControllerDidReceivedAccessToken:token];
	[SVProgressHUD show];
	[SVProgressHUD dismissWithSuccess:@"Success"];
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark error
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self stopTimeoutTimer];
    [SVProgressHUD show];
    [SVProgressHUD dismissWithError:error.localizedDescription];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didFailedToReceiveRequestToken:(NSError*)error{
    [self stopTimeoutTimer];
	[SVProgressHUD show];
	if(error){
		[SVProgressHUD dismissWithError:[error localizedDescription]];
	}else{
		[SVProgressHUD dismissWithError:@"Failed"];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)didFailedToReceiveAccessToken:(NSError*)error{
    [self stopTimeoutTimer];
	[SVProgressHUD show];
	if(error){
		[SVProgressHUD dismissWithError:[error localizedDescription]];
	}else{
		[SVProgressHUD dismissWithError:@"Failed"];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	fullBorder=backgroundBorderView.frame;
    CGRect frame = loading.frame;
    frame.origin.x = (self.view.frame.size.width-frame.size.width)/2;
    loading.frame = frame;
	backgroundBorderView.frame=CGRectMake(loading.frame.origin.x-loadingBorder, loading.frame.origin.y-loadingBorder, loading.frame.size.width+loadingBorder*2, loading.frame.size.height+loadingBorder*2);
	webView.hidden=YES;
	[loading startAnimating];
    [getter getRequestToken];
    [self startTimeoutTimer];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark timeout timer

- (void)startTimeoutTimer {
    if (self.timeoutTimer) return;
    self.timeoutTimer = [[NSTimer scheduledTimerWithTimeInterval:kTimeoutLimit
                                                          target:self
                                                        selector:@selector(timeoutTimerFired)
                                                        userInfo:nil
                                                         repeats:NO] retain];
}

- (void)stopTimeoutTimer {
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
        [self.timeoutTimer release];
        self.timeoutTimer = nil;
    }
}

- (void)timeoutTimerFired {
    [self stopTimeoutTimer];
    [SVProgressHUD show];
    [SVProgressHUD dismissWithError:@"Timeout"];
    [self.navigationController popViewControllerAnimated:YES];
}

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
	
	getter.delegate=nil;
	[getter release];
    [super dealloc];
}


@end

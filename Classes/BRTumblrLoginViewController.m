//
//  BRTumblrLoginViewController.m
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRTumblrLoginViewController.h"

@interface BRTumblrLoginViewController ()

-(id)init_;
-(void)failedWithError:(NSError*)error;

@end

@implementation BRTumblrLoginViewController
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
-(id)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
	return [self initWithConsumer:[[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]autorelease]];
}
-(id)initWithConsumer:(OAConsumer*)_consumer{
	getter=[[BRTumblrOAuthTokenGetter alloc]initWithConsumer:_consumer];
	getter.delegate=self;
	return [self init_];
}
-(id)init_{
	return [super initWithNibName:@"BRTumblrLoginViewController" bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[getter getRequestToken];
    [super viewDidLoad];
}

-(void)didReceivedRequestTokenURL:(NSURL*)url{
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	
	NSString *scheme=[[request URL] scheme];
	NSString *query=[[request URL] query];
	
	if([[[request URL]absoluteString] isEqualToString:tumblrOAuthCallBackURL]){
		[self failedWithError:nil];
		//User pressed no
		return NO;
	}
	
	if([[scheme lowercaseString] isEqualToString:@"persecond"]&&[[[request URL]absoluteString]rangeOfString:@"oauth_verifier"].location!=NSNotFound){
		[self getAccessTokenFromQuery:query];
		return NO;
	}
	
	
	return YES;
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
	}
	if(oauthToken)[oauthToken release];
	if(oauthVerifier)[oauthVerifier release];
}

-(void)didReceivedAccessToken:(SSToken*)token{
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(tumblrLoginViewController:didReceivedAccessToken:)]){
			[(id)delegate  tumblrLoginViewController:self didReceivedAccessToken:token];
		}
	}
}

-(void)didFailedToReceiveRequestToken:(NSError*)error{
	[self failedWithError:error];
}
-(void)didFailedToReceiveAccessToken:(NSError*)error{
	[self failedWithError:error];
}
-(void)failedWithError:(NSError*)error{
	if(!delegate)return;
	if(![(id)delegate respondsToSelector:@selector(tumblrLoginViewController:failedWithError:)])return;
	[delegate tumblrLoginViewController:self failedWithError:error];
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
	webView.delegate=nil;
	getter.delegate=nil;
	[getter release];
    [super dealloc];
}


@end

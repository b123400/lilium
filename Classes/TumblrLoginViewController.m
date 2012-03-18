//
//  TumblrLoginViewController.m
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "TumblrLoginViewController.h"
#import "BRFunctions.h"
#import "SVProgressHUD.h"

@implementation TumblrLoginViewController

-(id)init{
	backgroundBorderView=[[UIView alloc]initWithFrame:CGRectMake(6, 6, 307, 448)];
	backgroundBorderView.backgroundColor=[UIColor colorWithRed:44/255.0 green:71/255.0 blue:98/255.0 alpha:1.0];
	return [super initWithConsumerKey:tumblrAPIKey consumerSecret:tumblrAPISecret];
}

-(void)viewDidLoad{
	[super viewDidLoad];
	
	[self.view addSubview:backgroundBorderView];
	[self.view sendSubviewToBack:backgroundBorderView];
	webView.frame=CGRectMake(14, 16, 291, 429);
}
-(void)getAccessTokenFromQuery:(NSString*)query{
	[SVProgressHUD show];
	[super getAccessTokenFromQuery:query];
}
-(void)didReceivedAccessToken:(SSToken*)token{
	[super didReceivedAccessToken:token];
	[SVProgressHUD show];
	[SVProgressHUD dismissWithSuccess:@"Success"];
}
-(void)failedWithError:(NSError*)error{
	[super failedWithError:error];
	[SVProgressHUD show];
	[SVProgressHUD dismissWithError:@"Failed"];	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[SVProgressHUD dismiss];
}
-(void)pushInAnimationDidFinished{
	if(webView.loading){
		[SVProgressHUD show];
	}
}
-(BOOL)shouldPopByPinch{
	[SVProgressHUD dismiss];
	return YES;
}

-(void)dealloc{
	[backgroundBorderView release];
	[super dealloc];
}

@end

//
//  TumblrLoginViewController.m
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TumblrLoginViewController.h"
#import "BRFunctions.h"
#import "SVProgressHUD.h"

@implementation TumblrLoginViewController

-(id)init{
	return [super initWithConsumerKey:tumblrAPIKey consumerSecret:tumblrAPISecret];
}

-(void)viewDidLoad{
	[super viewDidLoad];

	webView.frame=CGRectInset(self.view.frame, 6, 6);
    webView.layer.borderColor=[UIColor colorWithRed:44/255.0 green:71/255.0 blue:98/255.0 alpha:1.0].CGColor;
    webView.layer.borderWidth=6;
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
	[super dealloc];
}

@end

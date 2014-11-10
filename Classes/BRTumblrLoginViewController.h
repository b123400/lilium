//
//  BRTumblrLoginViewController.h
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "BRTumblrOAuthTokenGetter.h"

#define tumblrOAuthCallBackURL @"perSecond://authed"

@protocol BRTumblrLoginViewControllerDelegate

-(void)tumblrLoginViewController:(id)sender didReceivedAccessToken:(OAToken*)token;
-(void)tumblrLoginViewController:(id)sender failedWithError:(NSError*)error;

@end


@interface BRTumblrLoginViewController : UIViewController <BROAuthTokenGetterDelegate> {
	IBOutlet UIWebView *webView;
	
	BRTumblrOAuthTokenGetter *getter;
	id <BRTumblrLoginViewControllerDelegate> delegate;
}

@property (nonatomic,assign) id <BRTumblrLoginViewControllerDelegate> delegate;

-(instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
-(instancetype)initWithConsumer:(OAConsumer*)_consumer;

@end

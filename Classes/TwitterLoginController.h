//
//  TwitterLoginController.h
//  perSecond
//
//  Created by b123400 on 02/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTwitterOAuthTokenGetter.h"

@protocol TwitterLoginControllerDelegate

-(void)twitterLoginControllerDidReceivedAccessToken:(OAToken*)token;

@end


@interface TwitterLoginController : UIViewController <UIWebViewDelegate,BROAuthTokenGetterDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *loading;
	IBOutlet UIView *backgroundBorderView;
	IBOutlet UILabel *statusLabel;
	
	BRTwitterOAuthTokenGetter *getter;
	CGRect fullBorder;
	
	id <TwitterLoginControllerDelegate> delegate;
}
@property (assign) id <TwitterLoginControllerDelegate> delegate;

@end

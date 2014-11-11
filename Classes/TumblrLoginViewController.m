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
#import <TMTumblrSDK/TMAPIClient.h>
#import <TMTumblrSDK/TMTumblrAuthenticator.h>

@implementation TumblrLoginViewController

-(instancetype)init{
    return [super init];
}

-(void)viewDidLoad{
	[super viewDidLoad];
}

-(void)pushInAnimationDidFinished{
    
    [[TMAPIClient sharedInstance] authenticate:@"persecond-tumblr" callback:^(NSError *error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(tumblrLoginViewController:failedWithError:)]) {
                [self.delegate tumblrLoginViewController:self failedWithError:error];
            }
            return;
        }
        NSString *key = [TMAPIClient sharedInstance].OAuthToken;
        NSString *tokenSecret = [TMAPIClient sharedInstance].OAuthTokenSecret;
        OAToken *token = [[OAToken alloc] initWithKey:key secret:tokenSecret];
        if ([self.delegate respondsToSelector:@selector(tumblrLoginViewController:didReceivedAccessToken:)]) {
            [self.delegate tumblrLoginViewController:self didReceivedAccessToken:token];
        }
    }];
}
-(BOOL)shouldPopByPinch{
	[SVProgressHUD dismiss];
	return YES;
}


@end

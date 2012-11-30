//
//  BRTumblrOAuthTokenGetter.m
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRTumblrOAuthTokenGetter.h"

@interface BROAuthTokenGetter ()

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;

@end

@implementation BRTumblrOAuthTokenGetter

-(void)getRequestToken{
	[super getRequestTokenWithURL:[NSURL URLWithString:@"http://www.tumblr.com/oauth/request_token"]];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[super requestTokenTicket:ticket didFinishWithData:data];
	NSURL *authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.tumblr.com/oauth/authorize?oauth_token=%@",[requestToken key]]];
	if(self.delegate){
		if([(NSObject*)self.delegate respondsToSelector:@selector(didReceivedRequestTokenURL:)]){
			[(id)self.delegate didReceivedRequestTokenURL:authorizeURL];
		}
	}
}

-(void)getAccessTokenWithOauthToken:(NSString*)token verifier:(NSString*)verifier{
	[super getAccessTokenWithOauthToken:token verifier:verifier withURL:[NSURL URLWithString:@"http://www.tumblr.com/oauth/access_token"]];
}

@end

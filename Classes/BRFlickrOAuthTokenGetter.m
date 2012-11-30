//
//  BRFlickrOAuthTokenGetter.m
//  perSecond
//
//  Created by b123400 on 07/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRFlickrOAuthTokenGetter.h"
#import "OAServiceTicket.h"

@interface BROAuthTokenGetter ()

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;

@end

@implementation BRFlickrOAuthTokenGetter

-(void)getRequestToken{
	[super getRequestTokenWithURL:[NSURL URLWithString:@"http://www.flickr.com/services/oauth/request_token"]];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[super requestTokenTicket:ticket didFinishWithData:data];
	NSURL *authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/services/oauth/authorize?oauth_token=%@&perms=write",[requestToken key]]];
	if(self.delegate){
		if([(NSObject*)self.delegate respondsToSelector:@selector(didReceivedRequestTokenURL:)]){
			[(id)self.delegate didReceivedRequestTokenURL:authorizeURL];
		}
	}
}

-(void)getAccessTokenWithOauthToken:(NSString*)token verifier:(NSString*)verifier{
	[super getAccessTokenWithOauthToken:token verifier:verifier withURL:[NSURL URLWithString:@"http://www.flickr.com/services/oauth/access_token"]];
}

@end

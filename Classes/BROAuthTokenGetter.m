//
//  BROAuthTokenGetter.m
//  Canvas
//
//  Created by b123400 on 24/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BROAuthTokenGetter.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

@implementation BROAuthTokenGetter
@synthesize consumer,delegate,requestToken,accessToken;

-(id)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
	return [self initWithConsumer:[[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]autorelease]];
}
-(id)initWithConsumer:(OAConsumer*)_consumer{
	self.consumer=_consumer;
	return [self init];
}
-(void)dealloc{
	if(requestTokenFetcher){
		requestTokenFetcher.delegate=nil;
		[requestTokenFetcher release];
	}
	if(accessTokenFetcher){
		accessTokenFetcher.delegate=nil;
		[accessTokenFetcher release];
	}
	[super dealloc];
}

-(void)getRequestTokenWithURL:(NSURL*)url{
	if(!consumer)return;
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:[[[SSToken alloc] init] autorelease]   // we don't have a Token yet
																	  realm:nil   // our service provider doesn't specify a realm
														  signatureProvider:nil]autorelease]; // use the default method, HMAC-SHA1	
	
	request.shouldAddCustomCallback=YES;
	[request setHTTPMethod:@"GET"];
	
	if(!requestTokenFetcher){
		requestTokenFetcher = [[OADataFetcher alloc] init];
		
		[requestTokenFetcher fetchDataWithRequest:request
							 delegate:self
					didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
					  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	}
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
	if(!ticket.didSucceed){
		if(delegate){
			if([(id)delegate respondsToSelector:@selector(didFailedToReceiveRequestToken:)]){
				[delegate didFailedToReceiveRequestToken:error];
			}
		}
	}
	if(requestTokenFetcher){
		[requestTokenFetcher release];
		requestTokenFetcher=nil;
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (ticket.didSucceed) {
		
		self.requestToken=[[[SSToken alloc] initWithHTTPResponseBody:responseBody]autorelease];
		if(self.delegate){
			if([(NSObject*)self.delegate respondsToSelector:@selector(didReceivedRequestToken:)]){
				[self.delegate didReceivedRequestToken:requestToken];
			}
		}
	}
	if(requestTokenFetcher){
		[requestTokenFetcher release];
		requestTokenFetcher=nil;
	}
}

#pragma mark Access token
-(void)getAccessTokenWithPin:(NSString*)pin url:(NSURL*)url{
	if(!consumer||!requestToken)return;
	[requestToken setPin:pin];

    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:requestToken   
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil] autorelease]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"GET"];
	
	if(!accessTokenFetcher){
		accessTokenFetcher = [[OADataFetcher alloc] init];
		
		[accessTokenFetcher fetchDataWithRequest:request
										delegate:self
							   didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
								 didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
	}
}
-(void)getAccessTokenWithOauthToken:(NSString*)token verifier:(NSString*)verifier withURL:(NSURL*)url{
	if(!consumer||!requestToken)return;
	[requestToken setPin:verifier];
	[requestToken setOauth_token:token];
	
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
																	consumer:consumer
																	   token:requestToken   
																	   realm:nil   // our service provider doesn't specify a realm
														   signatureProvider:nil] autorelease]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"GET"];
	
	if(!accessTokenFetcher){
		accessTokenFetcher = [[OADataFetcher alloc] init];
		
		[accessTokenFetcher fetchDataWithRequest:request
										delegate:self
							   didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
								 didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
		
	}
}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
	if(!ticket.didSucceed){
		if(delegate){
			if([(id)delegate respondsToSelector:@selector(didFailedToReceiveAccessToken:)]){
				[delegate didFailedToReceiveAccessToken:error];
			}
		}
	}
	if(accessTokenFetcher){
		[accessTokenFetcher release];
		accessTokenFetcher=nil;
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		
		self.accessToken = [[[SSToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		if(self.delegate){
			if([(NSObject*)self.delegate respondsToSelector:@selector(didReceivedAccessToken:)]){
				[self.delegate didReceivedAccessToken:accessToken];
			}
		}		
	}else{
		[self accessTokenTicket:ticket didFailWithError:nil];
	}
	if(accessTokenFetcher){
		[accessTokenFetcher release];
		accessTokenFetcher=nil;
	}
}

@end

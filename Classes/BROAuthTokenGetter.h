//
//  BROAuthTokenGetter.h
//  Canvas
//
//  Created by b123400 on 24/06/2011.
//  Copyright 2011 home. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "SSToken.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"

@protocol BROAuthTokenGetterDelegate

@optional
-(void)didReceivedRequestToken:(SSToken*)token;
-(void)didReceivedAccessToken:(SSToken*)token;

-(void)didFailedToReceiveRequestToken:(NSError*)error;
-(void)didFailedToReceiveAccessToken:(NSError*)error;

@end



@interface BROAuthTokenGetter : NSObject {
	OAConsumer *consumer;
	SSToken *requestToken;
	SSToken *accessToken;
	
	OADataFetcher *requestTokenFetcher;
	OADataFetcher *accessTokenFetcher;
	
	id <BROAuthTokenGetterDelegate> delegate;
}
@property (nonatomic,retain) OAConsumer *consumer;
@property (nonatomic,retain) SSToken *requestToken;
@property (nonatomic,retain) SSToken *accessToken;

@property (nonatomic,assign) id <BROAuthTokenGetterDelegate> delegate;

-(id)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
-(id)initWithConsumer:(OAConsumer*)_consumer;

-(void)getRequestTokenWithURL:(NSURL*)url;
-(void)getAccessTokenWithPin:(NSString*)pin url:(NSURL*)url;
-(void)getAccessTokenWithOauthToken:(NSString*)token verifier:(NSString*)verifier withURL:(NSURL*)url;

@end

//
//  BRInstagramEngine.h
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>

#define instagramDefaultRedirectURL @"BRInstagramEngine://authed"

@protocol BRInstagramEngineDelegate

-(void)instagramEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier;
-(void)instagramEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end


@interface BRInstagramEngine : NSObject {
	NSString *clientID;
	NSString *clientSecret;
	NSURL *redirectUri;       //optional  (for auth only)
	NSString *scope;          //optional  (for auth only)
	
	NSString *accessToken;
	
	id <BRInstagramEngineDelegate> delegate;
    
    NSMutableArray *requests;
}
@property (nonatomic,retain) NSURL *redirectUri;
@property (nonatomic,retain) NSString *scope;
@property (nonatomic,retain) NSString *accessToken;

@property (nonatomic,assign) id <BRInstagramEngineDelegate> delegate;

-(id)initWithClientID:(NSString*)_clientID secret:(NSString*)_clientSecret;

-(NSURL*)authURL:(BOOL)mobileLayout;

-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params;
-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params withMethod:(NSString *)method;

-(NSString*)getSelfFeedWithMinID:(NSString*)minID maxID:(NSString*)maxID;
-(NSString*)getUserFeedWithUserID:(NSString*)userID minID:(NSString*)minID maxID:(NSString*)maxID;
-(NSString*)getCommentsWithMediaID:(NSString*)mediaID;
-(NSString*)likeMediaWithMediaID:(NSString*)mediaID;
-(NSString*)unlikeMediaWithMediaID:(NSString*)mediaID;

@end

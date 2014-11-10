//
//  BRInstagramEngine.h
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"

@protocol BRTwitterEngineDelegate

-(void)twitterEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier;
-(void)twitterEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end

typedef enum BRImageSize{
	BRImageSizeThumb =0,
	BRImageSizeMedium =1,
	BRImageSizeLarge  =2,
	BRImageSizeFull =3,
}BRImageSize;

@interface BRTwitterEngine : NSObject {
	OAConsumer *consumer;
	OAToken *accessToken;
    
    NSMutableArray *fetchers;
	
	id <BRTwitterEngineDelegate> delegate;
}
@property (nonatomic,retain) OAToken *accessToken;
@property (nonatomic,assign) id <BRTwitterEngineDelegate> delegate;

-(instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
-(instancetype)initWithConsumer:(OAConsumer*)_consumer;

-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params;
-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params withMethod:(NSString*)method;

-(NSString*)getHomeTimelineWithSinceID:(NSString*)sinceID maxID:(NSString*)maxID;
-(NSString*)getUserTimelineWithUserID:(NSString*)userID sinceID:(NSString*)sinceID maxID:(NSString*)maxID;
-(NSString*)getRepliesForStatusWithID:(NSString*)statusID;
-(NSString*)markFavorite:(BOOL)favorite forStatusWithID:(NSString*)statusID;
@property (NS_NONATOMIC_IOSONLY, getter=getAuthedUserInfo, readonly, copy) NSString *authedUserInfo;
-(NSString*)getUserInfoWithUserID:(NSString*)userID;
-(NSString*)sendTweet:(NSString*)tweet inReplyToStatusWithID:(NSString*)statusID;
-(NSString*)getRelationshipWithUser:(NSString*)userID;
-(NSString*)followUserWithUserID:(NSString*)userID;
-(NSString*)unfollowUserWithUserID:(NSString*)userID;

+(NSURL*)rawImageURLFromURL:(NSURL*)aURL size:(BRImageSize)size;

@end

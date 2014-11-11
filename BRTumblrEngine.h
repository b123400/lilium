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

@protocol BRTumblrEngineDelegate

-(void)tumblrEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier;
-(void)tumblrEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end


@interface BRTumblrEngine : NSObject {
	OAConsumer *consumer;
	OAToken *accessToken;
	
	id <BRTumblrEngineDelegate> __weak delegate;
    
    NSMutableArray *fetchers;
}
@property (nonatomic,strong) OAToken *accessToken;
@property (nonatomic,weak) id <BRTumblrEngineDelegate> delegate;

-(instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
-(instancetype)initWithConsumer:(OAConsumer*)_consumer;

-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSMutableDictionary*)params;
-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSMutableDictionary*)params method:(NSString*)method;

-(NSString*)getUserDashBoardWithSinceID:(NSString*)sinceID offset:(int)offset;
-(NSString*)getPostsWithBaseHostname:(NSString*)baseHostname offset:(int)offset;
-(NSString*)likePostWithID:(NSString*)postID reblogKey:(NSString*)reblogKey;
-(NSString*)unlikePostWithID:(NSString*)postID reblogKey:(NSString*)reblogKey;
@property (NS_NONATOMIC_IOSONLY, getter=getUserBlogs, readonly, copy) NSString *userBlogs;
-(NSString*)reblogPostWithBaseHostname:(NSString*)baseHostname postID:(NSString*)postID reblogKey:(NSString*)reblogKey comment:(NSString*)comment;
-(NSString*)getBlogPostInfoWithBaseHostName:(NSString*)baseHostname postId:(NSString*)postID withNotes:(BOOL)withNotes;

@end

//
//  StatusFetcher.h
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "StatusesRequest.h"
#import "CommentRequest.h"
#import "LikeRequest.h"
#import "UserRequest.h"
#import "BRFunctions.h"
#import "RelationshipRequest.h"

@protocol StatusFetcherDelegate

-(void)requestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error;

@optional
-(BOOL)needThisStatus:(Status*)status;

@end

@interface StatusFetcher : NSObject<BRTwitterEngineDelegate,BRInstagramEngineDelegate,BRTumblrEngineDelegate,FBRequestDelegate> {
	NSMutableArray *allStatuses;
	
	NSMutableDictionary *tempStatuses;
	NSMutableDictionary *requestsByID;
	
}
@property (nonatomic,retain) NSMutableArray *allStatuses;

+(StatusFetcher*)sharedFetcher;

-(BOOL)didCachedStatus:(Status*)status inArray:(NSArray*)arr;
-(BOOL)didCachedStatusWithStatusID:(NSString*)statusID source:(StatusSourceType)source inArray:(NSArray*)arr;

-(void)getStatusesForRequest:(StatusesRequest*)request;
-(void)getCommentsForRequest:(CommentRequest*)request;
-(void)sendCommentForRequest:(CommentRequest*)request;
-(void)likeStatusForRequest:(LikeRequest*)request;
-(void)getUserForRequest:(UserRequest*)request;
-(void)getUserRelationship:(RelationshipRequest*)request;

@end

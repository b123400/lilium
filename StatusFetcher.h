//
//  StatusFetcher.h
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "StatusRequest.h"
#import "BRFunctions.h"

@protocol StatusFetcherDelegate

-(void)didGetStatuses:(NSMutableArray*)statuses forRequest:(StatusRequest*)request;
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

-(void)getStatusesForRequest:(StatusRequest*)request;

@end

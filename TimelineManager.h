//
//  TimelineManager.h
//  perSecond
//
//  Created by b123400 on 01/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "StatusesRequest.h"

#define TimelineManagerDidRefreshNotification @"TimelineManagerDidRefresh"
#define TimelineManagerDidLoadedOlderStatusNotification @"TimelineManagerDidLoadedOlderStatusNotification"
#define TimelineManagerDidPrefectchThumbNotification @"TimelineManagerDidPrefectchThumbNotification"
#define TimelineManagerDidDeletedStatusesNotification @"TimelineManagerDidDeletedStatusesNotification"

@interface TimelineManager : NSObject {
	NSTimer *timer;
	
	NSMutableArray *statuses;
	
    StatusesRequest *loadLatestRequest;
	StatusesRequest *loadNewerRequest;
	StatusesRequest *loadOlderRequest;
}

+(TimelineManager*)sharedManager;

-(void)sync;
-(void)cancelCurrentSync;
-(void)getNewerStatuses;
-(void)getOlderStatuses;

-(NSArray*)latestStatuses:(int)count;
-(NSArray*)statusesAfter:(Status*)aStatus count:(int)count;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Status *randomStatus;

-(void)removeAllStatusWithSource:(StatusSourceType)source;

-(void)saveRecentStatuses;
-(void)loadRecentStatuses;
-(void)clearRecentStatuses;
-(void)resetTimer;

@end

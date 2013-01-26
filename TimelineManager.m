//
//  TimelineManager.m
//  perSecond
//
//  Created by b123400 on 01/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "TimelineManager.h"
#import "StatusFetcher.h"
#import "AccountsViewController.h"

@interface TimelineManager ()

-(void)loadNewerRequestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error;
-(void)loadOlderRequestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error;

-(NSArray*)referenceStatuses:(StatusRequestDirection)direction;
-(Status*)firstStatusCachedWithSource:(StatusSourceType)source direction:(BOOL)isForward;
-(int)tumblrOffset;

@end

@implementation TimelineManager
static TimelineManager *sharedManager=nil;

+(TimelineManager*)sharedManager{
	if(!sharedManager){
		sharedManager=[[TimelineManager alloc]init];
	}
	return sharedManager;
}
-(id)init{
	statuses=[[NSMutableArray alloc] init];
	[self resetTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusDidPreloadedThumbImage:) name:StatusDidPreloadedImageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sync) name:AccountsDidUpdatedNotification object:nil];
	return [super init];
}
#pragma mark -
-(void)autoSyncByTimer:(NSTimer*)_timer{
	[self sync];
}

-(void)sync{
	if(loadNewerRequest)return;
	loadNewerRequest=[[StatusesRequest requestWithRequestType:StatusRequestTypeTimeline] retain];
	loadNewerRequest.delegate=self;
    loadNewerRequest.selector=@selector(loadNewerRequestFinished:withStatuses:withError:);
	loadNewerRequest.direction=StatusRequestDirectionNewer;
	loadNewerRequest.referenceStatuses=[self referenceStatuses:loadNewerRequest.direction];
	[[StatusFetcher sharedFetcher] getStatusesForRequest:loadNewerRequest];
}
-(void)getOlderStatuses{
	if(loadOlderRequest)return;
	loadOlderRequest=[[StatusesRequest requestWithRequestType:StatusRequestTypeTimeline] retain];
	loadOlderRequest.delegate=self;
    loadOlderRequest.selector=@selector(loadOlderRequestFinished:withStatuses:withError:);
	loadOlderRequest.direction=StatusRequestDirectionOlder;
	loadOlderRequest.referenceStatuses=[self referenceStatuses:loadOlderRequest.direction];
	loadOlderRequest.tumblrOffset=[self tumblrOffset];
	[[StatusFetcher sharedFetcher] getStatusesForRequest:loadOlderRequest];
}

-(NSArray*)latestStatuses:(int)count{
	if([statuses count]<=count){
		return [[statuses copy] autorelease];
	}
	return [statuses objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
}
-(NSArray*)statusesAfter:(Status*)aStatus count:(int)count{
	int indexOfStatus=[statuses indexOfObject:aStatus];
	if(indexOfStatus==NSNotFound)return nil;
	int maxCount=[statuses count]-indexOfStatus-1;
	if(maxCount<count){
		count=maxCount;
		[self getOlderStatuses];
	}
	return [statuses objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexOfStatus+1, count)]];
}
-(Status*)randomStatus{
    if(!statuses.count)return nil;
    return [statuses objectAtIndex:arc4random()%statuses.count];
}
-(void)removeAllStatusWithSource:(StatusSourceType)source{
    NSArray *statusesToRemove=[statuses filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Status *thisStatus=evaluatedObject;
        if(thisStatus.user.type==source){
            return YES;
        }
        return NO;
    }]];
    [statuses removeObjectsInArray:statusesToRemove];
    [[NSNotificationCenter defaultCenter] postNotificationName:TimelineManagerDidDeletedStatusesNotification object:statusesToRemove];
}

-(void)saveRecentStatuses{
    NSArray *recentStatuses=[self latestStatuses:30];
    NSMutableArray *statusDicts=[NSMutableArray array];
    for(Status *thisStatus in recentStatuses){
        [statusDicts addObject:[thisStatus dictionaryRepresentation]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:statusDicts forKey:@"recentStatuses"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)loadRecentStatuses{
    NSArray *statusDicts=[[NSUserDefaults standardUserDefaults] objectForKey:@"recentStatuses"];
    for(NSDictionary *thisDict in statusDicts){
        [statuses addObject:[Status statusWithDictionary:thisDict]];
    }
}
-(void)clearRecentStatuses{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recentStatuses"];
}
-(void)resetTimer{
    if(timer){
        [timer invalidate];
        [timer release];
        timer=nil;
    }
    int interval=2;
    NSNumber *savedInterval=[[NSUserDefaults standardUserDefaults] objectForKey:refreshIntervalKey];
    if(savedInterval)interval=[savedInterval intValue];
    timer=[[NSTimer scheduledTimerWithTimeInterval:60*interval target:self selector:@selector(autoSyncByTimer:) userInfo:nil repeats:YES] retain];
}
#pragma mark -
-(void)loadNewerRequestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error{
	NSSortDescriptor *descriptor=[[[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO]autorelease];
	[_statuses sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    [statuses insertObjects:_statuses atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_statuses count])]];
    [loadNewerRequest release];
    loadNewerRequest=nil;
	for(Status *thisStatus in _statuses){
		[thisStatus prefetechThumb];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:TimelineManagerDidRefreshNotification object:_statuses];
}
-(void)loadOlderRequestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error{
    NSSortDescriptor *descriptor=[[[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO]autorelease];
	[_statuses sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    [statuses addObjectsFromArray:_statuses];
    [loadOlderRequest release];
    loadOlderRequest=nil;
    for(Status *thisStatus in _statuses){
		[thisStatus prefetechThumb];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:TimelineManagerDidLoadedOlderStatusNotification object:_statuses];
}
-(void)statusDidPreloadedThumbImage:(NSNotification*)notification{
    for(Status *status in statuses){
        if(!status.isImagePreloaded)return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TimelineManagerDidPrefectchThumbNotification object:nil userInfo:nil];
}
-(BOOL)needThisStatus:(Status*)status{
	for(Status *thisStatus in statuses){
		if([thisStatus isEqual:status])return NO;
		if((thisStatus.user.type==StatusSourceTypeInstagram||thisStatus.user.type==StatusSourceTypeTwitter)&&
		   (status.user.type==StatusSourceTypeInstagram||status.user.type==StatusSourceTypeTwitter)){
			if([[thisStatus.webURL absoluteString] isEqualToString:[status.webURL absoluteString]]){
				return NO;
			}
		}
	}
	return YES;
}
#pragma mark private
-(NSArray*)referenceStatuses:(StatusRequestDirection)direction{
	NSMutableArray *referenceStatuses=[NSMutableArray array];
	if([BRFunctions didLoggedInTwitter]){
		Status *firstStatus=[self firstStatusCachedWithSource:StatusSourceTypeTwitter direction:direction==StatusRequestDirectionNewer];
		if(firstStatus){
			[referenceStatuses addObject:firstStatus];
		}
	}
	if([BRFunctions isFacebookLoggedIn:NO]){
		Status *firstStatus=[self firstStatusCachedWithSource:StatusSourceTypeFacebook direction:direction==StatusRequestDirectionNewer];
		if(firstStatus){
			[referenceStatuses addObject:firstStatus];
		}
	}
	if([BRFunctions didLoggedInInstagram]){
		Status *firstStatus=[self firstStatusCachedWithSource:StatusSourceTypeInstagram direction:direction==StatusRequestDirectionNewer];
		if(firstStatus){
			[referenceStatuses addObject:firstStatus];
		}
	}
	if([BRFunctions didLoggedInFlickr]){
		Status *firstStatus=[self firstStatusCachedWithSource:StatusSourceTypeFlickr direction:direction==StatusRequestDirectionNewer];
		if(firstStatus){
			[referenceStatuses addObject:firstStatus];
		}
	}
	if([BRFunctions didLoggedInTumblr]){
		Status *firstStatus=[self firstStatusCachedWithSource:StatusSourceTypeTumblr direction:direction==StatusRequestDirectionNewer];
		if(firstStatus){
			[referenceStatuses addObject:firstStatus];
		}
	}
	return referenceStatuses;
}
-(Status*)firstStatusCachedWithSource:(StatusSourceType)source direction:(BOOL)isForward{
	if(![statuses count])return nil;
	for(int i=(isForward?0:[statuses count]-1);((isForward&&i<[statuses count])||(!isForward&&i>=0));i+=(isForward?1:-1)){
		Status *thisStatus=[statuses objectAtIndex:i];
		if(thisStatus.user.type==source)return thisStatus;
	}
	return nil;
}
-(int)tumblrOffset{
	int tumblrOffset=0;
	for(Status *thisStatus in statuses){
		if(thisStatus.user.type==StatusSourceTypeTumblr)tumblrOffset++;
	}
	return tumblrOffset;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[statuses release];
    if(timer){
        [timer invalidate];
        [timer release];
        timer=nil;
    }
	[super dealloc];
}

@end

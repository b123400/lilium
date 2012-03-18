//
//  TimelineManager.m
//  perSecond
//
//  Created by b123400 on 01/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "TimelineManager.h"
#import "StatusFetcher.h"

@interface TimelineManager ()

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
	timer=[[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(autoSyncByTimer:) userInfo:nil repeats:YES] retain];
	return [super init];
}
#pragma mark -
-(void)autoSyncByTimer:(NSTimer*)_timer{
	[self sync];
}

-(void)sync{
	if(loadNewerRequest)return;
	loadNewerRequest=[[StatusRequest requestWithRequestType:StatusRequestTypeTimeline] retain];
	loadNewerRequest.delegate=self;
	loadNewerRequest.direction=StatusRequestDirectionNewer;
	loadNewerRequest.referenceStatuses=[self referenceStatuses:loadNewerRequest.direction];
	[[StatusFetcher sharedFetcher] getStatusesForRequest:loadNewerRequest];
}
-(void)getOlderStatuses{
	if(loadOlderRequest)return;
	loadOlderRequest=[[StatusRequest requestWithRequestType:StatusRequestTypeTimeline] retain];
	loadOlderRequest.delegate=self;
	loadOlderRequest.direction=StatusRequestDirectionOlder;
	loadOlderRequest.referenceStatuses=[self referenceStatuses:loadOlderRequest.direction];
	loadOlderRequest.tumblrOffset=[self tumblrOffset];
	[[StatusFetcher sharedFetcher] getStatusesForRequest:loadOlderRequest];
}

-(NSArray*)lastestStatuses:(int)count{
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
#pragma mark -
-(void)didGetStatuses:(NSMutableArray*)_statuses forRequest:(StatusRequest*)request{
	NSSortDescriptor *descriptor=[[[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO]autorelease];
	[_statuses sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	NSLog([_statuses description]);
	if(request==loadNewerRequest){
		[statuses insertObjects:_statuses atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_statuses count])]];
		[loadNewerRequest release];
		loadNewerRequest=nil;
	}else if(request==loadOlderRequest){
		[statuses addObjectsFromArray:_statuses];
		[loadOlderRequest release];
		loadOlderRequest=nil;
	}
	for(Status *thisStatus in _statuses){
		[thisStatus prefetechThumb];
	}
}
-(BOOL)needThisStatus:(Status*)status{
	for(Status *thisStatus in statuses){
		if([thisStatus isEqual:status])return NO;
		if((thisStatus.source==StatusSourceTypeInstagram||thisStatus.source==StatusSourceTypeTwitter)&&
		   (status.source==StatusSourceTypeInstagram||status.source==StatusSourceTypeTwitter)){
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
		if(thisStatus.source==source)return thisStatus;
	}
	return nil;
}
-(int)tumblrOffset{
	int tumblrOffset=0;
	for(Status *thisStatus in statuses){
		if(thisStatus.source==StatusSourceTypeTumblr)tumblrOffset++;
	}
	return tumblrOffset;
}
-(void)dealloc{
	[statuses release];
	[timer release];
	[super dealloc];
}

@end

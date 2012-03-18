//
//  StatusRequest.m
//  perSecond
//
//  Created by b123400 on 20/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "StatusRequest.h"


@implementation StatusRequest
@synthesize  twitterStatus, facebookStatus, instagramStatus, flickrStatus, tumblrStatus, plurkStatus,delegate,referenceStatuses,direction,tumblrOffset;

+(id)requestWithRequestType:(StatusRequestType)_type{
	return [[[StatusRequest alloc]initWithRequestType:_type]autorelease];
}

-(id)initWithRequestType:(StatusRequestType)_type{
	type=_type;
	return [super init];
}

-(StatusRequestType)type{
	return type;
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone{
	return [self retain];
	
	StatusRequest *newRequest=[[StatusRequest alloc] initWithRequestType:type];
	newRequest.twitterStatus=twitterStatus;
	newRequest.facebookStatus=facebookStatus;
	newRequest.instagramStatus=instagramStatus;
	newRequest.flickrStatus=flickrStatus;
	newRequest.tumblrStatus=tumblrStatus;
	newRequest.plurkStatus=plurkStatus;
	
	return newRequest;
}

@end

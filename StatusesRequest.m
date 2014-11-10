//
//  StatusRequest.m
//  perSecond
//
//  Created by b123400 on 20/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "StatusesRequest.h"


@implementation StatusesRequest
@synthesize  twitterStatus, facebookStatus, instagramStatus, flickrStatus, tumblrStatus, plurkStatus,referenceStatuses,referenceUsers,direction,tumblrOffset;

+(instancetype)requestWithRequestType:(StatusRequestType)_type{
	return [[[StatusesRequest alloc]initWithRequestType:_type]autorelease];
}

-(instancetype)initWithRequestType:(StatusRequestType)_type{
	type=_type;
    errors=[[NSMutableDictionary alloc] init];
	return [super init];
}
-(void)dealloc{
    [errors release];
    [super dealloc];
}

-(StatusRequestType)type{
	return type;
}
-(NSError*)errorForSource:(StatusSourceType)source{
    return errors[[NSNumber numberWithInt:source]];
}
-(void)setError:(NSError*)error forSource:(StatusSourceType)source{
    errors[[NSNumber numberWithInt:source]] = error;
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone{
	return [self retain];
	
	StatusesRequest *newRequest=[[StatusesRequest alloc] initWithRequestType:type];
	newRequest.twitterStatus=twitterStatus;
	newRequest.facebookStatus=facebookStatus;
	newRequest.instagramStatus=instagramStatus;
	newRequest.flickrStatus=flickrStatus;
	newRequest.tumblrStatus=tumblrStatus;
	newRequest.plurkStatus=plurkStatus;
    newRequest.direction=direction;
	
	return newRequest;
}

@end

//
//  StatusRequest.m
//  perSecond
//
//  Created by b123400 on 20/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "StatusRequest.h"


@implementation StatusRequest
@synthesize  twitterStatus, facebookStatus, instagramStatus, flickrStatus, tumblrStatus, plurkStatus,referenceStatuses,direction,tumblrOffset;

+(id)requestWithRequestType:(StatusRequestType)_type{
	return [[[StatusRequest alloc]initWithRequestType:_type]autorelease];
}

-(id)initWithRequestType:(StatusRequestType)_type{
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
    return [errors objectForKey:[NSNumber numberWithInt:source]];
}
-(void)setError:(NSError*)error forSource:(StatusSourceType)source{
    [errors setObject:error forKey:[NSNumber numberWithInt:source]];
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
    newRequest.direction=direction;
	
	return newRequest;
}

@end

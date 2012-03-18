//
//  StatusRequest.h
//  perSecond
//
//  Created by b123400 on 20/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"

typedef enum StatusRequestType {
    StatusRequestTypeSolo       = 0,
    StatusRequestTypeMixed   = 1,
	StatusRequestTypeTimeline  = 2,
} StatusRequestType;

typedef enum StatusFetchingStatus {
    StatusFetchingStatusNotAvailable       = 0,
    StatusFetchingStatusLoading   =1,
	StatusFetchingStatusFinished  = 2,
} StatusFetchingStatus;

typedef enum StatusRequestDirection{
	StatusRequestDirectionNewer  = 0,
	StatusRequestDirectionOlder  = 1,
}StatusRequestDirection;

@interface StatusRequest : NSObject {
	StatusRequestType type;
	NSArray *referenceStatuses;
	int tumblrOffset;
	StatusRequestDirection direction;
	
	StatusFetchingStatus twitterStatus;
	StatusFetchingStatus facebookStatus;
	StatusFetchingStatus instagramStatus;
	StatusFetchingStatus flickrStatus;
	StatusFetchingStatus tumblrStatus;
	StatusFetchingStatus plurkStatus;
	
	id delegate;
}
@property (retain) NSArray *referenceStatuses;
@property (assign) int tumblrOffset;
@property (assign) StatusRequestDirection direction;

@property (assign) StatusFetchingStatus twitterStatus;
@property (assign) StatusFetchingStatus facebookStatus;
@property (assign) StatusFetchingStatus instagramStatus;
@property (assign) StatusFetchingStatus flickrStatus;
@property (assign) StatusFetchingStatus tumblrStatus;
@property (assign) StatusFetchingStatus plurkStatus;

@property (assign) id delegate;

+(id)requestWithRequestType:(StatusRequestType)_type;
-(id)initWithRequestType:(StatusRequestType)_type;

-(StatusRequestType)type;

@end
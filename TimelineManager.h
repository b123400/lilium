//
//  TimelineManager.h
//  perSecond
//
//  Created by b123400 on 01/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "StatusRequest.h"

@interface TimelineManager : NSObject {
	NSTimer *timer;
	
	NSMutableArray *statuses;
	
	StatusRequest *loadNewerRequest;
	StatusRequest *loadOlderRequest;
}

+(TimelineManager*)sharedManager;

-(void)sync;
-(void)getOlderStatuses;

-(NSArray*)lastestStatuses:(int)count;
-(NSArray*)statusesAfter:(Status*)aStatus count:(int)count;

@end

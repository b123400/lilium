//
//  Status.m
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "Status.h"
#import "StatusFetcher.h"

@implementation Status
@synthesize thumbURL,meduimURL,fullURL,webURL,caption,source,account,statusID,liked,date,captionColor,attributes,comments;

-(id)init{
	return [super init];
}

-(NSDictionary*)dictionaryRepresentation{
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithInt:source] forKey:@"source"];
	if(thumbURL)[dict setObject:thumbURL forKey:@"thumb"];
	if(meduimURL)[dict setObject:meduimURL forKey:@"medium"];
	if(fullURL)[dict setObject:fullURL forKey:@"full"];
	if(webURL)[dict setObject:webURL forKey:@"web"];
	if(caption)[dict setObject:caption forKey:@"caption"];
	//Attribute+Account+comments?
	if(statusID)[dict setObject:statusID forKey:@"statusID"];
	if(date)[dict setObject:date forKey:@"date"];
	[dict setObject:[NSNumber numberWithBool:liked] forKey:@"liked"];
	return dict;
}
-(void)prefetechThumb{
	if(thumbURL){
		[[SDWebImageManager sharedManager] downloadWithURL:thumbURL delegate:self retryFailed:NO lowPriority:YES];
	}
}
-(void)getCommentsAndReturnTo:(id)target withSelector:(SEL)selector{
	if(comments){
		if([target respondsToSelector:selector]){
			[target performSelector:selector withObject:comments];
		}
		return;
	}
	CommentRequest *request=[[[CommentRequest alloc] init]autorelease];
	request.targetStatus=self;
	request.delegate=target;
	request.selector=selector;
	[[StatusFetcher sharedFetcher] getCommentsForRequest:request];
}

-(BOOL)isEqual:(id)object{
	if([object class]!=[Status class]){
		return NO;
	}
	Status *thatStatus=object;
	if(source!=thatStatus.source)return NO;
	if([[thumbURL absoluteString]isEqualToString:[thatStatus.thumbURL absoluteString]])return YES;
	return[statusID isEqualToString:thatStatus.statusID];
}
-(NSString*)description{
	return [[self dictionaryRepresentation] description];
}

@end

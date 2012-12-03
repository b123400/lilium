//
//  Status.m
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "Status.h"
#import "StatusFetcher.h"
#import "SDImageCache.h"

@implementation Status
@synthesize thumbURL,mediumURL,fullURL,webURL,caption,source,user,statusID,liked,date,captionColor,attributes,comments;

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
-(UIImage*)cachedImageOfSize:(StatusImageSize)size{
    if(size==StatusImageSizeThumb){
        return [[SDImageCache sharedImageCache] imageFromKey:self.thumbURL.absoluteString];
    }else if(size==StatusImageSizeMedium){
        return [[SDImageCache sharedImageCache] imageFromKey:self.mediumURL.absoluteString];
    }else if(size==StatusImageSizeFull){
        return [[SDImageCache sharedImageCache] imageFromKey:self.fullURL.absoluteString];
    }
    return nil;
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

+(NSArray*)allSources{
    return @[
        [NSNumber numberWithInt:StatusSourceTypeTwitter],
        [NSNumber numberWithInt:StatusSourceTypeInstagram],
        [NSNumber numberWithInt:StatusSourceTypeTumblr],
        [NSNumber numberWithInt:StatusSourceTypeFlickr],
        [NSNumber numberWithInt:StatusSourceTypeFacebook]
    ];
}
+(NSString*)sourceName:(StatusSourceType)source{
    switch (source) {
        case StatusSourceTypeTwitter:
            return @"Twitter";
        case StatusSourceTypeFacebook:
            return @"Facebook";
        case StatusSourceTypeFlickr:
            return @"Flickr";
        case StatusSourceTypeInstagram:
            return @"Instagram";
        case StatusSourceTypeTumblr:
            return @"Tumblr";
        default:
            break;
    }
    return nil;
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

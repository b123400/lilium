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
#import "Comment.h"
#import "Attribute.h"
#import "UIColor-Expanded.h"
#import "UIImage+averageColor.h"
#include <dispatch/dispatch.h>

@implementation Status
@synthesize thumbURL,mediumURL,fullURL,webURL,caption,user,statusID,liked,date,captionColor,attributes,comments;

+(Status*)statusWithDictionary:(NSDictionary*)dict{
    Status *newStatus=[[[Status alloc] init]autorelease];
    newStatus.user=[User userWithDictionary:[dict objectForKey:@"user"]];
    
    if([dict objectForKey:@"thumb"])newStatus.thumbURL=[NSURL URLWithString:[dict objectForKey:@"thumb"]];
    if([dict objectForKey:@"medium"])newStatus.mediumURL=[NSURL URLWithString:[dict objectForKey:@"medium"]];
    if([dict objectForKey:@"full"])newStatus.fullURL=[NSURL URLWithString:[dict objectForKey:@"full"]];
    if([dict objectForKey:@"web"])newStatus.webURL=[NSURL URLWithString:[dict objectForKey:@"web"]];
    if([dict objectForKey:@"caption"])newStatus.caption=[dict objectForKey:@"caption"];
    if([dict objectForKey:@"statusID"])newStatus.statusID=[dict objectForKey:@"statusID"];
    if([dict objectForKey:@"date"])newStatus.date=[dict objectForKey:@"date"];
    if([dict objectForKey:@"captionColor"])newStatus.captionColor=[UIColor colorWithString:[dict objectForKey:@"captionColor"]];
    if([dict objectForKey:@"comments"]){
        NSMutableArray *_comments=[NSMutableArray array];
        for(NSDictionary *thisDict in [dict objectForKey:@"comments"]){
            [_comments addObject:[Comment commentFromDictionary:thisDict]];
        }
        newStatus.comments=_comments;
    }
    if([dict objectForKey:@"attributes"]){
        NSMutableArray *_attributes=[NSMutableArray array];
        for(NSDictionary *thisDict in [dict objectForKey:@"attributes"]){
            [_attributes addObject:[Attribute attributeFromDictionary:thisDict]];
        }
        newStatus.attributes=_attributes;
    }
    if([dict objectForKey:@"liked"])[newStatus setLiked:[[dict objectForKey:@"liked"]boolValue] sync:NO];

    return newStatus;
}
-(NSMutableDictionary*)dictionaryRepresentation{
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setObject:[user dictionaryRepresentation] forKey:@"user"];
	if(thumbURL)[dict setObject:[thumbURL absoluteString] forKey:@"thumb"];
	if(mediumURL)[dict setObject:[mediumURL absoluteString] forKey:@"medium"];
	if(fullURL)[dict setObject:[fullURL absoluteString] forKey:@"full"];
	if(webURL)[dict setObject:[webURL absoluteString] forKey:@"web"];
	if(caption)[dict setObject:caption forKey:@"caption"];
	if(statusID)[dict setObject:statusID forKey:@"statusID"];
	if(date)[dict setObject:date forKey:@"date"];
    if(captionColor)[dict setObject:[captionColor stringFromColor] forKey:@"captionColor"];

    NSMutableArray *commentsArray=[NSMutableArray array];
    for(Comment *thisComment in comments){
        [commentsArray addObject:[thisComment dictionaryRepresentation]];
    }
    [dict setObject:commentsArray forKey:@"comments"];
    
    NSMutableArray *attributesArray=[NSMutableArray array];
    for(Attribute *thisAttribute in attributesArray){
        [attributesArray addObject:[thisAttribute dictionaryRepresentation]];
    }
    [dict setObject:attributesArray forKey:@"attributes"];
    
	[dict setObject:[NSNumber numberWithBool:liked] forKey:@"liked"];
	return dict;
}
#pragma mark - image
-(void)prefetechThumb{
	if(thumbURL&&!self.isImagePreloaded){
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
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image{
    if(!self.captionColor){
        dispatch_queue_t gQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(gQueue, ^{
            CGSize cellSize=[BRFunctions gridViewCellSize];
            float heightScale=cellSize.height/image.size.height;
            float widthScale=cellSize.width/image.size.width;
            
            float x=0;
            float y=0;
            float width=100;
            float height=100;
            if(heightScale>widthScale){
                float scaledWidth=heightScale*image.size.width;
                x=(scaledWidth-cellSize.width)/2.0/heightScale;
                y=image.size.height*(1-30/cellSize.height);
                height=30/heightScale;
                width=cellSize.width/heightScale;
            }else{
                float scaledHeight=widthScale*image.size.height;
                x=0;
                y=(scaledHeight-cellSize.height)/2.0/widthScale+image.size.height*(1-30/cellSize.height);
                width=cellSize.width/widthScale;
                height=30/widthScale;
            }
            CGImageRef imageRef=CGImageCreateWithImageInRect([image CGImage], CGRectMake(x, y, width, height));
            
            UIImage *viewImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            UIColor *averageColor=[viewImage getDominantColor];
            self.captionColor=averageColor;
            
            //imageView.image=viewImage;
            
            UIGraphicsEndImageContext();
        });
       [[NSNotificationCenter defaultCenter]postNotificationName:StatusDidPreloadedImageNotification object:self userInfo:nil];
    }
}
-(BOOL)isImagePreloaded{
    if([[SDImageCache sharedImageCache] imageFromKey:thumbURL.absoluteString fromDisk:NO]){
        return YES;
    }
    return NO;
}
#pragma mark -
-(void)getCommentsAndReturnTo:(id)target withSelector:(SEL)selector{
    [self getCommentsAndReturnTo:target withSelector:selector cached:YES];
}
-(void)getCommentsAndReturnTo:(id)target withSelector:(SEL)selector cached:(BOOL)cached{
	if(comments&&cached){
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
-(void)setLiked:(BOOL)_liked{
    [self setLiked:_liked sync:YES];
}
-(void)setLiked:(BOOL)_liked sync:(BOOL)sync{
    if(_liked!=liked){
        liked=_liked;
        if(sync){
            LikeRequest *request=[[[LikeRequest alloc]init] autorelease];
            request.targetStatus=self;
            request.isLike=liked;
            [[StatusFetcher sharedFetcher] likeStatusForRequest:request];
        }
    }
}
-(void)submitComment:(NSString*)commentString{
    Comment *newComment=[[[Comment alloc]init] autorelease];
    if(self.user.type==StatusSourceTypeTwitter&&[BRFunctions twitterUser]){
        newComment.user=[BRFunctions twitterUser];
    }else if(self.user.type==StatusSourceTypeFacebook&&[BRFunctions facebookUser]){
        newComment.user=[BRFunctions facebookUser];
    }else if(self.user.type==StatusSourceTypeInstagram&&[BRFunctions instagramUser]){
        newComment.user=[BRFunctions instagramUser];
    }else{
        newComment.user=[User me];
    }
    newComment.text=commentString;
    newComment.date=[NSDate date];
    [self.comments addObject:newComment];
    
    CommentRequest *request=[[[CommentRequest alloc] init]autorelease];
    request.targetStatus=self;
    request.submitCommentString=commentString;
    request.delegate=self;
    request.selector=@selector(commentRequestFinished:);
    [[StatusFetcher sharedFetcher] sendCommentForRequest:request];
}
-(void)commentRequestFinished:(CommentRequest*)request{
    [[NSNotificationCenter defaultCenter] postNotificationName:StatusDidSentCommentNotification object:self];
}
#pragma mark - util
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
+(Status*)sampleStatus{
    User *newUser=[User userWithType:StatusSourceTypeTwitter userID:@"userID"];
    newUser.displayName=@"display name";
    newUser.username=@"username";
    
    Status *newStatus=[[Status alloc]init];
    newStatus.statusID=@"status id";
    newStatus.caption=@"caption";
    newStatus.date=[NSDate date];
    newStatus.user=newUser;
    newStatus.thumbURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[[NSDate date]description]]];
    return newStatus;
}

-(BOOL)isEqual:(id)object{
	if(![object isKindOfClass:[Status class]]){
		return NO;
	}
	Status *thatStatus=object;
	if(self.user.type!=thatStatus.user.type)return NO;
	if([[thumbURL absoluteString]isEqualToString:[thatStatus.thumbURL absoluteString]])return YES;
	return[statusID isEqualToString:thatStatus.statusID];
}
-(NSString*)description{
	return [[self dictionaryRepresentation] description];
}

@end

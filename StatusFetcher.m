//
//  StatusFetcher.m
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "StatusFetcher.h"
#import "Status.h"
#import "RegexKitLite.h"
#import "NSObject+Identifier.h"
#import "CJSONDeserializer.h"
#import "Attribute.h"
#import "Comment.h"
#import "TimelineManager.h"
#import "FacebookUser.h"
#import "TumblrUser.h"
#import "TumblrStatus.h"

@interface StatusFetcher ()

-(void)refreshTempStatusForRequest:(StatusesRequest*)request;
-(Status*)firstStatusWithSource:(StatusSourceType)source inArray:(NSArray*)arr;

-(NSArray*)instagramCommentsFromDicts:(NSArray*)dicts;
-(User*)instagramUserFromDict:(NSDictionary*)dictionary;

-(User*)twitterUserFromDict:(NSDictionary*)dict;
-(Comment*)twitterCommentFromDict:(NSDictionary*)dict;

-(Comment*)tumblrCommentFromNotesDict:(NSDictionary*)dict;

-(void)didReceivedComments:(NSArray*)comments forRequest:(CommentRequest*)request;
-(void)didFinishedLikeRequestWithIdentifier:(NSString*)identifier;

@end

@implementation StatusFetcher
@synthesize allStatuses;

static StatusFetcher* sharedFetcher=nil;

-(id)init{
	allStatuses=[[NSMutableArray alloc] init];
	tempStatuses=[[NSMutableDictionary alloc]init];
	requestsByID=[[NSMutableDictionary alloc]init];
	return [super init];
}

+(StatusFetcher*)sharedFetcher{
	if(!sharedFetcher){
		sharedFetcher=[[StatusFetcher alloc]init];
	}
	return sharedFetcher;
}

#pragma mark - Timeline
-(void)getStatusesForRequest:(StatusesRequest*)request{
	NSMutableArray *newArray=[NSMutableArray array];
	[tempStatuses setObject:newArray forKey:request];
	if([request type]==StatusRequestTypeTimeline){
		Status *thisStatus=[self firstStatusWithSource:StatusSourceTypeTwitter inArray:request.referenceStatuses];
		if([BRFunctions didLoggedInTwitter]){
			if(thisStatus){
				if(request.direction==StatusRequestDirectionNewer){
					[requestsByID setObject:request forKey:[[BRFunctions sharedTwitter] getHomeTimelineWithSinceID:thisStatus.statusID maxID:nil]];
				}else{
					[requestsByID setObject:request forKey:[[BRFunctions sharedTwitter] getHomeTimelineWithSinceID:nil maxID:thisStatus.statusID]];
				}
			}else{
				[requestsByID setObject:request forKey:[[BRFunctions sharedTwitter] getHomeTimelineWithSinceID:nil maxID:nil]];
			}
			request.twitterStatus=StatusFetchingStatusLoading;
		}
		if([BRFunctions didLoggedInFlickr]){
			if(request.direction==StatusRequestDirectionNewer){
				[requestsByID setObject:request forKey:[[BRFunctions sharedFlickr] getContactsPhotos]];
				request.flickrStatus=StatusFetchingStatusLoading;
			}
		}
		
		thisStatus=[self firstStatusWithSource:StatusSourceTypeInstagram inArray:request.referenceStatuses];
		if([BRFunctions didLoggedInInstagram]){
			if(thisStatus){
				if(request.direction==StatusRequestDirectionNewer){
					[requestsByID setObject:request forKey:[[BRFunctions sharedInstagram] getSelfFeedWithMinID:thisStatus.statusID maxID:nil]];
				}else{
					[requestsByID setObject:request forKey:[[BRFunctions sharedInstagram] getSelfFeedWithMinID:nil maxID:thisStatus.statusID]];
				}
			}else{
				[requestsByID setObject:request forKey:[[BRFunctions sharedInstagram] getSelfFeedWithMinID:nil maxID:nil]];
			}
			request.instagramStatus=StatusFetchingStatusLoading;
		}
		
		thisStatus=[self firstStatusWithSource:StatusSourceTypeFacebook inArray:request.referenceStatuses];
		if([BRFunctions isFacebookLoggedIn:NO]){
			FBRequest *fbRequest=nil;
			if(thisStatus){
				if(request.direction==StatusRequestDirectionNewer){
					fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:[NSString stringWithFormat:@"me/home?type=photo&since=%f",[thisStatus.date timeIntervalSince1970]] andDelegate:self];
				}else{
					fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:[NSString stringWithFormat:@"me/home?type=photo&until=%f",[thisStatus.date timeIntervalSince1970]] andDelegate:self];
				}
			}else{
				fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:@"me/home?type=photo" andDelegate:self];
			}
			[requestsByID setObject:request forKey:[fbRequest identifier]];
			request.facebookStatus=StatusFetchingStatusLoading;
		}
		
		thisStatus=[self firstStatusWithSource:StatusSourceTypeTumblr inArray:request.referenceStatuses];
		if([BRFunctions didLoggedInTumblr]){
			if(thisStatus){
				if(request.direction==StatusRequestDirectionNewer){
					[requestsByID setObject:request forKey:[[BRFunctions sharedTumblr] getUserDashBoardWithSinceID:[NSString stringWithFormat:@"%f",[thisStatus.statusID doubleValue]+1] offset:0]];
				}else{
					[requestsByID setObject:request forKey:[[BRFunctions sharedTumblr] getUserDashBoardWithSinceID:nil offset:request.tumblrOffset]];
				}
			}else{
				[requestsByID setObject:request forKey:[[BRFunctions sharedTumblr] getUserDashBoardWithSinceID:nil offset:0]];
			}
			request.tumblrStatus=StatusFetchingStatusLoading;
		}
	}else if(request.type==StatusRequestTypeSolo){
        for(User *thisUser in request.referenceUsers){
            switch (thisUser.type) {
                case StatusSourceTypeInstagram:{
                    NSString *requestID=[[BRFunctions sharedInstagram] getUserFeedWithUserID:thisUser.userID minID:nil maxID:nil];
                    [requestsByID setObject:request forKey:requestID];
                    request.instagramStatus=StatusFetchingStatusLoading;
                    break;
                }
                case StatusSourceTypeTwitter:{
                    NSString *requestID=[[BRFunctions sharedTwitter] getUserTimelineWithUserID:thisUser.userID sinceID:nil maxID:nil];
                    [requestsByID setObject:request forKey:requestID];
                    request.twitterStatus=StatusFetchingStatusLoading;
                    break;
                }
                case StatusSourceTypeFlickr:{
                    NSString *requestID=[[BRFunctions sharedFlickr] getPhotosOfUser:thisUser.userID minDate:nil maxDate:nil page:0];
                    [requestsByID setObject:request forKey:requestID];
                    request.flickrStatus=StatusFetchingStatusLoading;
                }
                case StatusSourceTypeTumblr:{
                    NSString *requestID=[[BRFunctions sharedTumblr]getPostsWithBaseHostname:thisUser.userID offset:0];
                    [requestsByID setObject:request forKey:requestID];
                    request.tumblrStatus=StatusFetchingStatusLoading;
                    break;
                }
                case StatusSourceTypeFacebook:{
                    FBRequest *fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/feed?type=photo",thisUser.userID] andDelegate:self];
                    [requestsByID setObject:request forKey:[fbRequest identifier]];
                    request.facebookStatus=StatusFetchingStatusLoading;
                    break;
                }
                default:
                    break;
            }
        }
    }
}
-(void)refreshTempStatusForRequest:(StatusesRequest*)request{
	if(request.twitterStatus!=StatusFetchingStatusLoading&&
	   request.facebookStatus!=StatusFetchingStatusLoading&&
	   request.instagramStatus!=StatusFetchingStatusLoading&&
	   request.flickrStatus!=StatusFetchingStatusLoading&&
	   request.tumblrStatus!=StatusFetchingStatusLoading&&
	   request.plurkStatus!=StatusFetchingStatusLoading){
		NSMutableArray *_statuses=[tempStatuses objectForKey:request];
		//A statusRequest finished loading
		if(request.delegate&&_statuses){
			if(request.selector){
                NSError *error=nil;
                NSMutableArray *servicesWithError=[NSMutableArray array];
                NSArray *services=[Status allSources];
                for(NSNumber *thisSource in services){
                    if([request errorForSource:thisSource.intValue]){
                        [servicesWithError addObject:[Status sourceName:thisSource.intValue]];
                    }
                }
                if(servicesWithError.count){
                    NSString *errorMessage=[servicesWithError componentsJoinedByString:@","];
                    errorMessage=[NSString stringWithFormat:@"Failed to load from the following service:%@",errorMessage];
                    error=[NSError errorWithDomain:@"net.b123400.lilium" code:10 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
                }
				//Three arugments: request, statuses, error
                NSMethodSignature * mySignature = [TimelineManager
                                                   instanceMethodSignatureForSelector:request.selector];
                NSInvocation * myInvocation = [NSInvocation
                                               invocationWithMethodSignature:mySignature];
                [myInvocation setTarget:request.delegate];
                [myInvocation setSelector:request.selector];
                [myInvocation setArgument:&request atIndex:2];
                [myInvocation setArgument:&_statuses atIndex:3];
                [myInvocation setArgument:&error atIndex:4];
                [myInvocation invoke];
			}
		}
		[tempStatuses removeObjectForKey:request];
	}
}
#pragma mark - Comment
-(void)getCommentsForRequest:(CommentRequest*)request{
	StatusSourceType type=request.targetStatus.user.type;
	switch (type) {
		case StatusSourceTypeInstagram:{
			NSString *requestID=[[BRFunctions sharedInstagram]getCommentsWithMediaID:request.targetStatus.statusID];
			[requestsByID setObject:request forKey:requestID];
			break;
        }
        case StatusSourceTypeTwitter:{
            NSString *requestID=[[BRFunctions sharedTwitter]getRepliesForStatusWithID:request.targetStatus.statusID];
            [requestsByID setObject:request forKey:requestID];
            break;
        }
        case StatusSourceTypeFacebook:{
            FBRequest *fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/comments",request.targetStatus.statusID] andDelegate:self];
			[requestsByID setObject:request forKey:[fbRequest identifier]];
            break;
        }
        case StatusSourceTypeFlickr: {
            NSString *requestID=[[BRFunctions sharedFlickr] getCommentsForPhotoWithID:request.targetStatus.statusID];
            [requestsByID setObject:request forKey:requestID];
            break;
        }
		default:
			break;
	}
}
-(void)sendCommentForRequest:(CommentRequest*)request{
    StatusSourceType type=request.targetStatus.user.type;
	switch (type) {
		case StatusSourceTypeInstagram:{
			NSString *requestID=[[BRFunctions sharedInstagram]sendComment:request.submitCommentString withMediaID:request.targetStatus.statusID];
			[requestsByID setObject:request forKey:requestID];
			break;
        }
        case StatusSourceTypeTwitter:{
            NSString *requestID=[[BRFunctions sharedTwitter]sendTweet:[NSString stringWithFormat:@"@%@ %@",request.targetStatus.user.username,request.submitCommentString] inReplyToStatusWithID:request.targetStatus.statusID];
            [requestsByID setObject:request forKey:requestID];
            break;
        }
        case StatusSourceTypeFacebook:{
            FBRequest *fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/comments",request.targetStatus.statusID] andParams:[NSMutableDictionary dictionaryWithObject:request.submitCommentString forKey:@"message"] andHttpMethod:@"POST" andDelegate:self];
			[requestsByID setObject:request forKey:[fbRequest identifier]];
            break;
        }
        case StatusSourceTypeFlickr: {
            NSString *requestID=[[BRFunctions sharedFlickr] addComment:request.submitCommentString toPhotoWithPhotoID:request.targetStatus.statusID];
            [requestsByID setObject:request forKey:requestID];
            break;
        }
        case StatusSourceTypeTumblr:{
            if([request.targetStatus isKindOfClass:[TumblrStatus class]]){
                NSString *requestID=[[BRFunctions sharedTumblr] reblogPostWithPostID:request.targetStatus.statusID reblogKey:[(TumblrStatus*)request.targetStatus reblogKey] comment:request.submitCommentString];
                [requestsByID setObject:request forKey:requestID];
            }
        }
            break;
		default:
			break;
	}
}
-(void)didReceivedComments:(NSArray*)comments forRequest:(CommentRequest*)request{
	request.targetStatus.comments=[NSMutableArray arrayWithArray:comments];
	id target=request.delegate;
	[target performSelector:request.selector withObject:request withObject:comments];
    [requestsByID removeObjectsForKeys:[requestsByID allKeysForObject:request]];
}
#pragma mark - Like
-(void)likeStatusForRequest:(LikeRequest*)request{
    StatusSourceType source=request.targetStatus.user.type;
    switch (source) {
        case StatusSourceTypeFacebook:{
            FBRequest *fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/likes",request.targetStatus.statusID] andParams:[NSMutableDictionary dictionary] andHttpMethod:request.isLike?@"POST":@"DELETE" andDelegate:self];
			[requestsByID setObject:request forKey:[fbRequest identifier]];
        }
        break;
        case StatusSourceTypeFlickr:{
            NSString *requestID;
            if(request.isLike){
                requestID=[[BRFunctions sharedFlickr]addFavoritesForPhotoWithID:request.targetStatus.statusID];
            }else{
                requestID=[[BRFunctions sharedFlickr]removeFavoritesForPhotoWithID:request.targetStatus.statusID];
            }
            [requestsByID setObject:request forKey:requestID];
        }
            break;
        case StatusSourceTypeInstagram:{
            NSString *requestID;
            if(request.isLike){
                requestID=[[BRFunctions sharedInstagram]likeMediaWithMediaID:request.targetStatus.statusID];
            }else{
                requestID=[[BRFunctions sharedInstagram]unlikeMediaWithMediaID:request.targetStatus.statusID];
            }
            [requestsByID setObject:request forKey:requestID];
        }
            break;
        case StatusSourceTypeTumblr:{
            if([request.targetStatus isKindOfClass:[TumblrStatus class]]){
                NSString *requestID;
                if(request.isLike){
                    requestID=[[BRFunctions sharedTumblr]likePostWithID:request.targetStatus.statusID reblogKey:[(TumblrStatus*)request.targetStatus reblogKey]];
                }else{
                    requestID=[[BRFunctions sharedTumblr]unlikePostWithID:request.targetStatus.statusID reblogKey:[(TumblrStatus*)request.targetStatus reblogKey]];
                }
                [requestsByID setObject:request forKey:requestID];
            }
        }
            break;
        case StatusSourceTypeTwitter:{
            NSString *requestID=[[BRFunctions sharedTwitter]markFavorite:request.isLike forStatusWithID:request.targetStatus.statusID];
            [requestsByID setObject:request forKey:requestID];
        }
            break;
        default:
            break;
    }
}
-(void)didFinishedLikeRequestWithIdentifier:(NSString*)identifier{
    LikeRequest *request=[requestsByID objectForKey:identifier];
    if(request.delegate&&request.selector){
        [request.delegate performSelector:request.selector withObject:request];
    }
    [requestsByID removeObjectForKey:identifier];
}
#pragma mark - Get user
-(void)getUserForRequest:(UserRequest*)request{
    StatusSourceType type=request.type;
	switch (type) {
		case StatusSourceTypeInstagram:{
			NSString *requestID=[[BRFunctions sharedInstagram]getUserInfoWithUserID:request.userID];
			[requestsByID setObject:request forKey:requestID];
			break;
        }
        case StatusSourceTypeTwitter:{
            NSString *requestID;
            if([request.userID isEqualToString:@"self"]){
                requestID=[[BRFunctions sharedTwitter] getAuthedUserInfo];
            }else{
                requestID=[[BRFunctions sharedTwitter]getUserInfoWithUserID:request.userID];
            }
            [requestsByID setObject:request forKey:requestID];
            break;
        }
        case StatusSourceTypeFacebook:{
            FBRequest *fbRequest=[[BRFunctions sharedFacebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/",request.userID] andDelegate:self];
			[requestsByID setObject:request forKey:[fbRequest identifier]];
            break;
        }
        case StatusSourceTypeFlickr: {
            NSString *requestID=[[BRFunctions sharedFlickr]getUserInfoWithUserID:request.userID];
            [requestsByID setObject:request forKey:requestID];
            break;
        }
        case StatusSourceTypeTumblr:{
            NSString *requestID;
            if([request.userID isEqualToString:@"self"]){
                requestID=[[BRFunctions sharedTumblr]getUserBlogs];
            }else{
//                requestID=[[BRFunctions sharedTumblr]getUserInfo];
            }
            [requestsByID setObject:request forKey:requestID];
            break;
        }
		default:
			break;
	}
}
-(void)didReceivedUser:(User*)user forRequest:(UserRequest*)request{
    if(request.delegate&&request.selector&&[request.delegate respondsToSelector:request.selector]){
        [request.delegate performSelector:request.selector withObject:request withObject:user];
    }
    [requestsByID removeObjectsForKeys:[requestsByID allKeysForObject:request]];
}
#pragma mark - Flickr
-(Comment*)flickrCommentFromDict:(NSDictionary*)dict{
    User *newUser=[User userWithType:StatusSourceTypeFlickr userID:[dict objectForKey:@"author"]];
    newUser.profilePicture=[BRFlickrEngine iconSourceURLWithFarm:[[dict objectForKey:@"iconfarm"] intValue] iconServer:[[dict objectForKey:@"iconserver"] intValue] userID:[dict objectForKey:@"author"]];
    newUser.username=[dict objectForKey:@"authorname"];
    newUser.displayName=[dict objectForKey:@"authorname"];
    
    Comment *newComment=[[[Comment alloc] init]autorelease];
    newComment.user=newUser;
    newComment.text=[dict objectForKey:@"_content"];
    newComment.date=[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"datecreate"] doubleValue]];
    
    return newComment;
}
-(void)flickrEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
    if ([[requestsByID objectForKey:identifier]isKindOfClass:[CommentRequest class]]) {
        NSMutableArray *comments=[NSMutableArray array];
        if([data objectForKey:@"comments"]&&[[data objectForKey:@"comments"] objectForKey:@"comment"]){
            for(NSDictionary *thisComment in [[data objectForKey:@"comments"] objectForKey:@"comment"]){
                [comments addObject:[self flickrCommentFromDict:thisComment]];
            }
        }
        NSLog(@"%@",data);
        [self didReceivedComments:comments forRequest:[requestsByID objectForKey:identifier]];
        return;
    }
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[LikeRequest class]]){
        [self didFinishedLikeRequestWithIdentifier:identifier];
        return;
    }
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[UserRequest class]]){
        NSLog(@"%@",[data description]);
        return;
    }
	StatusesRequest *request=[requestsByID objectForKey:identifier];
	request.flickrStatus=StatusFetchingStatusFinished;
	
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSArray *photos=[[data objectForKey:@"photos"] objectForKey:@"photo"];
	for(NSDictionary *photo in photos){
		Status *thisStatus=[[[Status alloc]init]autorelease];
		thisStatus.thumbURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:@"m"];
		//thisStatus.thumbURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:nil]; <--retina
		thisStatus.mediumURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:nil];
		//thisStatus.meduimURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:@"b"]; <--retina
		thisStatus.fullURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:@"o"];
		thisStatus.webURL=[BRFlickrEngine webPageURLFromDictionary:photo];
		thisStatus.caption=[photo objectForKey:@"title"];
        
		User *thisUser=[User userWithType:StatusSourceTypeFlickr userID:[photo objectForKey:@"owner"]];
//		thisUser.displayName=;
		thisUser.username=[photo objectForKey:@"username"];
		thisStatus.user=thisUser;
		thisStatus.statusID=[NSString stringWithFormat:@"%@",[photo objectForKey:@"id"]];
		
		if(![self didCachedStatus:thisStatus inArray:_statuses]){
			if(request.delegate){
				if([request.delegate respondsToSelector:@selector(needThisStatus:)]){
					if([request.delegate needThisStatus:thisStatus]){
						[_statuses addObject:thisStatus];
					}
				}else{
					[_statuses addObject:thisStatus];
				}
			}
		}
		if(![self didCachedStatus:thisStatus inArray:allStatuses]){
			[allStatuses addObject:thisStatus];
		}
	}
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
-(void)flickrEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier{
    if([[requestsByID objectForKey:identifier] isKindOfClass:[StatusesRequest class]]){
        StatusesRequest *request=[requestsByID objectForKey:identifier];
        request.flickrStatus=StatusFetchingStatusError;
        [request setError:error forSource:StatusSourceTypeFlickr];
        [self refreshTempStatusForRequest:request];
    }else{
        Request *request=[requestsByID objectForKey:identifier];
        if(request.failSelector){
            [request.delegate performSelector:request.failSelector withObject:request withObject:error];
        }
    }
	[requestsByID removeObjectForKey:identifier];
}
#pragma mark instagram
-(NSArray*)instagramCommentsFromDicts:(NSArray*)dicts{
	NSMutableArray *comments=[NSMutableArray array];
	for(int i=0;i<[dicts count];i++){
		NSDictionary *thisDict=[dicts objectAtIndex:i];
		User *thisUser=[User userWithType:StatusSourceTypeInstagram userID:[[thisDict objectForKey:@"from"] objectForKey:@"id"]];
		thisUser.displayName=[[thisDict objectForKey:@"from"] objectForKey:@"full_name"];
		thisUser.profilePicture=[NSURL URLWithString:[[thisDict objectForKey:@"from"]objectForKey:@"profile_picture"]];
		thisUser.username=[[thisDict objectForKey:@"from"]objectForKey:@"username"];

		Comment *thisComment=[[[Comment alloc]init]autorelease];
		thisComment.user=thisUser;
		thisComment.text=[thisDict objectForKey:@"text"];
		thisComment.date=[NSDate dateWithTimeIntervalSince1970:[[thisDict objectForKey:@"created_time"]doubleValue]];
		
		[comments addObject:thisComment];
	}
	return comments;
}
-(User*)instagramUserFromDict:(NSDictionary*)dictionary{
    User *thisUser=[User userWithType:StatusSourceTypeInstagram userID:[dictionary objectForKey:@"id"]];;
    thisUser.displayName=[dictionary objectForKey:@"full_name"];
    thisUser.username=[dictionary objectForKey:@"username"];
    if([dictionary objectForKey:@"profile_picture"]){
        thisUser.profilePicture=[NSURL URLWithString:[dictionary objectForKey:@"profile_picture"]];
    }
    return thisUser;
}
-(void)instagramEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
	if([[requestsByID objectForKey:identifier] isKindOfClass:[CommentRequest class]]){
		NSArray *dicts=[data objectForKey:@"data"];
		NSArray *comments=[self instagramCommentsFromDicts:dicts];
		[self didReceivedComments:comments forRequest:[requestsByID objectForKey:identifier]];
		return;
	}
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[LikeRequest class]]){
        [self didFinishedLikeRequestWithIdentifier:identifier];
        return;
    }
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[UserRequest class]]){
        [self didReceivedUser:[self instagramUserFromDict:[data objectForKey:@"data"]] forRequest:[requestsByID objectForKey:identifier]];
        return;
    }
	StatusesRequest *request=[requestsByID objectForKey:identifier];
	request.instagramStatus=StatusFetchingStatusFinished;
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSArray *photos=[data objectForKey:@"data"];
	for(NSDictionary *photo in photos){
		Status *thisStatus=[[[Status alloc]init]autorelease];
		thisStatus.thumbURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"]];
		//thisStatus.thumbURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"]]; <--retina
		thisStatus.mediumURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"]];
		//thisStatus.meduimURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"]]; <--retina
		thisStatus.fullURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"]];
		if([photo objectForKey:@"link"]&&[photo objectForKey:@"link"]!=[NSNull null]){
			thisStatus.webURL=[NSURL URLWithString:[photo objectForKey:@"link"]];
		}
		if([photo objectForKey:@"caption"]&&[photo objectForKey:@"caption"]!=[NSNull null]){
			thisStatus.caption=[[photo objectForKey:@"caption"] objectForKey:@"text"];
		}
		thisStatus.date=[NSDate dateWithTimeIntervalSince1970:[[photo objectForKey:@"created_time"]doubleValue]];
        
		thisStatus.user=[self instagramUserFromDict:[photo objectForKey:@"user"]];
		thisStatus.statusID=[NSString stringWithFormat:@"%@",[photo objectForKey:@"id"]];
		
		thisStatus.date=[NSDate dateWithTimeIntervalSince1970:[[photo objectForKey:@"created_time"]doubleValue]];
		[thisStatus setLiked:[[photo objectForKey:@"user_has_liked"]intValue]==1 sync:NO];
		
		NSMutableArray *comments=[NSMutableArray arrayWithArray:[self instagramCommentsFromDicts:[[photo objectForKey:@"comments"]objectForKey:@"data"]]];
		thisStatus.comments=comments;
		
		BOOL needThisStatus=YES;
		if(![self didCachedStatus:thisStatus inArray:_statuses]){
			if(request.delegate){
				if([request.delegate respondsToSelector:@selector(needThisStatus:)]){
					needThisStatus=[request.delegate needThisStatus:thisStatus];
				}
			}
		}
		if(needThisStatus){
			BOOL repeated=NO;
			for(Status* otherStatus in _statuses){
				if([[otherStatus.webURL absoluteString] isEqualToString:[thisStatus.webURL absoluteString]]&&otherStatus.user.type!=StatusSourceTypeInstagram){
					repeated =YES;
					[_statuses replaceObjectAtIndex:[_statuses indexOfObject:otherStatus] withObject:thisStatus];
					break;
				}
			}
			if(!repeated){		
				if(![self didCachedStatus:thisStatus inArray:_statuses]){
					[_statuses addObject:thisStatus];
				}
			}
		}
		BOOL repeated=NO;
		for(Status* otherStatus in allStatuses){
			if([[otherStatus.webURL absoluteString] isEqualToString:[thisStatus.webURL absoluteString]]&&otherStatus.user.type!=StatusSourceTypeInstagram){
				repeated =YES;
				[allStatuses replaceObjectAtIndex:[allStatuses indexOfObject:otherStatus] withObject:thisStatus];
				break;
			}
		}
		if(!repeated){
			if(![self didCachedStatus:thisStatus inArray:allStatuses]){
				[allStatuses addObject:thisStatus];
			}
		}
	}
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
-(void)instagramEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier{
    if([[requestsByID objectForKey:identifier] isKindOfClass:[StatusesRequest class]]){
        StatusesRequest *request=[requestsByID objectForKey:identifier];
        request.instagramStatus=StatusFetchingStatusError;
        [request setError:error forSource:StatusSourceTypeInstagram];
        [self refreshTempStatusForRequest:request];
    }else{
        Request *request=[requestsByID objectForKey:identifier];
        if(request.failSelector){
            [request.delegate performSelector:request.failSelector withObject:request withObject:error];
        }
    }
    [requestsByID removeObjectForKey:identifier];
}
#pragma mark tumblr
-(Comment*)tumblrCommentFromNotesDict:(NSDictionary*)dict{
    TumblrUser *newUser=[TumblrUser userWithBlogName:[dict objectForKey:@"blog_name"] anyUrl:[dict objectForKey:@"blog_url"]];
    
    Comment *newComment=[[[Comment alloc] init]autorelease];
    newComment.user=newUser;
    newComment.date=[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"timestamp"] doubleValue]];
    
    NSString *actionString=@"";
    if([[dict objectForKey:@"type"] isEqualToString:@"reblog"]){
        actionString=@"rebloged";
    }else if([[dict objectForKey:@"type"]isEqualToString:@"like"]){
        actionString=@"liked";
    }else if([[dict objectForKey:@"type"]isEqualToString:@"posted"]){
        actionString=@"posted";
    }else{
        NSLog(@"%@",[dict objectForKey:@"type"]);
    }
    newComment.text=[NSString stringWithFormat:@"%@ this",actionString];
    return newComment;
}
-(void)tumblrEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
    if([[requestsByID objectForKey:identifier] isKindOfClass:[LikeRequest class]]){
        [self didFinishedLikeRequestWithIdentifier:identifier];
        return;
    }
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[UserRequest class]]){
        UserRequest *request=[requestsByID objectForKey:identifier];
        if([data isKindOfClass:[NSDictionary class]]&&[[[data objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"blogs"]){
            NSMutableArray *userBlogs=[NSMutableArray array];
            NSArray *blogs=[[[data objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"blogs"];
            for(NSDictionary *thisBlog in blogs){
                TumblrUser *thisUser=[TumblrUser userWithBlogName:[thisBlog objectForKey:@"name"] anyUrl:[thisBlog objectForKey:@"url"]];
                thisUser.displayName=[thisBlog objectForKey:@"title"];
                [userBlogs addObject:thisUser];
            }
            if(request.delegate&&request.selector&&[request.delegate respondsToSelector:request.selector]){
                [request.delegate performSelector:request.selector withObject:request withObject:userBlogs];
            }
            [requestsByID removeObjectsForKeys:[requestsByID allKeysForObject:request]];
            return;
        }
        if(request.delegate&&request.selector&&[request.delegate respondsToSelector:request.selector]){
            [request.delegate performSelector:request.failSelector withObject:request];
        }
        [requestsByID removeObjectsForKeys:[requestsByID allKeysForObject:request]];
        return;
    }
	StatusesRequest *request=[requestsByID objectForKey:identifier];
	request.tumblrStatus=StatusFetchingStatusFinished;
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSArray *photos=[[data objectForKey:@"response"] objectForKey:@"posts"];
	for(NSDictionary *post in photos){
		if([[post objectForKey:@"photos"] count]){
			TumblrStatus *thisStatus=[[[TumblrStatus alloc]init]autorelease];
			
			NSArray *sizes=[[[post objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"alt_sizes"];
			for(NSDictionary *size in sizes){
				if([[size objectForKey:@"width"] intValue]==250){
					thisStatus.thumbURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}else if([[size objectForKey:@"width"]intValue]==400){
					thisStatus.mediumURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}
				/*retina
				if([[size objectForKey:@"width"] intValue]==400){
					thisStatus.thumbURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}else if([[size objectForKey:@"width"]intValue]==500){
					thisStatus.meduimURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}
				 */
			}
			if(thisStatus.thumbURL&&thisStatus.mediumURL){
				thisStatus.fullURL=[NSURL URLWithString:[[sizes objectAtIndex:0]objectForKey:@"url"]];
				thisStatus.webURL=[NSURL URLWithString:[post objectForKey:@"post_url"]];
				if([post objectForKey:@"caption"]&&[post objectForKey:@"caption"]!=[NSNull null]&&![[post objectForKey:@"caption"] isEqualToString:@""]){
					
					NSString *caption=[post objectForKey:@"caption"];
					
					NSString *regex=@"</?(\\w+((\\s+\\w+(\\s*=\\s*(?:\".*?\"|\'.*?\'|[^\'\">\\s]+))?)+\\s*|\\s*)/?)>";
					NSArray *components=[caption arrayOfCaptureComponentsMatchedByRegex:regex];
					for(NSArray *component in components){
						NSString *thisTag=[component objectAtIndex:1];
						NSString *thisElement=[[thisTag componentsSeparatedByString:@" "] objectAtIndex:0];
						if(![thisElement isEqualToString:@"a"]){
							caption=[caption stringByReplacingOccurrencesOfString:[component objectAtIndex:0] withString:@""];
						}
					}
					
					regex=@"<[^>]*a[^>]*href=[\"|\']([^\'\"]*)[\"|\'][^>]*>([^<]*)</[\\s]*a[^>|\\s]*>";
					components=[caption arrayOfCaptureComponentsMatchedByRegex:regex];
					NSLog(@"%@",[components description]);
					NSMutableArray *attributes=[NSMutableArray array];
					for(int i=0;i<[components count];i++){
						NSArray *thisLink=[components objectAtIndex:i];
						NSString *wholeLink=[thisLink objectAtIndex:0];
						NSURL *thisURL=[NSURL URLWithString:[thisLink objectAtIndex:1]];
						NSString *thisText=[thisLink objectAtIndex:2];
						
						NSRange linkRange=[caption rangeOfString:wholeLink];
						
						Attribute *thisAttribute=[[[Attribute alloc] init]autorelease];
						thisAttribute.url=thisURL;
						thisAttribute.range=NSMakeRange(linkRange.location, thisText.length);
						[attributes addObject:thisAttribute];
						
						caption=[NSString stringWithFormat:@"%@%@%@",[caption substringToIndex:linkRange.location],thisText,[caption substringFromIndex:linkRange.location+linkRange.length]];
					}
					
					thisStatus.attributes=attributes;
					thisStatus.caption=caption;
				}
                TumblrUser *thisUser=[TumblrUser userWithBlogName:[post objectForKey:@"blog_name"] anyUrl:[post objectForKey:@"post_url"]];
				thisStatus.user=thisUser;
				
				thisStatus.statusID=[NSString stringWithFormat:@"%@",[post objectForKey:@"id"]];
				
				thisStatus.date=[NSDate dateWithTimeIntervalSince1970:[[post objectForKey:@"timestamp"]doubleValue]];
                thisStatus.reblogKey=[post objectForKey:@"reblog_key"];
                [thisStatus setLiked:[[post objectForKey:@"liked"] boolValue] sync:NO];
				
                //Comment
                NSMutableArray *comments=[NSMutableArray array];
                for(NSDictionary *commentDict in [post objectForKey:@"notes"]){
                    [comments addObject:[self tumblrCommentFromNotesDict:commentDict]];
                }
                thisStatus.comments=comments;
                
				if(![self didCachedStatus:thisStatus inArray:_statuses]){
					if(request.delegate){
						if([request.delegate respondsToSelector:@selector(needThisStatus:)]){
							if([request.delegate needThisStatus:thisStatus]){
								[_statuses addObject:thisStatus];
							}
						}else{
							[_statuses addObject:thisStatus];
						}
					}
				}
				if(![self didCachedStatus:thisStatus inArray:allStatuses]){
					[allStatuses addObject:thisStatus];
				}
			}
		}
	}
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
-(void)tumblrEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier{
    if([[requestsByID objectForKey:identifier] isKindOfClass:[StatusesRequest class]]){
        StatusesRequest *request=[requestsByID objectForKey:identifier];
        request.tumblrStatus=StatusFetchingStatusError;
        [request setError:error forSource:StatusSourceTypeTumblr];
        [self refreshTempStatusForRequest:request];
    }else{
        Request *request=[requestsByID objectForKey:identifier];
        if(request.failSelector){
            [request.delegate performSelector:request.failSelector withObject:request withObject:error];
        }
    }
	[requestsByID removeObjectForKey:identifier];
}
#pragma mark twitter
-(User*)twitterUserFromDict:(NSDictionary*)dict{
    User *thisUser=[User userWithType:StatusSourceTypeTwitter userID:[dict objectForKey:@"id_str"]];
    thisUser.username=[dict objectForKey:@"screen_name"];
    thisUser.profilePicture=[NSURL URLWithString:[dict objectForKey:@"profile_image_url"]];
    thisUser.displayName=[dict objectForKey:@"name"];
    return thisUser;
}
-(Comment*)twitterCommentFromDict:(NSDictionary*)dict{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setTimeStyle:NSDateFormatterFullStyle];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4];
	[df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	[df setDateFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];
    
    Comment *comment=[[[Comment alloc] init]autorelease];
    comment.user=[self twitterUserFromDict:[dict objectForKey:@"user"]];
    comment.date=[df dateFromString:[dict objectForKey:@"created_at"]];
    comment.text=[dict objectForKey:@"text"];
    return comment;
}
-(void)twitterEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[CommentRequest class]]){
        //comments received
        /*
         [
             { //thisDict
             "groupName": "TweetsWithConversation",
             "results":  
                [
                 { //thisResult
                 "annotations": {
                    "ConversationRole": "Ancestor"
                 },
                 "kind": "Tweet",
                 "score": 1,
                 "value":  {
                    //tweet dict
                 }
                }
              ]
            }
         ]
         */
        NSMutableArray *comments=[NSMutableArray array];
        if([data isKindOfClass:[NSArray class]]){
            for(NSDictionary *thisDict in (NSArray*)data){
                if([thisDict isKindOfClass:[NSDictionary class]]){
                    if([[thisDict objectForKey:@"groupName"] isEqualToString:@"TweetsWithConversation"]&&[[thisDict objectForKey:@"results"] isKindOfClass:[NSArray class]]){
                        for(NSDictionary *thisResult in (NSArray*)[thisDict objectForKey:@"results"]){
                            if([[thisResult objectForKey:@"value"] isKindOfClass:[NSDictionary class]]){
                                [comments addObject:[self twitterCommentFromDict:[thisResult objectForKey:@"value"]]];
                            }
                        }
                    }
                }
            }
        }
        [self didReceivedComments:comments forRequest:[requestsByID objectForKey:identifier]];
        return;
    }
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[LikeRequest class]]){
        [self didFinishedLikeRequestWithIdentifier:identifier];
        return;
    }
    if([requestsByID objectForKey:identifier]&&[[requestsByID objectForKey:identifier] isKindOfClass:[UserRequest class]]){
        [self didReceivedUser:[self twitterUserFromDict:data] forRequest:[requestsByID objectForKey:identifier]];
        return;
    }
	StatusesRequest *request=[requestsByID objectForKey:identifier];
	request.twitterStatus=StatusFetchingStatusFinished;
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setTimeStyle:NSDateFormatterFullStyle];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4];
	[df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	[df setDateFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];
	if(![data isKindOfClass:[NSArray class]])return;
	for(NSDictionary *tweet in data){
		NSString *urlRegex=@"[^(href=\\')]?((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))";
		
		NSArray *urls=nil;
		if([tweet objectForKey:@"entities"]&&[tweet objectForKey:@"entities"]!=[NSNull null]){
            if([[[tweet objectForKey:@"entities"] objectForKey:@"media"] isKindOfClass:[NSArray class]]){
                for(NSDictionary *media in [[tweet objectForKey:@"entities"]objectForKey:@"media"]){
                    Status *thisStatus=[[[Status alloc]init] autorelease];
                    thisStatus.statusID=[tweet objectForKey:@"id_str"];
                    thisStatus.webURL=[NSURL URLWithString:[media objectForKey:@"expanded_url"]];
                    thisStatus.caption=[[tweet objectForKey:@"text"] stringByReplacingOccurrencesOfString:[media objectForKey:@"url"] withString:@""];
                    thisStatus.user=[self twitterUserFromDict:[tweet objectForKey:@"user"]];
                    
                    thisStatus.thumbURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@:thumb",[media objectForKey:@"media_url"]]];
                    //thisStatus.thumbURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@:small",[media objectForKey:@"media_url"]]] <--retina
                    thisStatus.mediumURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@:medium",[media objectForKey:@"media_url"]]];
                    //thisStatus.mediumURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@:large",[media objectForKey:@"media_url"]]]
                    thisStatus.fullURL=[NSURL URLWithString:[media objectForKey:@"media_url"]];
                    
                    [thisStatus setLiked:[[tweet objectForKey:@"favorited"]intValue]==1 sync:NO];
                    thisStatus.date=[df dateFromString:[tweet objectForKey:@"created_at"]];
                    
                    if(request.delegate){
                        if([request.delegate respondsToSelector:@selector(needThisStatus:)]){
                            if(![request.delegate needThisStatus:thisStatus]){
                                continue;
                            }
                        }
                    }
                    
                    if(![self didCachedStatus:thisStatus inArray:_statuses]){
                        [_statuses addObject:thisStatus];
                    }
                    if(![self didCachedStatus:thisStatus inArray:allStatuses]){
                        [allStatuses addObject:thisStatus];
                    }
                }
            }else if([[tweet objectForKey:@"entities"] objectForKey:@"urls"]){
				NSArray *twitterParsedURLs=[[tweet objectForKey:@"entities"] objectForKey:@"urls"];
				NSMutableArray *parsedURL=[NSMutableArray array];
				for(NSDictionary *thisURL in twitterParsedURLs){
					if([thisURL objectForKey:@"expanded_url"]&&[thisURL objectForKey:@"expanded_url"]!=[NSNull null]){
						[parsedURL addObject:[thisURL objectForKey:@"expanded_url"]];
					}else if([thisURL objectForKey:@"url"]&&[thisURL objectForKey:@"url"]!=[NSNull null]){
						[parsedURL addObject:[thisURL objectForKey:@"url"]];
					}
				}
				urls=parsedURL;
			}
		}
		if(!urls){
			urls=[[tweet objectForKey:@"text"] componentsMatchedByRegex:urlRegex];
		}
		for(NSString *thisUrl in urls){
			thisUrl=[thisUrl stringByReplacingOccurrencesOfString:@"　" withString:@""];
			thisUrl=[thisUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			NSURL* thumbURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] size:BRImageSizeThumb];
			
			if(thumbURL){
				BOOL addedAlready=NO;
				if([thisUrl rangeOfString:@"instagr.am/p/"].location!=NSNotFound){
					for(Status *status in _statuses){
						if(status.user.type==StatusSourceTypeInstagram){
							if([[status.webURL absoluteString] isEqualToString:thisUrl]){
								addedAlready=YES;
								break;
							}else if([[status.thumbURL absoluteString]isEqualToString:thisUrl]){
								addedAlready=YES;
								break;
							}
						}
					}
				}
				
				if(!addedAlready){
					Status *thisStatus=[[[Status alloc]init] autorelease];
					thisStatus.statusID=[tweet objectForKey:@"id_str"];
					thisStatus.webURL=[NSURL URLWithString:thisUrl];
					
					if(request.delegate){
						if([request.delegate respondsToSelector:@selector(needThisStatus:)]){
							if(![request.delegate needThisStatus:thisStatus]){
								break;
							}
						}
					}
					
					thisStatus.caption=[[tweet objectForKey:@"text"] stringByReplacingOccurrencesOfString:thisUrl withString:@""];
					
					thisStatus.user=[self twitterUserFromDict:[tweet objectForKey:@"user"]];
					
					thisStatus.thumbURL=thumbURL;
					//thisStatus.thumbURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl]  size:BRImageSizeMedium]; <--retina
					thisStatus.mediumURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] size:BRImageSizeMedium];
					//thisStatus.meduimURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl]  size:BRImageSizeLarge]; <--retina
					thisStatus.fullURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] size:BRImageSizeFull];
					
					[thisStatus setLiked:[[tweet objectForKey:@"favorited"]intValue]==1 sync:NO];
					thisStatus.date=[df dateFromString:[tweet objectForKey:@"created_at"]];
					
					if(![self didCachedStatus:thisStatus inArray:_statuses]){
						[_statuses addObject:thisStatus];
					}
					if(![self didCachedStatus:thisStatus inArray:allStatuses]){
						[allStatuses addObject:thisStatus];
					}
					
					continue;
				}
			}
		}
	}
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
-(void)twitterEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier{
    if([[requestsByID objectForKey:identifier] isKindOfClass:[StatusesRequest class]]){
        StatusesRequest *request=[requestsByID objectForKey:identifier];
        request.twitterStatus=StatusFetchingStatusError;
        [request setError:error forSource:StatusSourceTypeTwitter];
        [self refreshTempStatusForRequest:request];
    }else{
        Request *request=[requestsByID objectForKey:identifier];
        if(request.failSelector){
            [request.delegate performSelector:request.failSelector withObject:request withObject:error];
        }
    }
    [requestsByID removeObjectForKey:identifier];
}
#pragma mark facebook
-(Comment*)facebookCommentFromDict:(NSDictionary*)dict{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    
    User *newUser=[FacebookUser userWithUserID:[[dict objectForKey:@"from"] objectForKey:@"id"]];
    newUser.displayName=[[dict objectForKey:@"from"]objectForKey:@"name"];
    
    Comment *newComment=[[[Comment alloc] init]autorelease];
    newComment.user=newUser;
    newComment.text=[dict objectForKey:@"message"];
    newComment.date=[df dateFromString:[dict objectForKey:@"created_time"]];
    return newComment;
}
-(User*)facebookUserFromDict:(NSDictionary*)dictionary{
    FacebookUser *thisUser=[FacebookUser userWithUserID:[dictionary objectForKey:@"id"]];
    thisUser.displayName=[dictionary objectForKey:@"name"];
    thisUser.username=[dictionary objectForKey:@"username"];
    return thisUser;
}
- (void)request:(FBRequest *)fbRequest didLoad:(id)result{
	NSString *identifier=[fbRequest identifier];
    if([[requestsByID objectForKey:identifier] isKindOfClass:[CommentRequest class]]){
        CommentRequest *request=[requestsByID objectForKey:identifier];
        NSMutableArray *comments=[NSMutableArray array];
        if([[result objectForKey:@"data"] isKindOfClass:[NSArray class]]){
            for(NSDictionary *dict in [result objectForKey:@"data"]){
                [comments addObject:[self facebookCommentFromDict:dict]];
            }
        }
        [self didReceivedComments:comments forRequest:request];
        return;
    }
    if([[requestsByID objectForKey:identifier] isKindOfClass:[LikeRequest class]]){
        [self didFinishedLikeRequestWithIdentifier:identifier];
        return;
    }
    if([[requestsByID objectForKey:identifier] isKindOfClass:[UserRequest class]]){
        [self didReceivedUser:[self facebookUserFromDict:result] forRequest:[requestsByID objectForKey:identifier]];
        return;
    }
	StatusesRequest *request=[requestsByID objectForKey:identifier];
	
	if([result	 isKindOfClass:[NSData class]]){
		NSError *error=nil;
		id selfParseResult=[[CJSONDeserializer deserializer] deserialize:result error:&error];
		if(!error){
			result=selfParseResult;
		}
	}
	
	if(![result isKindOfClass:[NSDictionary class]]){
		[self request:fbRequest didFailWithError:nil];
		return ;
	}
	request.facebookStatus=StatusFetchingStatusFinished;
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	
	NSArray *updates=[result objectForKey:@"data"];
	for(NSDictionary *dict in updates){
		if([[dict objectForKey:@"type"]isEqualToString:@"photo"]&&[dict objectForKey:@"picture"]){
			NSString *smallPictureURL=[dict objectForKey:@"picture"];
			NSRange sizeIndentifierRange=[smallPictureURL rangeOfString:@"_s" options:NSBackwardsSearch];
			
			NSString *thumbString=nil;
			NSString *mediumString=nil;
			NSString *fullString=nil;
			
			if(sizeIndentifierRange.location!=NSNotFound){
				thumbString=[NSString stringWithFormat:@"%@%@%@",[smallPictureURL substringToIndex:sizeIndentifierRange.location],@"_q",[smallPictureURL substringFromIndex:sizeIndentifierRange.location+sizeIndentifierRange.length]];
				mediumString=[NSString stringWithFormat:@"%@%@%@",[smallPictureURL substringToIndex:sizeIndentifierRange.location],@"_b",[smallPictureURL substringFromIndex:sizeIndentifierRange.location+sizeIndentifierRange.length]];
				fullString=[NSString stringWithFormat:@"%@%@%@",[smallPictureURL substringToIndex:sizeIndentifierRange.location],@"_o",[smallPictureURL substringFromIndex:sizeIndentifierRange.location+sizeIndentifierRange.length]];
			}
			
			Status *newStatus=[[Status alloc]init];
			newStatus.statusID=[dict objectForKey:@"id"];
			
			if(thumbString){
				newStatus.thumbURL=[NSURL URLWithString:thumbString];
				//newStatus.thumbURL=[NSURL URLWithString:mediumString];
				newStatus.mediumURL=[NSURL URLWithString:mediumString];
				newStatus.fullURL=[NSURL URLWithString:fullString];
			}
			newStatus.webURL=[NSURL URLWithString:[dict	objectForKey:@"link"]];
			
			if([dict objectForKey:@"message"])newStatus.caption=[dict objectForKey:@"message"];
			
			newStatus.user=[self facebookUserFromDict:[dict objectForKey:@"from"]];
			
			//2010-12-01T21:35:43+0000  
			
			newStatus.date=[df dateFromString:[dict objectForKey:@"created_time"]];
			
			
			
			if([dict objectForKey:@"likes"]){
				if([[dict objectForKey:@"likes"] objectForKey:@"data"]&&[[[dict objectForKey:@"likes"] objectForKey:@"data"] isKindOfClass:[NSArray class]]){
					NSArray *likes=[[dict objectForKey:@"likes"] objectForKey:@"data"];
					for(NSDictionary *thisLike in likes){
						NSString *idString=[NSString stringWithFormat:@"%@",[thisLike objectForKey:@"id"]];
						if([idString isEqualToString:[BRFunctions facebookCurrentUserID]]){
							[newStatus setLiked:YES sync:NO];
						}
					}
				}
			}
			//t = 75*113  // 75*56
			//s = 87*130  // 130*98
			//q = 180*270 // 180*135 //thumb
			//b = 480*720 // 720*540 //medium
			//n = 480*720 // 720*540 
			//o = download
			
			if(![self didCachedStatus:newStatus inArray:_statuses]){
				if(request.delegate){
					if([request.delegate respondsToSelector:@selector(needThisStatus:)]){
						if([request.delegate needThisStatus:newStatus]){
							[_statuses addObject:newStatus];
						}
					}else{
						[_statuses addObject:newStatus];
					}
				}
			}
			if(![self didCachedStatus:newStatus inArray:allStatuses]){
				[allStatuses addObject:newStatus];
			}
		}
	}
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
- (void)request:(FBRequest *)fbRequest didFailWithError:(NSError *)error{
	NSString *identifier=[fbRequest identifier];
    if([[requestsByID objectForKey:identifier] isKindOfClass:[StatusesRequest class]]){
        StatusesRequest *request=[requestsByID objectForKey:identifier];
        request.facebookStatus=StatusFetchingStatusError;
        [request setError:error forSource:StatusSourceTypeFacebook];
        [self refreshTempStatusForRequest:request];
    }else{
        Request *request=[requestsByID objectForKey:identifier];
        if(request.failSelector){
            [request.delegate performSelector:request.failSelector withObject:request withObject:error];
        }
    }
	[requestsByID removeObjectForKey:identifier];
}

#pragma mark -
-(BOOL)didCachedStatus:(Status*)status inArray:(NSArray*)arr{
	for(Status *cachedStatus in arr){
		if([cachedStatus isEqual:status]){
			return YES;
		}
	}
	return NO;
}
-(BOOL)didCachedStatusWithStatusID:(NSString*)statusID source:(StatusSourceType)source inArray:(NSArray*)arr{
	for(Status *cachedStatus in arr){
		if([[cachedStatus statusID] isEqualToString:statusID]&&cachedStatus.user.type==source){
			return YES;
		}
	}
	return NO;
}
-(Status*)firstStatusWithSource:(StatusSourceType)source inArray:(NSArray*)arr{
	if(!arr)return nil;
	if(![arr count])nil;
	for(Status *thisStatus in arr){
		if(thisStatus.user.type==source){
			return thisStatus;
		}
	}
	return nil;
}
-(void)dealloc{
	[allStatuses release];
	[requestsByID release];
	[tempStatuses release];
	[super dealloc];
}

@end

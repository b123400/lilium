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

@interface StatusFetcher ()

-(void)refreshTempStatusForRequest:(StatusRequest*)request;
-(Status*)firstStatusWithSource:(StatusSourceType)source inArray:(NSArray*)arr;

-(void)didReceivedComments:(NSArray*)comments forRequest:(CommentRequest*)request;

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

-(void)getStatusesForRequest:(StatusRequest*)request{
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
					[requestsByID setObject:request forKey:[[BRFunctions sharedTumblr] getUserDashBoardWithSinceID:[NSString stringWithFormat:@"%f",[thisStatus.statusID doubleValue]+1] offset:nil]];
				}else{
					[requestsByID setObject:request forKey:[[BRFunctions sharedTumblr] getUserDashBoardWithSinceID:nil offset:request.tumblrOffset]];
				}
			}else{
				[requestsByID setObject:request forKey:[[BRFunctions sharedTumblr] getUserDashBoardWithSinceID:nil offset:nil]];
			}
			request.tumblrStatus=StatusFetchingStatusLoading;
		}
	}
}
-(void)refreshTempStatusForRequest:(StatusRequest*)request{
	if(request.twitterStatus!=StatusFetchingStatusLoading&&
	   request.facebookStatus!=StatusFetchingStatusLoading&&
	   request.instagramStatus!=StatusFetchingStatusLoading&&
	   request.flickrStatus!=StatusFetchingStatusLoading&&
	   request.tumblrStatus!=StatusFetchingStatusLoading&&
	   request.plurkStatus!=StatusFetchingStatusLoading){
		NSMutableArray *_statuses=[tempStatuses objectForKey:request];
		//A statusRequest finished loading
		if(request.delegate&&_statuses){
			if([(id)request.delegate respondsToSelector:@selector(didGetStatuses:forRequest:)]){
				[(id)request.delegate didGetStatuses:_statuses forRequest:request];
			}
		}
		[tempStatuses removeObjectForKey:request];
	}
}
#pragma mark Flickr
-(void)flickrEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.flickrStatus=StatusFetchingStatusFinished;
	
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSArray *photos=[[data objectForKey:@"photos"] objectForKey:@"photo"];
	for(NSDictionary *photo in photos){
		Status *thisStatus=[[[Status alloc]init]autorelease];
		thisStatus.thumbURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:@"m"];
		//thisStatus.thumbURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:nil]; <--retina
		thisStatus.meduimURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:nil];
		//thisStatus.meduimURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:@"b"]; <--retina
		thisStatus.fullURL=[BRFlickrEngine photoSourceURLFromDictionary:photo size:@"o"];
		thisStatus.webURL=[BRFlickrEngine webPageURLFromDictionary:photo];
		thisStatus.caption=[photo objectForKey:@"title"];
		thisStatus.source=StatusSourceTypeFlickr;
		Account *thisAccount=[[[Account alloc]init]autorelease];
//		thisAccount.displayName=;
		thisAccount.username=[photo objectForKey:@"username"];
		thisAccount.userID=[photo objectForKey:@"owner"];
		thisStatus.account=thisAccount;
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
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.flickrStatus=StatusFetchingStatusFinished;
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
#pragma mark instagram
-(NSArray*)instagramCommentsFromDicts:(NSArray*)dicts{
	NSMutableArray *comments=[NSMutableArray array];
	for(int i=0;i<[dicts count];i++){
		NSDictionary *thisDict=[dicts objectAtIndex:i];
		Account *thisAccount=[[[Account alloc]init]autorelease];
		thisAccount.displayName=[[thisDict objectForKey:@"from"] objectForKey:@"full_name"];
		thisAccount.userID=[[thisDict objectForKey:@"from"] objectForKey:@"id"];
		thisAccount.profilePicture=[NSURL URLWithString:[[thisDict objectForKey:@"from"]objectForKey:@"profile_picture"]];
		thisAccount.username=[[thisDict objectForKey:@"from"]objectForKey:@"username"];
		Comment *thisComment=[[[Comment alloc]init]autorelease];
		thisComment.account=thisAccount;
		thisComment.text=[thisDict objectForKey:@"text"];
		thisComment.date=[NSDate dateWithTimeIntervalSince1970:[[thisDict objectForKey:@"created_time"]doubleValue]];
		
		[comments addObject:thisComment];
	}
	return comments;
}
-(void)instagramEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
	if([[requestsByID objectForKey:identifier] isKindOfClass:[CommentRequest class]]){
		NSArray *dicts=[data objectForKey:@"data"];
		NSArray *comments=[self instagramCommentsFromDicts:dicts];
		[self didReceivedComments:comments forRequest:[requestsByID objectForKey:identifier]];
		return;
	}
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.instagramStatus=StatusFetchingStatusFinished;
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSArray *photos=[data objectForKey:@"data"];
	for(NSDictionary *photo in photos){
		Status *thisStatus=[[[Status alloc]init]autorelease];
		thisStatus.thumbURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"]];
		//thisStatus.thumbURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"]]; <--retina
		thisStatus.meduimURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"]];
		//thisStatus.meduimURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"]]; <--retina
		thisStatus.fullURL=[NSURL URLWithString:[[[photo objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"]];
		if([photo objectForKey:@"link"]&&[photo objectForKey:@"link"]!=[NSNull null]){
			thisStatus.webURL=[NSURL URLWithString:[photo objectForKey:@"link"]];
		}
		if([photo objectForKey:@"caption"]&&[photo objectForKey:@"caption"]!=[NSNull null]){
			thisStatus.caption=[[photo objectForKey:@"caption"] objectForKey:@"text"];
		}
		thisStatus.source=StatusSourceTypeInstagram;
		thisStatus.date=[NSDate dateWithTimeIntervalSince1970:[[photo objectForKey:@"created_time"]doubleValue]];
		Account *thisAccount=[[[Account alloc]init]autorelease];
		thisAccount.displayName=[[photo objectForKey:@"user"] objectForKey:@"full_name"];
//		thisAccount.username=;
		thisAccount.userID=[[photo objectForKey:@"user"] objectForKey:@"id"];
		thisStatus.account=thisAccount;
		thisStatus.statusID=[NSString stringWithFormat:@"%@",[photo objectForKey:@"id"]];
		
		thisStatus.date=[NSDate dateWithTimeIntervalSince1970:[[photo objectForKey:@"created_time"]doubleValue]];
		thisStatus.liked=[[photo objectForKey:@"user_has_liked"]intValue]==1;
		
		NSMutableArray *comments=[NSMutableArray arrayWithArray:[self instagramCommentsFromDicts:[[photo objectForKey:@"comments"]objectForKey:@"data"]]];
		thisStatus.comments=comments;
		
		BOOL needThisStatus=YES;
		if(![self didCachedStatus:thisStatus inArray:_statuses]){
			if(request.delegate){
				if(![request.delegate respondsToSelector:@selector(needThisStatus:)]){
					needThisStatus=NO;
				}
			}
		}
		if(needThisStatus){
			BOOL repeated=NO;
			for(Status* otherStatus in _statuses){
				if([[otherStatus.webURL absoluteString] isEqualToString:[thisStatus.webURL absoluteString]]&&otherStatus.source!=StatusSourceTypeInstagram){
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
			if([[otherStatus.webURL absoluteString] isEqualToString:[thisStatus.webURL absoluteString]]&&otherStatus.source!=StatusSourceTypeInstagram){
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
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.instagramStatus=StatusFetchingStatusFinished;
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
#pragma mark tumblr
-(void)tumblrEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.tumblrStatus=StatusFetchingStatusFinished;
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSArray *photos=[[data objectForKey:@"response"] objectForKey:@"posts"];
	for(NSDictionary *post in photos){
		if([[post objectForKey:@"photos"] count]){
			Status *thisStatus=[[[Status alloc]init]autorelease];
			
			NSArray *sizes=[[[post objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"alt_sizes"];
			for(NSDictionary *size in sizes){
				if([[size objectForKey:@"width"] intValue]==250){
					thisStatus.thumbURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}else if([[size objectForKey:@"width"]intValue]==400){
					thisStatus.meduimURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}
				/*retina
				if([[size objectForKey:@"width"] intValue]==400){
					thisStatus.thumbURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}else if([[size objectForKey:@"width"]intValue]==500){
					thisStatus.meduimURL=[NSURL URLWithString:[size objectForKey:@"url"]];
				}
				 */
			}
			if(thisStatus.thumbURL&&thisStatus.meduimURL){
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
				thisStatus.source=StatusSourceTypeTumblr;
				Account *thisAccount=[[[Account alloc]init]autorelease];
				thisAccount.userID=[post objectForKey:@"blog_name"];
				thisStatus.account=thisAccount;
				
				thisStatus.statusID=[NSString stringWithFormat:@"%@",[post objectForKey:@"id"]];
				
				thisStatus.date=[NSDate dateWithTimeIntervalSince1970:[[post objectForKey:@"timestamp"]doubleValue]];
				
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
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.tumblrStatus=StatusFetchingStatusFinished;
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
#pragma mark twitter
-(void)twitterEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier{
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.twitterStatus=StatusFetchingStatusFinished;
	NSMutableArray *_statuses=[tempStatuses objectForKey:request];
	
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setTimeStyle:NSDateFormatterFullStyle];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4];
	[df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	[df setDateFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];
	
	for(NSDictionary *tweet in data){
		NSString *urlRegex=@"[^(href=\\')]?((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))";
		
		NSArray *urls=nil;
		if([tweet objectForKey:@"entities"]&&[tweet objectForKey:@"entities"]!=[NSNull null]){
			if([[tweet objectForKey:@"entities"] objectForKey:@"urls"]){
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
			
			NSURL* thumbURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] boolOnly:NO size:BRImageSizeThumb];
			
			if(thumbURL){
				BOOL addedAlready=NO;
				if([thisUrl rangeOfString:@"instagr.am/p/"].location!=NSNotFound){
					for(Status *status in _statuses){
						if(status.source==StatusSourceTypeInstagram){
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
					thisStatus.source=StatusSourceTypeTwitter;
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
					
					Account *thisAccount=[[[Account alloc]init]autorelease];
					thisAccount.userID=[[tweet objectForKey:@"user"]objectForKey:@"id_str"];
					thisAccount.username=[[tweet objectForKey:@"user"]objectForKey:@"name"];
					thisStatus.account=thisAccount;
					
					thisStatus.thumbURL=thumbURL;
					//thisStatus.thumbURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] boolOnly:NO size:BRImageSizeMedium]; <--retina
					thisStatus.meduimURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] boolOnly:NO size:BRImageSizeMedium];
					//thisStatus.meduimURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] boolOnly:NO size:BRImageSizeLarge]; <--retina
					thisStatus.fullURL=[BRTwitterEngine rawImageURLFromURL:[NSURL URLWithString:thisUrl] boolOnly:NO size:BRImageSizeFull];
					
					thisStatus.liked=[[tweet objectForKey:@"favorited"]intValue]==1;
					thisStatus.date=[df dateFromString:[tweet objectForKey:@"created_at"]];
					
					if(![self didCachedStatus:thisStatus inArray:_statuses]){
						[_statuses addObject:thisStatus];
					}
					if(![self didCachedStatus:thisStatus inArray:allStatuses]){
						[allStatuses addObject:thisStatus];
					}
					
					break;
				}
			}
		}
	}
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
-(void)twitterEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier{
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.twitterStatus=StatusFetchingStatusFinished;
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
#pragma mark facebook
- (void)request:(FBRequest *)fbRequest didLoad:(id)result{
	NSString *identifier=[fbRequest identifier];
	StatusRequest *request=[requestsByID objectForKey:identifier];
	
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
			newStatus.source=StatusSourceTypeFacebook;
			newStatus.statusID=[dict objectForKey:@"id"];
			
			if(thumbString){
				newStatus.thumbURL=[NSURL URLWithString:thumbString];
				//newStatus.thumbURL=[NSURL URLWithString:mediumString];
				newStatus.meduimURL=[NSURL URLWithString:mediumString];
				newStatus.fullURL=[NSURL URLWithString:fullString];
			}
			newStatus.webURL=[NSURL URLWithString:[dict	objectForKey:@"link"]];
			
			if([dict objectForKey:@"message"])newStatus.caption=[dict objectForKey:@"message"];
			
			Account *thisAccount=[[[Account alloc]init]autorelease];
			thisAccount.userID=[[dict objectForKey:@"from"]objectForKey:@"id"];
			thisAccount.displayName=[[dict objectForKey:@"from"]objectForKey:@"name"];
			newStatus.account=thisAccount;
			
			//2010-12-01T21:35:43+0000  
			
			newStatus.date=[df dateFromString:[dict objectForKey:@"created_time"]];
			
			
			
			if([dict objectForKey:@"likes"]){
				if([[dict objectForKey:@"likes"] objectForKey:@"data"]&&[[[dict objectForKey:@"likes"] objectForKey:@"data"] isKindOfClass:[NSArray class]]){
					NSArray *likes=[[dict objectForKey:@"likes"] objectForKey:@"data"];
					for(NSDictionary *thisLike in likes){
						NSString *idString=[NSString stringWithFormat:@"%@",[thisLike objectForKey:@"id"]];
						if([idString isEqualToString:[BRFunctions facebookCurrentUserID]]){
							newStatus.liked=YES;
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
	StatusRequest *request=[requestsByID objectForKey:identifier];
	request.facebookStatus=StatusFetchingStatusFinished;
	[self refreshTempStatusForRequest:request];
	[requestsByID removeObjectForKey:identifier];
}
#pragma mark -
-(void)getCommentsForRequest:(CommentRequest*)request{
	StatusSourceType type=request.targetStatus.source;
	switch (type) {
		case StatusSourceTypeInstagram:{
			NSString *requestID=[[BRFunctions sharedInstagram]getCommentsWithMediaID:request.targetStatus.statusID];
			[requestsByID setObject:request forKey:requestID];
		}
			break;
		default:
			break;
	}
}
-(void)didReceivedComments:(NSArray*)comments forRequest:(CommentRequest*)request{
	request.targetStatus.comments=[NSMutableArray arrayWithArray:comments];
	id target=request.delegate;
	[target performSelector:request.selector withObject:comments];
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
		if([[cachedStatus statusID] isEqualToString:statusID]&&[cachedStatus source]==source){
			return YES;
		}
	}
	return NO;
}
-(Status*)firstStatusWithSource:(StatusSourceType)source inArray:(NSArray*)arr{
	if(!arr)return nil;
	if(![arr count])nil;
	for(Status *thisStatus in arr){
		if(thisStatus.source==source){
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

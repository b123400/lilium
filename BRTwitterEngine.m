//
//  BRInstagramEngine.m
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRTwitterEngine.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "NSObject+Identifier.h"
#import "CJSONDeserializer.h"
#import "OAServiceTicket.h"
#import "RegexKitLite.h"
#import "NSString+EscapePercentage.h"

@interface BRTwitterEngine()

-(void)failedWithError:(NSError*)error  forRequestIdentifier:(NSString*)identifier;

@end

@implementation BRTwitterEngine
@synthesize delegate,accessToken;

-(id)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
	return [self initWithConsumer:[[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]autorelease]];
}
-(id)initWithConsumer:(OAConsumer*)_consumer{
	consumer =[_consumer retain];
    fetchers=[[NSMutableArray alloc]init];
	return [self init];
}
-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params{
    return [self performRequestWithPath:path parameters:params withMethod:@"GET"];
}
-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params withMethod:(NSString*)method{
	NSMutableString *paramString=[NSMutableString string];
	for(NSString *key in params){
		if([paramString length]){
			[paramString appendFormat:@"&%@=%@",key,[[params objectForKey:key] stringByEscapingWithPercentage]];
		}else{
			[paramString appendFormat:@"%@=%@",key,[[params objectForKey:key] stringByEscapingWithPercentage]];
		}
	}
	
    NSString *url;
    if([[method lowercaseString]isEqualToString:@"get"]){
        url=[NSString stringWithFormat:@"http://api.twitter.com/1.1/%@.json?%@",path,[paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        url=[NSString stringWithFormat:@"http://api.twitter.com/1.1/%@.json",path];
    }
	
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
																	consumer:consumer
																	   token:accessToken   
																	   realm:nil
														   signatureProvider:nil]autorelease];
    [request setHTTPMethod:method];
    if(![[method lowercaseString]isEqualToString:@"get"]){
        [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [request setValue:@"Fuck you twitter" forHTTPHeaderField:@"X-Twitter-Client"];
	OADataFetcher *fetcher=[[[OADataFetcher alloc]init] autorelease];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestDidFinished:withData:) didFailSelector:@selector(requestDidFailed:withError:)];
    [fetchers addObject:fetcher];
	return [request identifier];
}
- (void)requestDidFinished:(OAServiceTicket *)ticket withData:(NSData *)data {
	NSError *error=nil;
    NSMutableArray *itemsToRemove=[NSMutableArray array];
    for(OADataFetcher *fetcher in fetchers){
        if(fetcher.request==ticket.request){
            [itemsToRemove addObject:fetcher];
        }
    }
    [fetchers removeObject:itemsToRemove];
    
	id object=[[CJSONDeserializer deserializer] deserialize:data error:&error];
	if(error){
		[self failedWithError:error  forRequestIdentifier:[[ticket request]identifier]];
		return;
	}
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(twitterEngine:didReceivedData:forRequestIdentifier:)]){
			[(id)delegate twitterEngine:self didReceivedData:object forRequestIdentifier:[[ticket request]identifier]];
		}
	}
}
- (void)requestDidFailed:(OAServiceTicket *)ticket withError:(NSError *)error{
	[self failedWithError:error  forRequestIdentifier:[[ticket request]identifier]];
    NSMutableArray *itemsToRemove=[NSMutableArray array];
    for(OADataFetcher *fetcher in fetchers){
        if(fetcher.request==ticket.request){
            [itemsToRemove addObject:fetcher];
        }
    }
    [fetchers removeObject:itemsToRemove];
}

-(void)failedWithError:(NSError*)error  forRequestIdentifier:(NSString*)identifier{
	if(!delegate)return;
	if(![(id)delegate respondsToSelector:@selector(twitterEngine:didFailed: forRequestIdentifier:)])return;
	[(id)delegate twitterEngine:self didFailed:error forRequestIdentifier:identifier];
}


#pragma mark API
-(NSString*)getHomeTimelineWithSinceID:(NSString*)sinceID maxID:(NSString*)maxID{
	NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"200",@"count",
								 @"true",@"include_rts",
								 @"true",@"include_entities",nil];
	if(sinceID){
		[params setObject:sinceID forKey:@"since_id"];
	}
	if(maxID){
		[params	setObject:maxID forKey:@"max_id"];
	}
	return [self performRequestWithPath:@"../1/statuses/home_timeline" parameters:params];
}
-(NSString*)getUserTimelineWithUserID:(NSString*)userID sinceID:(NSString*)sinceID maxID:(NSString*)maxID{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"200",@"count",
								 @"true",@"include_rts",
								 @"true",@"include_entities",
                                 userID,@"user_id", nil];
	if(sinceID){
		[params setObject:sinceID forKey:@"since_id"];
	}
	if(maxID){
		[params	setObject:maxID forKey:@"max_id"];
	}
	return [self performRequestWithPath:@"statuses/user_timeline" parameters:params];

}
-(NSString*)getRepliesForStatusWithID:(NSString*)statusID{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"true",@"include_entities",nil];
//    statusID=@"274902397728477185";
	return [self performRequestWithPath:[NSString stringWithFormat:@"../1/related_results/show/%@",statusID] parameters:params];
}

-(NSString*)markFavorite:(BOOL)favorite forStatusWithID:(NSString*)statusID{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								 statusID,@"id", nil];
    if(favorite){
        return [self performRequestWithPath:@"favorites/create" parameters:params withMethod:@"POST"];
    }
    return [self performRequestWithPath:@"favorites/destroy" parameters:params withMethod:@"POST"];
}
-(NSString*)getAuthedUserInfo{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"true",@"include_entities",nil];
	return [self performRequestWithPath:@"account/verify_credentials" parameters:params];
}
-(NSString*)getUserInfoWithUserID:(NSString*)userID{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"true",@"include_entities",nil];
    [params setObject:userID forKey:@"user_id"];
	return [self performRequestWithPath:@"users/show" parameters:params];
}
-(NSString*)sendTweet:(NSString*)tweet inReplyToStatusWithID:(NSString*)statusID{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								 tweet,@"status", nil];
    if(statusID){
        [params setObject:statusID forKey:@"in_reply_to_status_id"];
    }
    return [self performRequestWithPath:@"statuses/update" parameters:params withMethod:@"POST"];
}
#pragma mark misc
+(NSURL*)rawImageURLFromURL:(NSURL*)aURL size:(BRImageSize)size{
	NSString *urlString=[aURL absoluteString];
	NSString *regex=nil;
	//twitpic
	regex=@"http://(www.)?twitpic.com/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageID=[captures lastObject];
		if(![imageID isEqualToString:@""]){
			if(size==BRImageSizeLarge){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://twitpic.com/show/large/%@",imageID]];
			}else if(size==BRImageSizeThumb){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://twitpic.com/show/thumb/%@",imageID]];
			}else if(size==BRImageSizeMedium){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://twitpic.com/show/large/%@",imageID]];
			}else if(size==BRImageSizeFull){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://twitpic.com/show/full/%@",imageID]];
			}
		}
	}
	//img.ly
	regex=@"http://(www.)?img.ly/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageID=[captures lastObject];
		if(![imageID isEqualToString:@""]){
			if(size==BRImageSizeThumb){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://img.ly/show/thumb/%@",imageID]];
			}else if(size==BRImageSizeMedium){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://img.ly/show/medium/%@",imageID]];
			}else if(size==BRImageSizeLarge){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://img.ly/show/large/%@",imageID]];
			}else if(size==BRImageSizeFull){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://img.ly/show/full/%@",imageID]];
			}
		}
	}
	//yfrog
	regex=@"http://(www.)?yfrog.com/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageAddress=[captures objectAtIndex:0];
		NSString *imageID=[[captures lastObject] substringFromIndex:[[captures lastObject]length]-2];
		if(![imageID isEqualToString:@"z"]&&![imageID isEqualToString:@"f"]){
			///those are video
			if(![imageAddress isEqualToString:@""]){
				if(size==BRImageSizeThumb){
					return [NSURL URLWithString:[NSString stringWithFormat:@"%@:small",imageAddress]];
				}else{
					return [NSURL URLWithString:[NSString stringWithFormat:@"%@:iphone",imageAddress]];
				}
			}
		}else{
			//this is video
			return nil;
		}
	}
	//moby.to
	regex=@"http://(www.)?moby.to/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageAddress=[captures objectAtIndex:0];
		if(![imageAddress isEqualToString:@""]){
			if(size!=BRImageSizeFull){
				return [NSURL URLWithString:[NSString stringWithFormat:@"%@:medium",imageAddress]];
			}else{
				return [NSURL URLWithString:[NSString stringWithFormat:@"%@:full",imageAddress]];
			}
		}
	}
	//instagram
	regex=@"http://(www.)?instagr.am/p/([^/]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageAddress=[captures objectAtIndex:0];
		if(![imageAddress isEqualToString:@""]){
			if(size==BRImageSizeThumb){
				return [NSURL URLWithString:[NSString stringWithFormat:@"%@/media/?size=t",imageAddress]];
			}else if(size==BRImageSizeMedium){
				return [NSURL URLWithString:[NSString stringWithFormat:@"%@/media/?size=m",imageAddress]];
			}else{
				return [NSURL URLWithString:[NSString stringWithFormat:@"%@/media/?size=l",imageAddress]];
			}
		}
	}
	//twitgoo
	regex=@"http://(www.)?twitgoo.com/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageAddress=[captures objectAtIndex:0];
		if(![imageAddress isEqualToString:@""]){
			if(size==BRImageSizeThumb){
				return [NSURL URLWithString:[NSString stringWithFormat:@"%@/thumb",imageAddress]];
			}
			return [NSURL URLWithString:[NSString stringWithFormat:@"%@/img",imageAddress]];
		}
	}
	//twipl
	regex=@"http://(www.)?twipl.net/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageID=[captures lastObject];
		if(![imageID isEqualToString:@""]){
			if(size==BRImageSizeThumb){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twipl.net/show/thumb/%@",imageID]];
			}else if(size==BRImageSizeMedium||size==BRImageSizeLarge){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twipl.net/show/view/%@",imageID]];
			}
			return [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twipl.net/show/large/%@",imageID]];
		}
	}
	//twipple
	regex=@"http://p.twipple.jp/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageID=[captures lastObject];
		if(size==BRImageSizeThumb){
			return [NSURL URLWithString:[NSString stringWithFormat:@"http://p.twipple.jp/show/thumb/%@",imageID]];
		}else if(size==BRImageSizeMedium||size==BRImageSizeLarge){
			return [NSURL URLWithString:[NSString stringWithFormat:@"http://p.twipple.jp/show/large/%@",imageID]];
		}else if(size==BRImageSizeFull){
				return [NSURL URLWithString:[NSString stringWithFormat:@"http://p.twipple.jp/show/orig/%@",imageID]];
		}
	}
	//step.ly
	regex=@"http://step.ly/p/([a-zA-Z0-9]+)";
	if([urlString isMatchedByRegex:regex]){
		
		NSArray *captures=[urlString captureComponentsMatchedByRegex:regex];
		NSString *imageID=[captures lastObject];
		if(![imageID isEqualToString:@""]){
			NSURL *theURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://steply.com/photos/%@/image",imageID]];
			return theURL;
		}
	}
	return nil;
}

-(void)dealloc{
    for(OADataFetcher *fetcher in fetchers){
        [fetcher.connection cancel];
        fetcher.delegate=nil;
    }
    [fetchers release];
	[consumer release];
	[super dealloc];
}

@end

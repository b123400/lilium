//
//  BRInstagramEngine.m
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRTumblrEngine.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "NSObject+Identifier.h"
#import "CJSONDeserializer.h"
#import "OAServiceTicket.h"

@interface BRTumblrEngine()

-(void)failedWithError:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end

@implementation BRTumblrEngine
@synthesize delegate,accessToken;

-(instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
	return [self initWithConsumer:[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]];
}
-(instancetype)initWithConsumer:(OAConsumer*)_consumer{
	consumer =_consumer;
    fetchers=[[NSMutableArray alloc]init];
	return [self init];
}

-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSMutableDictionary*)params{
    return [self performRequestWithPath:path parameters:params method:@"GET"];
}
-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSMutableDictionary*)params method:(NSString*)method{
	NSMutableString *paramString=[NSMutableString string];
    if(![params isKindOfClass:[NSMutableDictionary class]]){
        params=[NSMutableDictionary dictionaryWithDictionary:params];
    }
    params[@"api_key"] = consumer.key;
	for(NSString *key in params){
		if([paramString length]){
			[paramString appendFormat:@"&%@=%@",key,params[key]];
		}else{
			[paramString appendFormat:@"%@=%@",key,params[key]];
		}
	}
	
	NSString *url;
    if([[method lowercaseString] isEqualToString:@"get"]){
        url=[NSString stringWithFormat:@"http://api.tumblr.com/v2/%@?%@",path,paramString];
	}else{
        url=[NSString stringWithFormat:@"http://api.tumblr.com/v2/%@",path];
    }
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
																	consumer:consumer
																	   token:accessToken   
																	   realm:nil   
														   signatureProvider:nil];
    if(![[method lowercaseString] isEqualToString:@"get"]){
        request.HTTPMethod=method;
        [request setHTTPBodyWithString:paramString];
    }
	OADataFetcher *fetcher=[[OADataFetcher alloc]init];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestDidFinished:withData:) didFailSelector:@selector(requestDidFailed:withError:)];
    [fetchers addObject:fetcher];
	return [request identifier];
}
- (void)requestDidFinished:(OAServiceTicket *)ticket withData:(NSData *)data {
    NSMutableArray *itemsToRemove=[NSMutableArray array];
    for(OADataFetcher *fetcher in fetchers){
        if(fetcher.request==ticket.request){
            [itemsToRemove addObject:fetcher];
        }
    }
    [fetchers removeObject:itemsToRemove];
    
	NSError *error=nil;
	id object=[[CJSONDeserializer deserializer] deserialize:data error:&error];
	if(error){
		[self failedWithError:error  forRequestIdentifier:[[ticket request]identifier]];
		return;
	}
    if([(NSHTTPURLResponse*)ticket.response statusCode]>=400){
        error=[NSError errorWithDomain:@"net.b123400.engine.tumblr" code:[(NSHTTPURLResponse*)ticket.response statusCode] userInfo:nil];
        [self failedWithError:error forRequestIdentifier:[[ticket request]identifier]];
        return;
    }
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(tumblrEngine:didReceivedData:forRequestIdentifier:)]){
			[(id)delegate tumblrEngine:self didReceivedData:object forRequestIdentifier:[[ticket request]identifier]];
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
	if(![(id)delegate respondsToSelector:@selector(tumblrEngine:didFailed: forRequestIdentifier:)])return;
	[(id)delegate tumblrEngine:self didFailed:error  forRequestIdentifier:identifier];
}

#pragma mark - rest-ful api

-(NSString*)getUserDashBoardWithSinceID:(NSString*)sinceID offset:(int)offset{
	NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObject:@"photo" forKey:@"type"];
	if(sinceID){
		params[@"since_id"] = sinceID;
	}
	if(offset){
		params[@"offset"] = [NSString stringWithFormat:@"%i",offset];
	}
    params[@"notes_info"] = @"true";
	return [self performRequestWithPath:@"user/dashboard" parameters:params];
}
-(NSString*)getPostsWithBaseHostname:(NSString*)baseHostname offset:(int)offset{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObject:@"photo" forKey:@"type"];
    //[params setObject:baseHostname forKey:@"base-hostname"];
	if(offset){
		params[@"offset"] = [NSString stringWithFormat:@"%i",offset];
	}
    //[params setObject:@"true" forKey:@"notes_info"];
	return [self performRequestWithPath:[NSString stringWithFormat:@"blog/%@/posts/photo",baseHostname] parameters:params];
}
-(NSString*)likePostWithID:(NSString*)postID reblogKey:(NSString*)reblogKey{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"id"] = postID;
    params[@"reblog_key"] = reblogKey;
	return [self performRequestWithPath:@"user/like" parameters:params method:@"post"];
}
-(NSString*)unlikePostWithID:(NSString*)postID reblogKey:(NSString*)reblogKey{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"id"] = postID;
    params[@"reblog_key"] = reblogKey;
	return [self performRequestWithPath:@"user/unlike" parameters:params method:@"post"];
}
-(NSString*)getUserBlogs{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
	return [self performRequestWithPath:@"user/info" parameters:params];
}
-(NSString*)reblogPostWithBaseHostname:(NSString*)baseHostname postID:(NSString*)postID reblogKey:(NSString*)reblogKey comment:(NSString*)comment{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"id"] = postID;
    params[@"reblog_key"] = reblogKey;
    if(comment)params[@"comment"] = comment;
	return [self performRequestWithPath:[NSString stringWithFormat:@"blog/%@/post/reblog",baseHostname] parameters:params method:@"post"];
}
-(NSString*)getBlogPostInfoWithBaseHostName:(NSString*)baseHostname postId:(NSString*)postID withNotes:(BOOL)withNotes{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"id"] = postID;
    if(withNotes){
        params[@"notes_info"] = @"true";
    }
	return [self performRequestWithPath:[NSString stringWithFormat:@"blog/%@/posts",baseHostname] parameters:params];
}
-(void)dealloc{
    for(OADataFetcher *fetcher in fetchers){
        [fetcher.connection cancel];
        fetcher.delegate=nil;
    }
}

@end

//
//  BRInstagramEngine.m
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRInstagramEngine.h"
#import "ASIFormDataRequest.h"
#import "NSObject+Identifier.h"
#import "CJSONDeserializer.h"

@interface BRInstagramEngine()

-(void)failedWithError:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end

@implementation BRInstagramEngine
@synthesize redirectUri, scope,accessToken,delegate;

-(id)initWithClientID:(NSString*)_clientID secret:(NSString*)_clientSecret{
	clientID=[_clientID retain];
	clientSecret=[_clientSecret retain];
    requests=[[NSMutableArray alloc]init];
	
	return [super init];
}

-(void)dealloc{
    for(ASIHTTPRequest* request in requests){
        [request cancel];
        request.delegate=nil;
    }
    [requests release];
	[clientID release];
	[clientSecret release];
	if(redirectUri)[redirectUri release];
	if(scope)[scope release];
	[super dealloc];
}

-(NSURL*)authURL:(BOOL)mobileLayout{
	NSString *urlString=[NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&response_type=token",clientID];
	if(scope){
		urlString=[urlString stringByAppendingFormat:@"&scope=%@",scope];
	}
	if(mobileLayout){
		urlString=[urlString stringByAppendingFormat:@"&display=touch"];
	}
	
	
	urlString=[urlString stringByAppendingFormat:@"&redirect_uri=%@",(NSString *)CFURLCreateStringByAddingPercentEscapes(
																														 NULL,
																														 (CFStringRef)[[self redirectUri]absoluteString],
																														 NULL,
																														 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																														 kCFStringEncodingUTF8 )];
	return [NSURL URLWithString:urlString];
}

-(NSURL*)redirectUri{
	if(!redirectUri){
		return [NSURL URLWithString:instagramDefaultRedirectURL];
	}
	return redirectUri;
}

-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params{
    return [self performRequestWithPath:path parameters:params withMethod:@"get"];
}
-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)_params withMethod:(NSString *)method{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:_params];
    [params setObject:accessToken forKey:@"access_token"];
    
	NSMutableString *paramString=[NSMutableString string];
	for(NSString *key in params){
        if(paramString.length){
            [paramString appendFormat:@"&%@=%@",key,[params objectForKey:key]];
        }else{
            [paramString appendFormat:@"%@=%@",key,[params objectForKey:key]];
        }
	}
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@""]];
	if([[method lowercaseString] isEqualToString:@"get"]){
        request.url=[NSURL URLWithString:[NSString	stringWithFormat:@"https://api.instagram.com/v1/%@?%@",path,paramString]];
    }else if([[method lowercaseString]isEqualToString:@"delete"]){
        request.url=[NSURL URLWithString:[NSString	stringWithFormat:@"https://api.instagram.com/v1/%@?access_token=%@",path,accessToken]];
        [request appendPostData:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
        [request buildPostBody];
        request.requestMethod=method;
    }else{
        request.url=[NSURL URLWithString:[NSString	stringWithFormat:@"https://api.instagram.com/v1/%@",path]];
        [request appendPostData:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
        request.requestMethod=method;
    }
    
	[request setDelegate:self];
	[request startAsynchronous];
	[requests addObject:request];
	return [request identifier];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [requests removeObject:request];
	// Use when fetching binary data
	NSData *responseData = [request responseData];
    NSLog(@"%@",[[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding]autorelease]);
	NSError *error=nil;
	id object=[[CJSONDeserializer deserializer]deserialize:responseData error:&error];
	if(error){
		[self failedWithError:error forRequestIdentifier:[request identifier]];
		return;
	}
    if(request.responseStatusCode>=400){
        error=[NSError errorWithDomain:@"net.b123400.engine.tumblr" code:request.responseStatusCode userInfo:nil];
        [self failedWithError:error forRequestIdentifier:[request identifier]];
        return;
    }
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(instagramEngine:didReceivedData:forRequestIdentifier:)]){
			[(id)delegate instagramEngine:self didReceivedData:object forRequestIdentifier:[request identifier]];
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self failedWithError:error  forRequestIdentifier:[request identifier]];
    [requests removeObject:request];
}

-(void)failedWithError:(NSError*)error forRequestIdentifier:(NSString*)identifier{
	if(!delegate)return;
	if(![(id)delegate respondsToSelector:@selector(instagramEngine:didFailed: forRequestIdentifier:)])return;
	[(id)delegate instagramEngine:self didFailed:error forRequestIdentifier:identifier];
}
#pragma mark - REST api
-(NSString*)getSelfFeedWithMinID:(NSString*)minID maxID:(NSString*)maxID{
	NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObject:@"20" forKey:@"count"];
	if(minID){
		[params setObject:minID forKey:@"min_id"];
	}
    if(maxID){
		[params setObject:maxID forKey:@"max_id"];
	}
	return [self performRequestWithPath:@"users/self/feed" parameters:params];
}
-(NSString*)getUserFeedWithUserID:(NSString*)userID minID:(NSString*)minID maxID:(NSString*)maxID{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    if(minID){
        [params setObject:minID forKey:@"MIN_ID"];
    }
    if(maxID){
        [params setObject:maxID forKey:@"MAX_ID"];
    }
    return [self performRequestWithPath:[NSString stringWithFormat:@"users/%@/media/recent",userID] parameters:params];
}
-(NSString*)getCommentsWithMediaID:(NSString*)mediaID{
	NSMutableDictionary *params=[NSMutableDictionary dictionary];
	return [self performRequestWithPath:[NSString stringWithFormat:@"media/%@/comments",mediaID] parameters:params];
}
-(NSString*)sendComment:(NSString*)comment withMediaID:(NSString*)mediaID{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObject:comment forKey:@"text"];
	return [self performRequestWithPath:[NSString stringWithFormat:@"media/%@/comments",mediaID] parameters:params withMethod:@"POST"];
}
-(NSString*)likeMediaWithMediaID:(NSString*)mediaID{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
	return [self performRequestWithPath:[NSString stringWithFormat:@"media/%@/likes",mediaID] parameters:params withMethod:@"POST"];
}
-(NSString*)unlikeMediaWithMediaID:(NSString*)mediaID{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
	return [self performRequestWithPath:[NSString stringWithFormat:@"media/%@/likes",mediaID] parameters:params withMethod:@"DELETE"];
}
-(NSString*)getUserInfoWithUserID:(NSString*)userID{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
	return [self performRequestWithPath:[NSString stringWithFormat:@"users/%@",userID] parameters:params];
}
@end

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

-(id)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
	return [self initWithConsumer:[[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]autorelease]];
}
-(id)initWithConsumer:(OAConsumer*)_consumer{
	consumer =[_consumer retain];
    fetchers=[[NSMutableArray alloc]init];
	return [self init];
}

-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSMutableDictionary*)params{
	NSMutableString *paramString=[NSMutableString string];
    if(![params isKindOfClass:[NSMutableDictionary class]]){
        params=[NSMutableDictionary dictionaryWithDictionary:params];
    }
    [params setObject:consumer.key forKey:@"api_key"];
	for(NSString *key in params){
		if([paramString length]){
			[paramString appendFormat:@"&%@=%@",key,[params objectForKey:key]];
		}else{
			[paramString appendFormat:@"?%@=%@",key,[params objectForKey:key]];
		}
	}
	
	NSString *url=[NSString stringWithFormat:@"http://api.tumblr.com/v2/%@%@",path,paramString];
	
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
																	consumer:consumer
																	   token:accessToken   
																	   realm:nil   
														   signatureProvider:nil]autorelease];
	OADataFetcher *fetcher=[[[OADataFetcher alloc]init] autorelease];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestDidFinished:withData:) didFailSelector:@selector(requestDidFailed:withError:)];
    [fetchers addObject:fetcher];
	return [request identifier];
}
- (void)requestDidFinished:(OAServiceTicket *)ticket withData:(NSData *)data {
    for(OADataFetcher *fetcher in fetchers){
        if(fetcher.request==ticket.request){
            [fetchers removeObject:fetcher];
        }
    }
    
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
    for(OADataFetcher *fetcher in fetchers){
        if(fetcher.request==ticket.request){
            [fetchers removeObject:fetcher];
        }
    }
}

-(void)failedWithError:(NSError*)error  forRequestIdentifier:(NSString*)identifier{
	if(!delegate)return;
	if(![(id)delegate respondsToSelector:@selector(tumblrEngine:didFailed: forRequestIdentifier:)])return;
	[(id)delegate tumblrEngine:self didFailed:error  forRequestIdentifier:identifier];
}



-(NSString*)getUserDashBoardWithSinceID:(NSString*)sinceID offset:(int)offset{
	NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObject:@"photo" forKey:@"type"];
	if(sinceID){
		[params setObject:sinceID forKey:@"since_id"];
	}
	if(offset){
		[params setObject:[NSString stringWithFormat:@"%i",offset] forKey:@"offset"];
	}
    [params setObject:@"true" forKey:@"notes_info"];
	return [self performRequestWithPath:@"user/dashboard" parameters:params];
}
-(NSString*)getPostsWithBaseHostname:(NSString*)baseHostname offset:(int)offset{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObject:@"photo" forKey:@"type"];
    //[params setObject:baseHostname forKey:@"base-hostname"];
	if(offset){
		[params setObject:[NSString stringWithFormat:@"%i",offset] forKey:@"offset"];
	}
    //[params setObject:@"true" forKey:@"notes_info"];
	return [self performRequestWithPath:[NSString stringWithFormat:@"blog/%@/posts/photo",baseHostname] parameters:params];
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

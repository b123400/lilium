//
//  BRFlickrEngine.m
//  perSecond
//
//  Created by b123400 on 16/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRFlickrEngine.h"
#import "OADataFetcher.h"
#import "NSObject+Identifier.h"
#import "CJSONDeserializer.h"

@interface BRFlickrEngine ()

-(void)failedWithError:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end

@implementation BRFlickrEngine
@synthesize accessToken,delegate;

-(instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
	return [self initWithConsumer:[[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]autorelease]];
}
-(instancetype)initWithConsumer:(OAConsumer*)_consumer{
	consumer=[_consumer retain];
    fetchers=[[NSMutableArray alloc]init];
	return [self init];
}

-(NSString*)performRequestWithMethod:(NSString*)method parameters:(NSDictionary*)params{
    return [self performRequestWithMethod:method parameters:params withHTTPMethod:@"GET"];
}
-(NSString*)performRequestWithMethod:(NSString*)method parameters:(NSDictionary*)_params withHTTPMethod:(NSString*)httpMethod{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:_params];
    params[@"method"] = method;
    params[@"api_key"] = [consumer key];
    params[@"format"] = @"json";
    params[@"nojsoncallback"] = @"1";
    
	NSMutableString *paramString=[NSMutableString string];
    for(NSString *key in params){
        if(paramString.length){
            [paramString appendFormat:@"&%@=%@",key,params[key]];
        }else{
            [paramString appendFormat:@"%@=%@",key,params[key]];
        }
	}
	
	NSString *url;
    if([[httpMethod lowercaseString] isEqualToString:@"get"]){
        url=[NSString stringWithFormat:@"http://api.flickr.com/services/rest?%@",paramString];
    }else{
        url=@"http://api.flickr.com/services/rest";
    }
	
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
																	consumer:consumer
																	   token:accessToken   
																	   realm:nil   
														   signatureProvider:nil]autorelease];
    if(![[httpMethod lowercaseString]isEqualToString:@"get"]){
        request.HTTPMethod=httpMethod;
        [request setHTTPBodyWithString:paramString];
    }
	OADataFetcher *fetcher=[[[OADataFetcher alloc]init] autorelease];
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
		[self failedWithError:error forRequestIdentifier:[[ticket request]identifier]];
		return;
	}
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(flickrEngine:didReceivedData:forRequestIdentifier:)]){
			[(id)delegate flickrEngine:self didReceivedData:object forRequestIdentifier:[[ticket request]identifier]];
		}
	}
}
- (void)requestDidFailed:(OAServiceTicket *)ticket withError:(NSError *)error{
	[self failedWithError:error forRequestIdentifier:[[ticket request]identifier]];
    NSMutableArray *itemsToRemove=[NSMutableArray array];
    for(OADataFetcher *fetcher in fetchers){
        if(fetcher.request==ticket.request){
            [itemsToRemove addObject:fetcher];
        }
    }
    [fetchers removeObject:itemsToRemove];
}

-(void)failedWithError:(NSError*)error forRequestIdentifier:(NSString*)identifier{
	if(!delegate)return;
	if(![(id)delegate respondsToSelector:@selector(flickrEngine:didFailed: forRequestIdentifier:)])return;
	[(id)delegate flickrEngine:self didFailed:error forRequestIdentifier:identifier];
}

-(NSString*)getContactsPhotos{
	return [self performRequestWithMethod:@"flickr.photos.getContactsPhotos" parameters:@{@"include_self": @"1",
																						 @"50": @"count"}];
}
-(NSString*)getPhotosOfUser:(NSString*)userID minDate:(NSDate*)minDate maxDate:(NSDate*)maxDate page:(int)page{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"user_id"] = userID;
    if(minDate){
        params[@"min_upload_date"] = [NSString stringWithFormat:@"%f",[minDate timeIntervalSince1970]];
    }
    if(maxDate){
        params[@"max_upload_date"] = [NSString stringWithFormat:@"%f",[maxDate timeIntervalSince1970]];
    }
    if(page){
        params[@"page"] = [NSString stringWithFormat:@"%d",page];
    }
    return [self performRequestWithMethod:@"flickr.people.getPhotos" parameters:params];
}
-(NSString*)getCommentsForPhotoWithID:(NSString*)photoID{
	return [self performRequestWithMethod:@"flickr.photos.comments.getList" parameters:@{@"photo_id": photoID}];
}
-(NSString*)addFavoritesForPhotoWithID:(NSString*)photoID{
    return [self performRequestWithMethod:@"flickr.favorites.add" parameters:@{@"photo_id": photoID}];
}
-(NSString*)removeFavoritesForPhotoWithID:(NSString*)photoID{
    return [self performRequestWithMethod:@"flickr.favorites.remove" parameters:@{@"photo_id": photoID}];
}
-(NSString*)getUserInfoWithUserID:(NSString*)userID{
    return [self performRequestWithMethod:@"flickr.people.getInfo" parameters:@{@"user_id": userID}];
}
-(NSString*)addComment:(NSString*)comment toPhotoWithPhotoID:(NSString*)photoID{
    return [self performRequestWithMethod:@"flickr.photos.comments.addComment" parameters:@{@"photo_id": photoID,
                                                                               @"comment_text": comment}];
}
#pragma mark -
+ (NSURL *)iconSourceURLWithFarm:(int)farm iconServer:(int)server userID:(NSString*)userID{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%d.staticflickr.com/%d/buddyicons/%@.jpg",farm,server,userID]];
}
+ (NSURL *)photoSourceURLFromDictionary:(NSDictionary *)inDictionary size:(NSString *)inSizeModifier
{
	// http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}_[mstb].jpg
	// http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
	
	NSNumber* farm = inDictionary[@"farm"];
	NSNumber *photoID = inDictionary[@"id"];
	NSString *secret = inDictionary[@"secret"];
	NSNumber *server = inDictionary[@"server"];
	
	NSMutableString *URLString = [NSMutableString stringWithString:@"http://"];
	if (farm) {
		[URLString appendFormat:@"farm%@.", farm];
	}
	
	// skips "http://"
	NSAssert(server, @"Must have server attribute");
	NSAssert(photoID , @"Must have id attribute");
	NSAssert(secret , @"Must have secret attribute");
	[URLString appendString:@"static.flickr.com/"];
	[URLString appendFormat:@"%@/%@_%@", server, photoID, secret];
	
	if (inSizeModifier) {
		[URLString appendFormat:@"_%@.jpg", inSizeModifier];
	}
	else {
		[URLString appendString:@".jpg"];
	}
	
	return [NSURL URLWithString:URLString];
}
+ (NSURL *)webPageURLFromDictionary:(NSDictionary *)inDictionary{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@/",inDictionary[@"owner"],inDictionary[@"id"]]];
}

+ (NSString *)shortURLIDFromPhotoID:(long long)num {
	NSString *alphabet = @"123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
	int baseCount = [alphabet length];
	NSString *encoded = @"";
	while(num >= baseCount) {
		double div = num/baseCount;
		long long mod = (num - (baseCount * (long long)div));
		NSString *alphabetChar = [alphabet substringWithRange: NSMakeRange(mod, 1)];
		encoded = [NSString stringWithFormat: @"%@%@", alphabetChar, encoded];
		num = (long long)div;
	}
	
	if(num) {
		encoded = [NSString stringWithFormat: @"%@%@", [alphabet substringWithRange: NSMakeRange(num, 1)], encoded];
	}
	return encoded;
}

+ (NSString *)photoIDFromShortURLID:(NSString *)strNum {
	NSString *alphabet = @"123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
	
	unsigned long long lDecoded = 0;
	unsigned long long lMulti = 1;
	NSString *lastCharOfNum;
	
	while ([strNum length] > 0) {
		lastCharOfNum = [strNum substringFromIndex:([strNum length] - 1)];
		lDecoded += lMulti * [alphabet rangeOfString:lastCharOfNum].location;
		lMulti = lMulti * [alphabet length];
		strNum = [strNum substringToIndex:[strNum length] - 1];
	}
	
	return [NSString stringWithFormat:@"%llu", lDecoded];
}

-(void)dealloc{
    for(OADataFetcher *fetcher in fetchers){
        [fetcher.connection cancel];
        fetcher.delegate=nil;
    }
    [fetchers release];
	[super dealloc];
}

@end

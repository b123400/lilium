//
//  BRFunctions.m
//  perSecond
//
//  Created by b123400 on 01/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRFunctions.h"
#import "StatusFetcher.h"

@implementation BRFunctions

static BRTwitterEngine *sharedTwitter=nil;
static Facebook *sharedFacebook=nil;
static BRInstagramEngine *sharedInstagram=nil;
static BRFunctions *sharedObject=nil;
static BRFlickrEngine *sharedFlickr = nil;
static BRTumblrEngine *sharedTumblr = nil;

#pragma mark -
#pragma mark Twitter

+(BRTwitterEngine*)sharedTwitter{
	if(!sharedTwitter){
		sharedTwitter=[[BRTwitterEngine alloc]initWithConsumerKey:kTwitterOAuthConsumerKey consumerSecret:kTwitterOAuthConsumerSecret];
		sharedTwitter.accessToken=[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:twitterSaveKey]autorelease];
		sharedTwitter.delegate=[StatusFetcher sharedFetcher];
	}
	return sharedTwitter;
}
+(void)saveTwitterToken:(OAToken*)token{
	[token storeInUserDefaultsWithServiceProviderName:nil prefix:twitterSaveKey];
	
	if(sharedTwitter){
		[sharedTwitter setAccessToken:token];
	}
}
+(BOOL)didLoggedInTwitter{
	OAToken *token=[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:twitterSaveKey]autorelease];
	if(token){
		return YES;
	}
	return NO;
}
#pragma mark -
#pragma mark Facebook
+(Facebook*)sharedFacebook{
	if(!sharedFacebook){
		sharedFacebook=[[Facebook alloc] initWithAppId:kFacebookAppID];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"FBAccessTokenKey"] 
			&& [defaults objectForKey:@"FBExpirationDateKey"]) {
			sharedFacebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
			sharedFacebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
		}
	}
	return sharedFacebook;
}
+(void)setFacebookCurrentUserID:(NSString*)userID{
	[[NSUserDefaults	standardUserDefaults] setObject:userID forKey:@"currentFacebookUserId"];
}
+(NSString*)facebookCurrentUserID{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"currentFacebookUserId"];
}
+(BOOL)isFacebookLoggedIn:(BOOL)authIfNotLoggedIn{
	BOOL logged=[[BRFunctions sharedFacebook] isSessionValid];
	if(authIfNotLoggedIn&&!logged){
		NSArray *permissions=[NSArray arrayWithObjects:@"friends_photos",@"friends_videos",@"publish_stream",@"offline_access",@"read_stream",nil];
		[[BRFunctions sharedFacebook] authorize:permissions delegate:[BRFunctions sharedObject]];
	}
	return logged;
}
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[BRFunctions sharedFacebook] accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[[BRFunctions sharedFacebook] expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:facebookDidLoginNotification	object:nil];
}
- (void)fbDidNotLogin:(BOOL)cancelled{
	[[NSNotificationCenter defaultCenter] postNotificationName:facebookDidNotLoginNotification	object:nil];
}
- (void)fbDidLogout{
	[BRFunctions setFacebookCurrentUserID:nil];
}
#pragma mark -
#pragma mark Instagram
+(BRInstagramEngine*)sharedInstagram{
	if(!sharedInstagram){
		sharedInstagram=[[BRInstagramEngine alloc]initWithClientID:instagramClientID secret:instagramClientSecret];
		sharedInstagram.scope=@"likes+comments";
		sharedInstagram.redirectUri=[NSURL URLWithString:@"persecond://authed"];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		sharedInstagram.accessToken=[defaults objectForKey:instagramSaveKey];
		
		sharedInstagram.delegate=[StatusFetcher sharedFetcher];
	}
	return sharedInstagram;
}
+(void)saveInstagramToken:(NSString*)token{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:instagramSaveKey];
    [defaults synchronize];
	
	if(sharedInstagram){
		[sharedInstagram setAccessToken:token];
	}
}
+(BOOL)didLoggedInInstagram{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults objectForKey:instagramSaveKey]){
		return YES;
	}
	return NO;
}
#pragma mark -
#pragma mark Flickr
+(BRFlickrEngine*)sharedFlickr{
	if(!sharedFlickr){
		//sharedFlickr = [[OFFlickrAPIContext alloc] initWithAPIKey:flickrAPIKey sharedSecret:flickrAPISecret];
		sharedFlickr=[[BRFlickrEngine alloc]initWithConsumerKey:flickrAPIKey consumerSecret:flickrAPISecret];
		[sharedFlickr setAccessToken:[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:flickrSaveKey]autorelease]];
		sharedFlickr.delegate=[StatusFetcher sharedFetcher];
	}
	return sharedFlickr;
}
+(void)saveFlickrToken:(OAToken*)token{
	[token	storeInUserDefaultsWithServiceProviderName:nil prefix:flickrSaveKey];
	
	if(sharedFlickr){
		[sharedFlickr setAccessToken:token];
	}
}
+(BOOL)didLoggedInFlickr{
	OAToken *token=[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:flickrSaveKey]autorelease];
	if(token){
		return YES;
	}
	return NO;
}
#pragma mark -
#pragma mark tumblr
+(BRTumblrEngine*)sharedTumblr{
	if(!sharedTumblr){
		sharedTumblr=[[BRTumblrEngine alloc]initWithConsumerKey:tumblrAPIKey consumerSecret:tumblrAPISecret];
		
		OAToken *token=[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:tumblrSaveKey]autorelease];
		sharedTumblr.accessToken=token;
		sharedTumblr.delegate=[StatusFetcher sharedFetcher];
	}
	return sharedTumblr;
}
+(void)saveTumblrToken:(OAToken*)token{
	[token	storeInUserDefaultsWithServiceProviderName:nil prefix:tumblrSaveKey];
	if(sharedTumblr){
		sharedTumblr.accessToken=token;
	}
}
+(BOOL)didLoggedInTumblr{
	OAToken *token=[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:tumblrSaveKey]autorelease];
	if(token){
		return YES;
	}
	return NO;
}
#pragma mark -
+(BRFunctions*)sharedObject{
	if(!sharedObject){
		sharedObject=[[BRFunctions alloc]init];
	}
	return sharedObject;
}

+(CGSize)screenSize{
	if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])){
		CGSize size=CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
		return size;
	}else{
		return [[UIScreen mainScreen] bounds].size;
	}
}
+(dispatch_queue_t)imageQueue{
	static dispatch_queue_t imageQueue=nil;
	if(!imageQueue){
		imageQueue=dispatch_queue_create("net.b123400.imageQueue", 0);
		dispatch_retain(imageQueue);
	}
	return imageQueue;
}

@end

//
//  BRFunctions.m
//  perSecond
//
//  Created by b123400 on 01/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRFunctions.h"
#import "StatusFetcher.h"
#import "TumblrUser.h"

@interface BRFunctions ()

+(void)requestFinished:(UserRequest*)request didReceivedTwitterUser:(User*)user;
+(void)requestFinished:(UserRequest*)request didReceivedFacebookUser:(User*)user;
+(void)requestFinished:(UserRequest*)request didReceivedInstagramUser:(User*)user;
+(void)requestFinished:(UserRequest*)request didReceivedTumblrUsers:(NSMutableArray*)users;

@end

@implementation BRFunctions

static BRTwitterEngine *sharedTwitter=nil;
static User *twitterUser=nil;
static Facebook *sharedFacebook=nil;
static FacebookUser *facebookUser=nil;
static BRInstagramEngine *sharedInstagram=nil;
static User *instagramUser=nil;
static BRFunctions *sharedObject=nil;
static BRFlickrEngine *sharedFlickr = nil;
static BRTumblrEngine *sharedTumblr = nil;
static NSMutableArray *tumblrUsers=nil;

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
    [BRFunctions loadAccounts];
}
+(BOOL)didLoggedInTwitter{
	OAToken *token=[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:twitterSaveKey]autorelease];
	if(token){
		return YES;
	}
	return NO;
}
+(User*)twitterUser{
    return twitterUser;
}
+(void)logoutTwitter{
    if(![self didLoggedInTwitter])return;
    [OAToken removeFromUserDefaultsWithServiceProviderName:nil prefix:twitterSaveKey];
    if(sharedTwitter){
        [sharedTwitter release];
        sharedTwitter=nil;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)requestFinished:(UserRequest*)request didReceivedTwitterUser:(User*)user{
    if(twitterUser)[twitterUser release];
    twitterUser=[user retain];
    [BRFunctions saveAccounts];
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
    [BRFunctions loadAccounts];
}
+(FacebookUser*)facebookUser{
    return facebookUser;
}
+(void)requestFinished:(UserRequest*)request didReceivedFacebookUser:(FacebookUser*)user{
    if(facebookUser)[facebookUser release];
    facebookUser=[user retain];
    [BRFunctions saveAccounts];
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
		sharedInstagram.scope=@"likes+comments+relationships";
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
    [BRFunctions loadAccounts];
}
+(User*)instagramUser{
    return instagramUser;
}
+(void)requestFinished:(UserRequest*)request didReceivedInstagramUser:(User*)user{
    if(instagramUser)[instagramUser release];
    instagramUser=[user retain];
    [BRFunctions saveAccounts];
}

+(BOOL)didLoggedInInstagram{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults objectForKey:instagramSaveKey]){
		return YES;
	}
	return NO;
}
+(void)logoutInstagram{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:instagramSaveKey];
    [defaults synchronize];
	
	if(sharedInstagram){
        [sharedInstagram release];
        sharedInstagram=nil;
	}
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
+(void)logoutFlickr{
    if(sharedFlickr){
        [sharedFlickr release];
        sharedFlickr=nil;
    }
    [OAToken removeFromUserDefaultsWithServiceProviderName:nil prefix:flickrSaveKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
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
    [BRFunctions loadAccounts];
}
+(NSMutableArray*)tumblrUsers{
    return tumblrUsers;
}
+(BOOL)didLoggedInTumblr{
	OAToken *token=[[[OAToken alloc]initWithUserDefaultsUsingServiceProviderName:nil prefix:tumblrSaveKey]autorelease];
	if(token){
		return YES;
	}
	return NO;
}
+(void)logoutTumblr{
    if(sharedTumblr){
        [sharedTumblr release];
        sharedTumblr=nil;
    }
    [OAToken removeFromUserDefaultsWithServiceProviderName:nil prefix:tumblrSaveKey];
}
+(void)requestFinished:(UserRequest*)request didReceivedTumblrUsers:(NSMutableArray*)users{
    if(tumblrUsers){
        [tumblrUsers release];
        tumblrUsers=nil;
    }
    tumblrUsers=[users retain];
    [BRFunctions saveAccounts];
}
#pragma mark - accounts
+(void)loadAccounts{
    NSDictionary *savedAccounts=[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
    if([savedAccounts objectForKey:[Status sourceName:StatusSourceTypeTwitter]]){
        if(twitterUser)[twitterUser release];
        twitterUser=[[User userWithDictionary:[savedAccounts objectForKey:[Status sourceName:StatusSourceTypeTwitter]]] retain];
    }
    if([savedAccounts objectForKey:[Status sourceName:StatusSourceTypeFacebook]]){
        if(facebookUser)[facebookUser release];
        facebookUser=(FacebookUser*)[[FacebookUser userWithDictionary:[savedAccounts objectForKey:[Status sourceName:StatusSourceTypeFacebook]]] retain];
    }
    if([savedAccounts objectForKey:[Status sourceName:StatusSourceTypeInstagram]]){
        if(instagramUser)[instagramUser release];
        instagramUser=[[User userWithDictionary:[savedAccounts objectForKey:[Status sourceName:StatusSourceTypeInstagram]]] retain];
    }
    if([savedAccounts objectForKey:[Status sourceName:StatusSourceTypeTumblr]]){
        if(tumblrUsers)[tumblrUsers release];
        tumblrUsers=[[NSMutableArray alloc]init];
        for(NSDictionary *thisDict in [savedAccounts objectForKey:[Status sourceName:StatusSourceTypeTumblr]]){
            [(NSMutableArray*)tumblrUsers addObject:[TumblrUser userWithDictionary:thisDict]];
        }
    }
    
    
    if([BRFunctions didLoggedInTwitter]&&!twitterUser){
        UserRequest *request=[[[UserRequest alloc] init]autorelease];
        request.type=StatusSourceTypeTwitter;
        request.delegate=self;
        request.selector=@selector(requestFinished:didReceivedTwitterUser:);
        request.userID=@"self";
        [[StatusFetcher sharedFetcher] getUserForRequest:request];
    }
    if([BRFunctions isFacebookLoggedIn:NO]&&!facebookUser){
        UserRequest *request=[[[UserRequest alloc] init]autorelease];
        request.type=StatusSourceTypeFacebook;
        request.delegate=[self class];
        request.selector=@selector(requestFinished:didReceivedFacebookUser:);
        request.userID=@"me";
        [[StatusFetcher sharedFetcher] getUserForRequest:request];
    }
    if([BRFunctions didLoggedInInstagram]&&!instagramUser){
        UserRequest *request=[[[UserRequest alloc] init]autorelease];
        request.type=StatusSourceTypeInstagram;
        request.delegate=[self class];
        request.selector=@selector(requestFinished:didReceivedInstagramUser:);
        request.userID=@"self";
        [[StatusFetcher sharedFetcher] getUserForRequest:request];
    }
    if([BRFunctions didLoggedInTumblr]&&!tumblrUsers){
        UserRequest *request=[[[UserRequest alloc] init]autorelease];
        request.type=StatusSourceTypeTumblr;
        request.delegate=self;
        request.selector=@selector(requestFinished:didReceivedTumblrUsers:);
        request.userID=@"self";
        [[StatusFetcher sharedFetcher] getUserForRequest:request];
    }
}
+(void)saveAccounts{
    NSMutableDictionary *accounts=[NSMutableDictionary dictionary];
    if(twitterUser)[accounts setObject:[twitterUser dictionaryRepresentation] forKey:[Status sourceName:StatusSourceTypeTwitter]];
    if(facebookUser)[accounts setObject:[facebookUser dictionaryRepresentation] forKey:[Status sourceName:StatusSourceTypeFacebook]];
    if(instagramUser)[accounts setObject:[instagramUser dictionaryRepresentation] forKey:[Status sourceName:StatusSourceTypeInstagram]];
    if(tumblrUsers){
        NSMutableArray *tumblrDicts=[NSMutableArray array];
        for(TumblrUser *thisUser in tumblrUsers){
            [tumblrDicts addObject:[thisUser dictionaryRepresentation]];
        }
        [accounts setObject:tumblrDicts forKey:[Status sourceName:StatusSourceTypeTumblr]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:accounts forKey:@"accounts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - utils
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

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
#import <AudioToolbox/AudioToolbox.h>
#import "TimelineManager.h"
#import "UIApplication+Frame.h"

@interface BRFunctions ()

+(void)requestFinished:(UserRequest*)request didReceivedTwitterUser:(User*)user;
+(void)requestFinished:(UserRequest*)request didReceivedFacebookUser:(User*)user;
+(void)requestFinished:(UserRequest*)request didReceivedInstagramUser:(User*)user;
+(void)requestFinished:(UserRequest*)request didReceivedTumblrUsers:(NSMutableArray*)users;

@end

@implementation BRFunctions

static BRTwitterEngine *sharedTwitter=nil;
static User *twitterUser=nil;
static ACAccount *sharedFacebookAccount=nil;
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
    if(twitterUser){
        [twitterUser release];
        twitterUser=nil;
    }
    [BRFunctions saveAccounts];
    [[TimelineManager sharedManager]removeAllStatusWithSource:StatusSourceTypeTwitter];
}
+(void)requestFinished:(UserRequest*)request didReceivedTwitterUser:(User*)user{
    if(twitterUser)[twitterUser release];
    twitterUser=[user retain];
    [BRFunctions saveAccounts];
}
#pragma mark -
#pragma mark Facebook
+ (ACAccountStore *)sharedAccountStore {
    static ACAccountStore *store = nil;
    if (!store) {
        store = [[ACAccountStore alloc] init];
    }
    return store;
}
+ (ACAccountType *)sharedFacebookType {
    static ACAccountType *type = nil;
    if (!type) {
        type = [[[BRFunctions sharedAccountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] retain];
    }
    return type;
}
+ (ACAccount *)sharedFacebookAccount {
    if (!sharedFacebookAccount) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *identifier = [defaults objectForKey:@"currentFacebookUserIdentifier"];
        if (!identifier) return nil;
        sharedFacebookAccount = [[[BRFunctions sharedAccountStore] accountWithIdentifier:identifier] retain];
    }
    return sharedFacebookAccount;
}

//+(Facebook*)sharedFacebook{
//	if(!sharedFacebook){
//		sharedFacebook=[[Facebook alloc] initWithAppId:kFacebookAppID];
//		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//		if ([defaults objectForKey:@"FBAccessTokenKey"]
//			&& [defaults objectForKey:@"FBExpirationDateKey"]) {
//			sharedFacebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
//			sharedFacebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
//		}
//	}
//	return sharedFacebook;
//}

+(void)setFacebookCurrentUserID:(NSString*)userID{
	[[NSUserDefaults	 standardUserDefaults] setObject:userID forKey:@"currentFacebookUserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString*)facebookCurrentUserID{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"currentFacebookUserId"];
}
+(BOOL)isFacebookLoggedIn {
    BOOL loggedIn = [BRFunctions sharedFacebookType].accessGranted;
    if (!loggedIn) return NO;
    NSArray *accounts = [[BRFunctions sharedAccountStore] accountsWithAccountType:[BRFunctions sharedFacebookType]];
    if (!accounts.count) return NO;
    return [BRFunctions sharedFacebookAccount] != nil;
}

+(void)requestFinished:(UserRequest*)request didReceivedFacebookUser:(FacebookUser*)user{
    if(facebookUser)[facebookUser release];
    facebookUser=[user retain];
    [BRFunctions saveAccounts];
}

+(FacebookUser*)facebookUser {
    return facebookUser;
}

+(void)logoutFacebook{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"currentFacebookUserIdentifier"];
    [defaults synchronize];
    if (sharedFacebookAccount) {
        [sharedFacebookAccount release];
        sharedFacebookAccount = nil;
    }
    if(facebookUser){
        [facebookUser release];
        facebookUser=nil;
    }
    [self saveAccounts];
    [[TimelineManager sharedManager]removeAllStatusWithSource:StatusSourceTypeFacebook];
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
    if(instagramUser){
        [instagramUser release];
        instagramUser=nil;
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
    
	if(sharedInstagram){
        [sharedInstagram release];
        sharedInstagram=nil;
	}
    if(instagramUser){
        [instagramUser release];
        instagramUser=nil;
    }
    [BRFunctions saveAccounts];
    [[TimelineManager sharedManager]removeAllStatusWithSource:StatusSourceTypeInstagram];
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
    [BRFunctions saveAccounts];
    [[TimelineManager sharedManager]removeAllStatusWithSource:StatusSourceTypeFlickr];
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
    if(tumblrUsers){
        [tumblrUsers release];
        tumblrUsers=nil;
    }
    [OAToken removeFromUserDefaultsWithServiceProviderName:nil prefix:tumblrSaveKey];
    [BRFunctions saveAccounts];
    [[TimelineManager sharedManager]removeAllStatusWithSource:StatusSourceTypeTumblr];
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
    if(savedAccounts[[Status sourceName:StatusSourceTypeTwitter]]){
        if(twitterUser)[twitterUser release];
        twitterUser=[[User userWithDictionary:savedAccounts[[Status sourceName:StatusSourceTypeTwitter]]] retain];
    }
    if(savedAccounts[[Status sourceName:StatusSourceTypeFacebook]]){
        if(facebookUser)[facebookUser release];
        facebookUser=(FacebookUser*)[[FacebookUser userWithDictionary:savedAccounts[[Status sourceName:StatusSourceTypeFacebook]]] retain];
    }
    if(savedAccounts[[Status sourceName:StatusSourceTypeInstagram]]){
        if(instagramUser)[instagramUser release];
        instagramUser=[[User userWithDictionary:savedAccounts[[Status sourceName:StatusSourceTypeInstagram]]] retain];
    }
    if(savedAccounts[[Status sourceName:StatusSourceTypeTumblr]]){
        if(tumblrUsers)[tumblrUsers release];
        tumblrUsers=[[NSMutableArray alloc]init];
        for(NSDictionary *thisDict in savedAccounts[[Status sourceName:StatusSourceTypeTumblr]]){
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
    if([BRFunctions isFacebookLoggedIn]&&!facebookUser){
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
    if(twitterUser)accounts[[Status sourceName:StatusSourceTypeTwitter]] = [twitterUser dictionaryRepresentation];
    if(facebookUser)accounts[[Status sourceName:StatusSourceTypeFacebook]] = [facebookUser dictionaryRepresentation];
    if(instagramUser)accounts[[Status sourceName:StatusSourceTypeInstagram]] = [instagramUser dictionaryRepresentation];
    if(tumblrUsers){
        NSMutableArray *tumblrDicts=[NSMutableArray array];
        for(TumblrUser *thisUser in tumblrUsers){
            [tumblrDicts addObject:[thisUser dictionaryRepresentation]];
        }
        accounts[[Status sourceName:StatusSourceTypeTumblr]] = tumblrDicts;
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
+ (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}

+(void)playSound:(NSString*)filename{
    SystemSoundID audioEffect;
    NSString *path=[[NSBundle mainBundle] pathForResource:filename ofType:@"aiff"];
    /*
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR(path), CFSTR("caf"), NULL);
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundId);
    AudioServicesPlaySystemSound(soundId);
    CFRelease(soundFileURLRef);*/
    if(!path)return;
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
}

+(int)gridViewNumOfRow{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])){
            return 1;
        }
        return 3;
    }else{
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])){
            return 2;
        }else{
            return 5;
        }
    }
    return 3;
}
+(CGSize)gridViewCellMargin{
    float numOfFloat=3;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        numOfFloat=5;
    }
    UIEdgeInsets contentIndent=[BRFunctions gridViewIndent];
    float margin=([UIApplication currentFrame].size.height-contentIndent.top-contentIndent.bottom)/(([BRFunctions gridViewCellToMarginRatio]+1)*numOfFloat-1);
    return CGSizeMake(margin, margin);
}
+(UIEdgeInsets)gridViewIndent{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
+(float)gridViewCellToMarginRatio{
    return 3;
}
+(CGSize)gridViewCellSize{
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])){
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
            CGRect appFrame=[UIApplication currentFrame];
            UIEdgeInsets indent=[BRFunctions gridViewIndent];
            float height=appFrame.size.height-indent.bottom-indent.top;
            return CGSizeMake(height, height);
        }else{
            CGRect appFrame=[UIApplication currentFrame];
            UIEdgeInsets indent=[BRFunctions gridViewIndent];
            float height=appFrame.size.height-indent.bottom-indent.top;
            CGSize margin=[BRFunctions gridViewCellMargin];
            height=(height+margin.height)/[BRFunctions gridViewNumOfRow]-margin.height;
            return CGSizeMake(height, height);
        }
    }
    CGSize cellSize=[BRFunctions gridViewCellMargin];
    return CGSizeMake(cellSize.width*[BRFunctions gridViewCellToMarginRatio],cellSize.height*[BRFunctions gridViewCellToMarginRatio]);
}
@end

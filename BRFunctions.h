//
//  BRFunctions.h
//  perSecond
//
//  Created by b123400 on 01/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "BRTwitterEngine.h"
#import "BRInstagramEngine.h"
#import "BRFlickrEngine.h"
#import "BRTumblrEngine.h"
#import "OAToken.h"
#import "User.h"
#import "FacebookUser.h"

#define kTwitterOAuthConsumerKey				@"lGuUouxoENJfJDKD29FOA"		//REPLACE ME
#define kTwitterOAuthConsumerSecret			@"Cw76i2Jl7A12soeeQCIDRNpNSmGJvMj9eRS5kOmUA"		//REPLACE ME
#define twitterSaveKey @"TwitterAccessToken"

#define kFacebookAppID @"111015292318563"
//#define facebookDidLoginNotification @"facebookDidLoginNotification"
//#define facebookDidNotLoginNotification @"facebookDidNotLoginNotification"

#define instagramClientID @"3a39c9aafa4146f8a06a688cb8a9781a"
#define instagramClientSecret @"63bc6321512248e1b8b1f534697648f3"
#define instagramSaveKey @"InstagramAccessToken"

#define flickrAPIKey @"182dd3c0af69e52efeafc5b1feae067b"
#define flickrAPISecret @"790cd5fd5dfcf00b"
#define flickrSaveKey @"FlickrAccessToken"

#define tumblrAPIKey  @"nDOanl11l1dwQ6YNv7URb9m6K2UD1afQImoX28SeOLIXJaT7kX"
#define tumblrAPISecret  @"rAHBEhunBoJO2rKuHQzvAaNKkGsFETOPx6hsoYTI3cgbmGKsXi"
#define tumblrSaveKey @"TumblrAccessToken"

#define refreshIntervalKey @"refreshIntervalKey"

@interface BRFunctions : NSObject {
	
}

+(BRTwitterEngine*)sharedTwitter;
+(void)saveTwitterToken:(OAToken*)token;
+(BOOL)didLoggedInTwitter;
+(User*)twitterUser;
+(void)logoutTwitter;

+ (ACAccountType *)sharedFacebookType;
+ (ACAccountStore *)sharedAccountStore;
+ (ACAccount *)sharedFacebookAccount;

+(NSString*)facebookCurrentUserID;
+(FacebookUser*)facebookUser;
+(void)setFacebookCurrentUserID:(NSString*)userID;
+(BOOL)isFacebookLoggedIn;
+(void)logoutFacebook;

+(BRInstagramEngine*)sharedInstagram;
+(void)saveInstagramToken:(NSString*)token;
+(User*)instagramUser;
+(BOOL)didLoggedInInstagram;
+(void)logoutInstagram;

+(BRFlickrEngine*)sharedFlickr;
+(void)saveFlickrToken:(OAToken*)token;
+(BOOL)didLoggedInFlickr;
+(void)logoutFlickr;

+(BRTumblrEngine*)sharedTumblr;
+(void)saveTumblrToken:(OAToken*)token;
+(NSMutableArray*)tumblrUsers;
+(BOOL)didLoggedInTumblr;
+(void)logoutTumblr;

+(void)saveAccounts;
+(void)loadAccounts;
+(void)saveAccounts;

+(BRFunctions*)sharedObject;

+(CGSize)screenSize;
+ (NSString *)applicationDocumentsDirectory;
+(dispatch_queue_t)imageQueue;
+(void)playSound:(NSString*)filename;

+(int)gridViewNumOfRow;
+(CGSize)gridViewCellMargin;
+(UIEdgeInsets)gridViewIndent;
+(float)gridViewCellToMarginRatio;
+(CGSize)gridViewCellSize;

@end

//
//  BRFlickrOAuthTokenGetter.h
//  perSecond
//
//  Created by b123400 on 07/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BROAuthTokenGetter.h"

@protocol BRFlickrOAuthTokenGetterDelegate <BROAuthTokenGetterDelegate>

@optional
-(void)didReceivedRequestTokenURL:(NSURL*)url;

@end

@interface BRFlickrOAuthTokenGetter : BROAuthTokenGetter {

}

-(void)getRequestToken;
-(void)getAccessTokenWithOauthToken:(NSString*)token verifier:(NSString*)verifier;

@end

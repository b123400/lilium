//
//  BRTumblrOAuthTokenGetter.h
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BROAuthTokenGetter.h"


@protocol BRTumblrOAuthTokenGetterDelegate <BROAuthTokenGetterDelegate>

@optional
-(void)didReceivedRequestTokenURL:(NSURL*)url;

@end


@interface BRTumblrOAuthTokenGetter : BROAuthTokenGetter {

}

-(void)getRequestToken;
-(void)getAccessTokenWithOauthToken:(NSString*)token verifier:(NSString*)verifier;

@end

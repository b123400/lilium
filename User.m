//
//  Account.m
//  perSecond
//
//  Created by b123400 Chan on 23/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize displayName,userID,type,profilePicture,username;

-(NSURL*)profilePicture{
    if(type==StatusSourceTypeFacebook){
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",self.userID]];
    }
    return profilePicture;
}

@end

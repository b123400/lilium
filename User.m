//
//  Account.m
//  perSecond
//
//  Created by b123400 Chan on 23/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "User.h"
#import "FacebookUser.h"
#import "TumblrUser.h"

@implementation User
@synthesize displayName,userID,type,profilePicture,username;

+(NSMutableArray*)allUsers{
    static NSMutableArray *allUsers;
    
    @synchronized(self)
    {
        if (!allUsers)
            allUsers = [[NSMutableArray alloc] init];
        
        return allUsers;
    }
}

-(id)init{
    [[User allUsers] addObject:self];
    return [super init];
}

+(User*)userWithType:(StatusSourceType)type userID:(NSString*)userID{
    return [User userWithType:type userID:userID autoCreate:YES];
}
+(User*)userWithType:(StatusSourceType)type userID:(NSString*)userID autoCreate:(BOOL)autoCreate{
    NSMutableArray *allUsers=[User allUsers];
    for(User *thisUser in allUsers){
        if(thisUser.type==type&&[thisUser.userID isEqualToString:userID]){
            return thisUser;
        }
    }
    if(!autoCreate)return nil;
    
    User *newUser=nil;
    if(type==StatusSourceTypeFacebook){
        newUser=[[[FacebookUser alloc]init]autorelease];
    }else if(type==StatusSourceTypeTumblr){
        newUser=[[[TumblrUser alloc]init]autorelease];
    }else{
        newUser=[[[User alloc] init] autorelease];
    }
    
    newUser.type=type;
    newUser.userID=userID;
    return newUser;
}

@end

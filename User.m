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
#import "Status.h"
#import "StatusFetcher.h"
#import "RelationshipRequest.h"

@interface User ()

-(void)requestFinished:(RelationshipRequest*)request withRelationship:(UserRelationship)_relationship;
-(void)followRequestFinished:(RelationshipRequest*)request;

@end

@implementation User
@synthesize displayName,userID,type,profilePicture,username,relationship;

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

-(NSArray*)statuses{
    NSArray *allStatuses=[[StatusFetcher sharedFetcher] allStatuses];
    NSMutableArray *statuses=[NSMutableArray array];
    for(Status *thisStatus in allStatuses){
        if(thisStatus.user==self){
            [statuses addObject:thisStatus];
        }
    }
    return statuses;
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
+(User*)me{
    static User* me=nil;
    if(!me){
        me=[[User alloc] init];
    }
    me.displayName=@"me";
    return me;
}
-(NSString*)displayName{
    if(displayName)return displayName;
    if(username)return username;
    if(userID)return userID;
    return nil;
}
-(void)setRelationship:(UserRelationship)_relationship{
    [self setRelationship:_relationship sync:YES];
}
-(void)setRelationship:(UserRelationship)_relationship sync:(BOOL)sync{
    if(relationship!=_relationship){
        relationship=_relationship;
        if(sync&&(relationship==UserRelationshipFollowing||relationship==UserRelationshipNotFollowing)){
            RelationshipRequest *request=[[[RelationshipRequest alloc]init]autorelease];
            request.targetUser=self;
            request.targetRelationship=relationship;
            request.delegate=self;
            request.selector=@selector(followRequestFinished:);
            [[StatusFetcher sharedFetcher]followsUser:request];
        }
    }
}
#pragma mark -
-(void)getRelationshipAndReturnTo:(id)target withSelector:(SEL)selector{
    RelationshipRequest *request=[[[RelationshipRequest alloc] init]autorelease];
    request.targetUser=self;
    request.delegate=target;
    request.selector=selector;
    [[StatusFetcher sharedFetcher] getUserRelationship:request];
}
-(void)requestFinished:(RelationshipRequest*)request withRelationship:(UserRelationship)_relationship{
    [self setRelationship:_relationship sync:NO];
}
-(void)followRequestFinished:(RelationshipRequest*)request{
    
}
#pragma mark -
+(User*)userWithDictionary:(NSDictionary*)dict{
    StatusSourceType type=[[dict objectForKey:@"type"] intValue];
    User *thisUser=[User userWithType:type userID:[dict objectForKey:@"userID"]];
    thisUser.displayName=[dict objectForKey:@"displayName"];
    thisUser.username=[dict objectForKey:@"username"];
    if([dict objectForKey:@"profilePicture"])thisUser.profilePicture=[NSURL URLWithString:[dict objectForKey:@"profilePicture"]];
    return thisUser;
}
-(NSMutableDictionary*)dictionaryRepresentation{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if(self.displayName)[dict setObject:self.displayName forKey:@"displayName"];
    if(self.userID)[dict setObject:self.userID forKey:@"userID"];
    if(self.username)[dict setObject:self.username forKey:@"username"];
    if(self.profilePicture)[dict setObject:self.profilePicture.absoluteString forKey:@"profilePicture"];
    [dict setObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    return dict;
}

@end

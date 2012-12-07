//
//  FacebookUser.m
//  perSecond
//
//  Created by b123400 on 8/12/12.
//
//

#import "FacebookUser.h"

@implementation FacebookUser

+(FacebookUser*)userWithUserID:(NSString*)userID{
    return [FacebookUser userWithUserID:userID autoCreate:YES];
}
+(FacebookUser*)userWithUserID:(NSString*)userID autoCreate:(BOOL)autoCreate{
    User *cachedUser=[super userWithType:StatusSourceTypeTumblr userID:userID autoCreate:NO];
    if(cachedUser&&[cachedUser isKindOfClass:[FacebookUser class]]){
        return (FacebookUser*)cachedUser;
    }
    if(autoCreate){
        return [[[FacebookUser alloc]init]autorelease];
    }
    return nil;
}

-(NSURL*)profilePicture{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",self.userID]];
}


@end

//
//  TumblrUser.m
//  perSecond
//
//  Created by b123400 on 8/12/12.
//
//

#import "TumblrUser.h"

@implementation TumblrUser

+(TumblrUser*)userWithUserID:(NSString*)userID{
    return [TumblrUser userWithUserID:userID autoCreate:YES];
}
+(TumblrUser*)userWithUserID:(NSString*)userID autoCreate:(BOOL)autoCreate{
    User *cachedUser=[super userWithType:StatusSourceTypeTumblr userID:userID autoCreate:NO];
    if(cachedUser&&[cachedUser isKindOfClass:[TumblrUser class]]){
        return (TumblrUser*)cachedUser;
    }
    if(autoCreate){
        TumblrUser *newUser=[[[TumblrUser alloc]init]autorelease];
        newUser.type=StatusSourceTypeTumblr;
        newUser.userID=userID;
        return newUser;
    }
    return nil;
}

+(TumblrUser*)userWithBlogName:(NSString*)blogName anyUrl:(NSString*)urlString{
    NSString *uniqueUsername=blogName;
    NSString *baseURLString=[urlString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    baseURLString=[baseURLString substringToIndex:[baseURLString rangeOfString:@"/"].location];
    
    TumblrUser *cachedUser=[TumblrUser userWithUserID:baseURLString autoCreate:NO];
    if(cachedUser){
        return cachedUser;
    }
    TumblrUser *newUser=[[[TumblrUser alloc] init]autorelease];
    newUser.type=StatusSourceTypeTumblr;
    newUser.userID=baseURLString;
    newUser.username=uniqueUsername;
    newUser.displayName=uniqueUsername;
    return newUser;
}

-(NSURL*)profilePicture{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@/avatar/64",self.userID]];
}

@end

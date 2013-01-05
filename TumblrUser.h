//
//  TumblrUser.h
//  perSecond
//
//  Created by b123400 on 8/12/12.
//
//

#import "User.h"

@interface TumblrUser : User

//username=blog base-hostname, e.g. b123400.tumblr.com
//userID and display name: b123400

+(TumblrUser*)userWithUserID:(NSString*)userID;
+(TumblrUser*)userWithUserID:(NSString*)userID autoCreate:(BOOL)autoCreate;
+(TumblrUser*)userWithBlogName:(NSString*)blogName anyUrl:(NSString*)urlString;

+(TumblrUser*)userWithDictionary:(NSDictionary*)dict;

@end

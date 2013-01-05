//
//  FacebookUser.h
//  perSecond
//
//  Created by b123400 on 8/12/12.
//
//

#import "User.h"

@interface FacebookUser : User

+(FacebookUser*)userWithUserID:(NSString*)userID;
+(FacebookUser*)userWithUserID:(NSString*)userID autoCreate:(BOOL)autoCreate;

+(FacebookUser*)userWithDictionary:(NSDictionary*)dict;

@end

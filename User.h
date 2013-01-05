//
//  Account.h
//  perSecond
//
//  Created by b123400 Chan on 23/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum StatusSourceType {
    StatusSourceTypeTwitter       = 0,
    StatusSourceTypeFacebook   =1,
	StatusSourceTypeFlickr  = 2,
	StatusSourceTypeInstagram =3,
	StatusSourceTypeTumblr    =4,
} StatusSourceType;

@interface User : NSObject{
	NSString *displayName; //all sources didnt implement this well
	NSString *username;
	NSString *userID;
	NSURL *profilePicture;
	StatusSourceType type;
}
@property (nonatomic,retain) NSString *displayName;
@property (nonatomic,retain)NSString *username;
@property (nonatomic,retain)NSString *userID;
@property (nonatomic,retain)NSURL *profilePicture;
@property (nonatomic,assign) StatusSourceType type;
@property (nonatomic,readonly) NSArray *statuses;

+(NSMutableArray*)allUsers;
+(User*)userWithType:(StatusSourceType)type userID:(NSString*)userID;
+(User*)userWithType:(StatusSourceType)type userID:(NSString*)userID autoCreate:(BOOL)autoCreate;

+(User*)userWithDictionary:(NSDictionary*)dict;
-(NSDictionary*)dictionaryRepresentation;

@end

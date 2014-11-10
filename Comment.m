//
//  Comment.m
//  perSecond
//
//  Created by b123400 Chan on 23/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Comment.h"

@implementation Comment
@synthesize text,date,user;

+(Comment*)commentFromDictionary:(NSDictionary*)dictionary{
    Comment *newComment=[[[Comment alloc] init]autorelease];
    if(dictionary[@"text"])newComment.text=dictionary[@"text"];
    if(dictionary[@"user"])newComment.user=[User userWithDictionary:dictionary[@"user"]];
    if(dictionary[@"date"])newComment.date=dictionary[@"date"];
    return newComment;
}
-(NSDictionary*)dictionaryRepresentation{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if(text)dict[@"text"] = text;
    if(date)dict[@"date"] = date;
    if(user)dict[@"user"] = [user dictionaryRepresentation];
    return dict;
}

@end

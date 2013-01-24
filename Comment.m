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
    if([dictionary objectForKey:@"text"])newComment.text=[dictionary objectForKey:@"text"];
    if([dictionary objectForKey:@"user"])newComment.user=[User userWithDictionary:[dictionary objectForKey:@"user"]];
    if([dictionary objectForKey:@"date"])newComment.date=[dictionary objectForKey:@"date"];
    return newComment;
}
-(NSDictionary*)dictionaryRepresentation{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if(text)[dict setObject:text forKey:@"text"];
    if(date)[dict setObject:date forKey:@"date"];
    if(user)[dict setObject:[user dictionaryRepresentation] forKey:@"user"];
    return dict;
}

@end

//
//  Attribute.m
//  perSecond
//
//  Created by b123400 Chan on 21/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Attribute.h"

@implementation Attribute
@synthesize url,range;

-(instancetype)init{
    range=NSMakeRange(0, 0);
    return [super init];
}

+(Attribute*)attributeFromDictionary:(NSDictionary*)dict{
    Attribute *newAttribute=[[[Attribute alloc]init]autorelease];
    if(dict[@"url"])newAttribute.url=[NSURL URLWithString:dict[@"url"]];
    newAttribute.range=NSMakeRange([dict[@"location"] integerValue], [dict[@"length"]integerValue]);
    return newAttribute;
}
-(NSDictionary*)dictionaryRepresentation{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if(url)dict[@"url"] = [url absoluteString];
    dict[@"length"] = [NSNumber numberWithInt:range.length];
    dict[@"location"] = [NSNumber numberWithInt:range.location];
    return dict;
}

@end

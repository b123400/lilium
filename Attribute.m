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

-(id)init{
    range=NSMakeRange(0, 0);
    return [super init];
}

+(Attribute*)attributeFromDictionary:(NSDictionary*)dict{
    Attribute *newAttribute=[[[Attribute alloc]init]autorelease];
    if([dict objectForKey:@"url"])newAttribute.url=[NSURL URLWithString:[dict objectForKey:@"url"]];
    newAttribute.range=NSMakeRange([[dict objectForKey:@"location"] integerValue], [[dict objectForKey:@"length"]integerValue]);
    return newAttribute;
}
-(NSDictionary*)dictionaryRepresentation{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if(url)[dict setObject:[url absoluteString] forKey:@"url"];
    [dict setObject:[NSNumber numberWithInt:range.length] forKey:@"length"];
    [dict setObject:[NSNumber numberWithInt:range.location] forKey:@"location"];
    return dict;
}

@end

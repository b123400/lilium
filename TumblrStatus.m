//
//  TumblrStatus.m
//  perSecond
//
//  Created by b123400 on 3/1/13.
//
//

#import "TumblrStatus.h"

@implementation TumblrStatus
@synthesize reblogKey;

-(NSMutableDictionary*)dictionaryRepresentation{
    NSMutableDictionary *dict=[super dictionaryRepresentation];
    dict[@"reblogKey"] = reblogKey;
    return dict;
}

@end

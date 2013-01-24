//
//  Choice.m
//  perSecond
//
//  Created by b123400 on 15/1/13.
//
//

#import "Choice.h"

@implementation Choice
@synthesize action,detailText,text;

+(Choice*)choiceWithText:(NSString*)text action:(void (^)())action{
    return [Choice choiceWithText:text detailText:nil action:action];
}
+(Choice*)choiceWithText:(NSString*)text detailText:(NSString*)detailText action:(void (^)())_action{
    Choice *newChoice=[[[Choice alloc] init] autorelease];
    newChoice.action=_action;
    newChoice.text=text;
    newChoice.detailText=detailText;
    return newChoice;
}

@end

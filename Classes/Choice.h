//
//  Choice.h
//  perSecond
//
//  Created by b123400 on 15/1/13.
//
//

#import <Foundation/Foundation.h>

@interface Choice : NSObject{
    void (^action)();
    NSString *text;
    NSString *detailText;
}
@property (nonatomic,copy)    void (^action)();
@property (nonatomic,retain)    NSString *text;
@property (nonatomic,retain)    NSString *detailText;

+(Choice*)choiceWithText:(NSString*)text action:(void (^)())action;
+(Choice*)choiceWithText:(NSString*)text detailText:(NSString*)detailText action:(void (^)())action;

@end

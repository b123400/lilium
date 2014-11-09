//
//  BRCircleAlertButton.h
//  perSecond
//
//  Created by b123400 on 25/12/12.
//
//

#import <UIKit/UIKit.h>

@interface BRCircleAlertButton : UIButton{
    void (^action)(void);
    UIColor *color;
}
@property (nonatomic,copy) void (^action)(void);
@property (nonatomic,assign) UIColor *color;

+(BRCircleAlertButton*)buttonWithAction:(void (^) (void))_action;
+(BRCircleAlertButton*)buttonWithAction:(void (^) (void))_action color:(UIColor*)_color;

+(BRCircleAlertButton*)tickButtonWithAction:(void (^)(void))_action;
+(BRCircleAlertButton*)cancelButton;

@end

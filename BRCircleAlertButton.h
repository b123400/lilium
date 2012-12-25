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
}
@property (nonatomic,assign) void (^action)(void);

+(BRCircleAlertButton*)buttonWithAction:(void (^) (void))_action;

@end

//
//  BRCircleAlert.h
//  perSecond
//
//  Created by b123400 on 18/12/12.
//
//

#import <UIKit/UIKit.h>
#import "BRCircleAlertButton.h"

#define MIN_BUTTON_MARGIN   20
#define BUTTON_RADIUS       25
#define BUTTON_SPACING      10

@interface BRCircleAlert : UIView{
    NSString *text;
    UIColor *color;
    NSArray *buttons;
    
    float _radius;
    float _minimumTextWidth;
    float _verticalBlank;
    
    UITextView *textView;
}
@property (retain,nonatomic) NSString *text;
@property (retain,nonatomic) UIColor *color;
@property (retain,nonatomic) NSArray *buttons;

+(BRCircleAlert*)alertWithText:(NSString*)text color:(UIColor*)color buttons:(NSArray*)buttons;
- (id)initWithText:(NSString*)_text color:(UIColor*)_color buttons:(NSArray*)_buttons;

-(void)show;
-(void)dismiss;

@end

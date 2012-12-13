//
//  BRLoadingView.h
//  perSecond
//
//  Created by b123400 on 10/12/12.
//
//

#import <UIKit/UIKit.h>

@interface BRLoadingView : UIView{
    UIView *innerView;
}
@property (retain,nonatomic) UIColor *color;

-(void)startAnimation;
-(void)stopAnimation;

@end

//
//  TitleButton.h
//  perSecond
//
//  Created by b123400 on 26/1/13.
//
//

#import <UIKit/UIKit.h>

@protocol TitleButtonDelegate <NSObject>

-(void)titleButtonDidFinishedAnimation:(id)button;

@end

@interface TitleButton : UIView{
    UILabel *textLabel;
    UIImageView *backgroundImageView;
    
    id delegate;
}
@property (nonatomic,retain) UILabel *textLabel;
@property (nonatomic,retain) UIImageView *backgroundImageView;
@property (nonatomic,assign) id <TitleButtonDelegate> delegate;

-(void)setImageWithURL:(NSURL*)url;

-(void)startAnimation;

@end

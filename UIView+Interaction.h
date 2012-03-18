//
//  UIView+Interaction.h
//  perSecond
//
//  Created by b123400 on 14/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Interaction)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

-(BOOL)touchReactionEnabled;
-(void)setTouchReactionEnabled:(BOOL)enabled;

@end

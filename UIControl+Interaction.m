//
//  UIControl+Interaction.m
//  perSecond
//
//  Created by b123400 on 16/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "UIControl+Interaction.h"
#import "UIView+Interaction.h"

@implementation UIControl (Interaction)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
	[super touchesBegan:[NSSet setWithObject:touch] withEvent:event];
	return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
	[super touchesMoved:[NSSet setWithObject:touch] withEvent:event];
	return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
	[super touchesEnded:[NSSet setWithObject:touch] withEvent:event];
	//[super endTrackingWithTouch:touch withEvent:event];
}
- (void)cancelTrackingWithEvent:(UIEvent *)event{
	[super touchesCancelled:[NSSet set] withEvent:event];
	//[super cancelTrackingWithEvent:event];
}
#pragma clang diagnostic pop

@end

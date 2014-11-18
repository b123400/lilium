//
//  UIView+Interaction.m
//  perSecond
//
//  Created by b123400 on 14/07/2011.
//  Copyright 2011 home. All rights reserved.
//
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Interaction.h"
#import "BRFunctions.h"

static const char *reactionKey = "touchReaction";

@implementation UIView (Interaction)

-(void)buttonDragBegan:(id)sender withEvent:(UIEvent*)event{
	[self touchesBegan:[event touchesForView:self] withEvent:event];
}
-(void)buttonDragMoving:(id)sender withEvent:(UIEvent*)event{
	[self touchesMoved:[event touchesForView:self] withEvent:event];
}
-(void)buttonDragEnded:(id)sender withEvent:(UIEvent*)event{
	[self touchesEnded:[event touchesForView:self] withEvent:event];
}
-(void)buttonDragCancel:(id)sender withEvent:(UIEvent*)event{
	[self touchesCancelled:[event touchesForView:self] withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
	if(![touches count])return;
	if(![self touchReactionEnabled])return;
	
	UITouch *thisTouch=[touches allObjects][0];
	CGPoint touchPoint=[thisTouch locationInView:self];
	
	CGPoint percentagePoint=CGPointMake(touchPoint.x/self.frame.size.width, touchPoint.y/self.frame.size.height);
	
	CABasicAnimation *topAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	//topAnim.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.97 :0.15 :1.00 :1.00];
	topAnim.duration=0.15;
	topAnim.repeatCount=1;
	topAnim.fromValue= [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0, 0, 0, 0)];
	
	float rotatePercentageX=(percentagePoint.x-0.5);
	float rotatePercentageY=(percentagePoint.y-0.5);
	float f = M_PI/180;
	CATransform3D aTransform = CATransform3DMakeRotation(f, 0, 1, 0);
	aTransform.m14 = 1.0 / (6.875*self.frame.size.width-25.0)*rotatePercentageX;//1100 *rotatePercentageX;	
	aTransform.m24 = 1.0 / (6.875*self.frame.size.height-25.0)*rotatePercentageY;//1100 *rotatePercentageY;
	aTransform.m34 = 1.0 / -1000 *rotatePercentageX;
	aTransform.m44 = 0.98+(0.3 * (0.5-fabs(rotatePercentageX))*(0.5-fabs(rotatePercentageY)));
	topAnim.toValue=[NSValue valueWithCATransform3D:aTransform];
	topAnim.removedOnCompletion = FALSE;
	topAnim.fillMode=kCAFillModeForwards;
	
	CGPoint origin=self.frame.origin;
	origin.x+=(1-percentagePoint.x)*self.frame.size.width;
	origin.y+=(1-percentagePoint.y)*self.frame.size.height;
	self.center=origin;
	
	self.layer.anchorPoint = CGPointMake(1-percentagePoint.x,1-percentagePoint.y);
	
	[self.layer addAnimation:topAnim forKey:@"interaction-transform"];
	
	self.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
	//self.layer.zPosition=10000;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesMoved:touches withEvent:event];
	[self.layer removeAnimationForKey:@"interaction-transform"];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	[self.layer removeAnimationForKey:@"interaction-transform"];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesCancelled:touches withEvent:event];
	[self.layer removeAnimationForKey:@"interaction-transform"];
}


-(BOOL)touchReactionEnabled{
	NSNumber *enabled=objc_getAssociatedObject(self, reactionKey);
	if(!enabled){
		return [self isKindOfClass:[UIButton class]];
	}
	return [enabled boolValue];
}
-(void)setTouchReactionEnabled:(BOOL)enabled{
	objc_setAssociatedObject(self, reactionKey, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

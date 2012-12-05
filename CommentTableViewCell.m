//
//  CommentTableViewCell.m
//  perSecond
//
//  Created by b123400 Chan on 24/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell
@synthesize comment,profileImage;

- (void)drawContentView:(CGRect)r
{
	CGContextRef context    = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, r);
	
	self.profileImage=[[SDWebImageManager sharedManager] imageWithURL:comment.user.profilePicture];
	if(self.profileImage){
		[self.profileImage drawInRect:CGRectMake(15, 29, 29, 29)];
	}else{
		[[SDWebImageManager sharedManager] downloadWithURL:comment.user.profilePicture delegate:self];
	}
	
	UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(53, 44)];
	[path addLineToPoint:CGPointMake(58, 39)];
	[path addLineToPoint:CGPointMake(58, 24)];
	[path addLineToPoint:CGPointMake(r.size.width-21, 24)];
	[path addLineToPoint:CGPointMake(r.size.width-21, r.size.height-7)];
	[path addLineToPoint:CGPointMake(58, r.size.height-7)];
	[path addLineToPoint:CGPointMake(58, 49)];
    [path closePath];
    [[UIColor colorWithRed:72/255.0 green:124/255.0 blue:204/255.0 alpha:1.0] set];
    [path fill];
	
	[[UIColor whiteColor] set];
	[comment.text drawInRect:CGRectMake(68, 34, r.size.width-99, r.size.height-64) withFont:[UIFont fontWithName:@"Arial" size:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	[comment.user.displayName drawInRect:CGRectMake(68, r.size.height-28, r.size.width-156, 16) withFont:[UIFont fontWithName:@"Arial" size:12]];
	
	UIGraphicsEndImageContext();
    // subclasses should implement this
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image{
	self.profileImage=image;
	[self setNeedsDisplay];
}
-(void)setComment:(Comment *)_comment{
    if(comment)[comment release];
    comment=[_comment retain];
    [self setNeedsDisplay];
}
@end

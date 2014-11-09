//
//  SquareCell.m
//  perSecond
//
//  Created by b123400 on 03/08/2011.
//  Copyright 2011 home. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SquareCell.h"
#import "BRFunctions.h"
#import "UIImage+averageColor.h"
#import "UIColor-Expanded.h"
#import "UIImage-Tint.h"

@implementation SquareCell
@synthesize imageURL,captionLabel,status;

-(id)initWithReuseIdentifier:(NSString*)identifier{
	self=[super initWithReuseIdentifier:identifier];
	self.clipsToBounds=YES;
	imageView=[[OLImageView alloc]init];
	[self addSubview:imageView];
	
	coverView=[[UIImageView alloc]init];
	coverView.image=[UIImage imageNamed:@"imageCoverAlpha.png"];
	coverView.backgroundColor=[UIColor clearColor];
	[self addSubview:coverView];
	
	captionView=[[UIView alloc]init];
	captionView.backgroundColor=[UIColor clearColor];
	[self addSubview:captionView];
	
	captionImageView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"imageCoverCaption.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 60, 0, 0)]];
	captionImageView.backgroundColor=[UIColor clearColor];
	[captionView addSubview:captionImageView];
	
	captionLabel=[[UILabel alloc]init];
	captionLabel.textColor=[UIColor whiteColor];
	captionLabel.text=@"test test test";
	captionLabel.backgroundColor=[UIColor clearColor];
	captionLabel.adjustsFontSizeToFitWidth=NO;
	[captionView addSubview:captionLabel];
	
	imageView.userInteractionEnabled=coverView.userInteractionEnabled=captionView.userInteractionEnabled=captionImageView.userInteractionEnabled=captionLabel.userInteractionEnabled=NO;
	
	return self;
}
-(void)drawRect:(CGRect)rect{
	CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
	if(displayImage){
		/*CGRect imageRect=rect;
		imageRect.origin.x-=(displayImage.size.width-imageRect.size.width)/2;
		 imageRect.origin.y-=(displayImage.size.height-imageRect.size.height)/2;
		 imageRect.size.width=displayImage.size.width;
		 imageRect.size.height=displayImage.size.height;
		
		if(displayImage.size.width>displayImage.size.height){
			float compression=rect.size.height/displayImage.size.height;
			imageRect.size.width=displayImage.size.width*compression;
			
			imageRect.origin.x-=(imageRect.size.width-imageRect.size.height)/2;
		}else{
			float compression=rect.size.width/displayImage.size.width;
			imageRect.size.height=displayImage.size.height*compression;
			
			imageRect.origin.y-=(imageRect.size.height-imageRect.size.width)/2;
		}
		[displayImage drawInRect:imageRect];*/
		
		captionView.hidden=NO;
		imageView.hidden=NO;
		
		imageView.image=displayImage;
		
		CGRect imageViewFrame=CGRectInset(rect, -20, -20);
		if(displayImage.size.width<displayImage.size.height){
			imageViewFrame.size.height=(imageViewFrame.size.width/displayImage.size.width)*displayImage.size.height;
			imageViewFrame.origin.y=(imageViewFrame.size.height-self.frame.size.height)/-2;
		}
		imageView.frame=imageViewFrame;
		
		imageView.contentMode=UIViewContentModeScaleAspectFill;
		imageView.clipsToBounds=YES;
		
		if(status.caption&&![status.caption isEqualToString:@""]){
			UIColor *captionColor=nil;
			if(status){
				captionColor=status.captionColor;
			}
			if(!captionColor){
				//Detect brightness
				coverView.layer.opacity=0;
				captionView.layer.opacity=0;
				
				UIGraphicsBeginImageContextWithOptions(imageView.frame.size, YES, 0);
				[imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
				//UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();

				CGImageRef imageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
				imageRef=CGImageCreateWithImageInRect(imageRef, [captionView.superview convertRect:captionView.frame toView:imageView]);
				
				UIImage *viewImage = [UIImage imageWithCGImage:imageRef];
				CGImageRelease(imageRef);
				
				UIColor *averageColor=[viewImage getDominantColor];
				
				
				imageView.image=displayImage;
				
				UIGraphicsEndImageContext();
				
				captionView.layer.opacity=1;
				
				captionColor=averageColor;
				status.captionColor=averageColor;
			}
			float brightness = [captionColor red] * 0.3 + [captionColor green]* 0.59 + [captionColor blue] * 0.11;
			if(brightness<0.7){
				float dimAlpha=brightness*0.1847+0.123;
				coverView.backgroundColor=[UIColor clearColor];
				coverView.layer.opacity=dimAlpha;
				
				captionLabel.frame=CGRectMake(-5, 0, self.frame.size.width+60, 30);
				captionLabel.font=[UIFont boldSystemFontOfSize:30];
                //captionLabel.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:30];
				
				captionImageView.hidden=YES;
			}else{
				coverView.backgroundColor=[UIColor blackColor];
				coverView.layer.opacity=0.05;
				
				captionLabel.frame=CGRectMake(38, 7, self.frame.size.width+60, 20);
				captionLabel.font=[UIFont boldSystemFontOfSize:18];
                //captionLabel.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:18];
				
				captionImageView.hidden=NO;
				captionImageView.image=[[captionImageView.image tintedImageUsingColor:[captionColor inverseColor]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
                
				
				CGRect imageFrame=captionView.frame;
				imageFrame.origin.y+=imageFrame.size.height;
				captionView.frame=imageFrame;
				
				if(timer){
					[timer release];
				}
				timer=[[NSTimer scheduledTimerWithTimeInterval:3.5+1*((arc4random()%100)/100.0) target:self selector:@selector(pullUpCaption:) userInfo:nil repeats:NO] retain];
			}
		}else{
			captionImageView.hidden=YES;
			captionLabel.text=status.caption;
			coverView.backgroundColor=[UIColor blackColor];
			coverView.layer.opacity=0.05;
		}
	}
	if(!displayImage||!imageURL){
		imageView.hidden=YES;
		captionView.hidden=YES;
	}
}
-(void)didMoveToWindow{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
	if(self.window){
		if(imageURL){
			[[SDWebImageManager sharedManager] downloadWithURL:imageURL delegate:self];
		}
	}else{
		//self.imageURL=nil;
		if(displayImage){
			[displayImage release];
			displayImage=nil;
		}
		if(timer&&[timer isValid]){
			[timer invalidate];
		}
	}
	[self setNeedsDisplay];
	[super didMoveToWindow];
}
-(void)setFrame:(CGRect)rect{
	[super setFrame:rect];
	captionView.frame=CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 30);
	captionImageView.frame=CGRectMake(0, 0, captionView.frame.size.width, captionView.frame.size.height);
	coverView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[super setFrame:rect];
}
#pragma mark caption animation
-(void)pullUpCaption:(NSTimer*)_timer{
	
	CGRect captionFrame=captionView.frame;
	
	CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
	positionAnimation.removedOnCompletion=YES;
	positionAnimation.duration=1;
    positionAnimation.fromValue = [captionView.layer valueForKey:@"position.y"];
	
	captionFrame.origin.y-=captionFrame.size.height;
	captionView.frame=captionFrame;
	
	positionAnimation.toValue = [captionView.layer valueForKey:@"position.y"];
	positionAnimation.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.19 :0.91 :1.00 :1.00]; //smoother!
	
    [captionView.layer addAnimation:positionAnimation forKey:@"position"];
	
	if(imageView.frame.origin.y+imageView.frame.size.height>=self.frame.size.height+captionFrame.size.height){
		
		CGRect imageFrame=imageView.frame;
		
		CABasicAnimation *positionAnimation2 = [CABasicAnimation animationWithKeyPath:@"position.y"];
		positionAnimation2.removedOnCompletion=YES;
		positionAnimation2.duration=1;
		positionAnimation2.fromValue = [imageView.layer valueForKey:@"position.y"];
		
		imageFrame.origin.y-=captionFrame.size.height;
		imageView.frame=imageFrame;
		
		positionAnimation2.toValue = [captionView.layer valueForKey:@"position.y"];
		positionAnimation2.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.19 :0.91 :1.00 :1.00]; //smoother!
		
		// Add the animation, overriding the implicit animation.
		[imageView.layer addAnimation:positionAnimation2 forKey:@"position"];
	}
	
	if(timer){
		[timer release];
	}
	timer=[[NSTimer scheduledTimerWithTimeInterval:5.5+1*((arc4random()%100)/100.0) target:self selector:@selector(hideCaption:) userInfo:nil repeats:NO] retain];
}
-(void)hideCaption:(NSTimer*)_timer{
	CGRect captionFrame=captionView.frame;
	
	CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
	positionAnimation.removedOnCompletion=YES;
	positionAnimation.duration=1;
    positionAnimation.fromValue = [captionView.layer valueForKey:@"position.y"];
	
	captionFrame.origin.y+=captionFrame.size.height;
	captionView.frame=captionFrame;
	
	positionAnimation.toValue = [captionView.layer valueForKey:@"position.y"];
	positionAnimation.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.19 :0.91 :1.00 :1.00]; //smoother!
	
    // Add the animation, overriding the implicit animation.
    [captionView.layer addAnimation:positionAnimation forKey:@"position"];
	
	if(imageView.frame.origin.y<=captionFrame.size.height*-1){
		
		CGRect imageFrame=imageView.frame;
		
		CABasicAnimation *positionAnimation2 = [CABasicAnimation animationWithKeyPath:@"position.y"];
		positionAnimation2.removedOnCompletion=YES;
		positionAnimation2.duration=1;
		positionAnimation2.fromValue = [imageView.layer valueForKey:@"position.y"];
		
		imageFrame.origin.y+=captionFrame.size.height;
		imageView.frame=imageFrame;
		
		positionAnimation2.toValue = [captionView.layer valueForKey:@"position.y"];
		positionAnimation2.timingFunction=[CAMediaTimingFunction functionWithControlPoints:0.19 :0.91 :1.00 :1.00]; //smoother!
		
		// Add the animation, overriding the implicit animation.
		[imageView.layer addAnimation:positionAnimation2 forKey:@"position"];
	}
	
	if(timer){
		[timer release];
	}
	timer=[[NSTimer scheduledTimerWithTimeInterval:4.5+1*((arc4random()%100)/100.0) target:self selector:@selector(pullUpCaption:) userInfo:nil repeats:NO] retain];
}
#pragma mark Web
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image{
	displayImage=[image retain];
	[self setNeedsDisplay];
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error{
	
}
#pragma mark -
-(void)setStatus:(Status *)_status{
	if(status){
		[status release];
	}
	status=[_status retain];
	self.imageURL=status.thumbURL;
	self.captionLabel.text=status.caption;
}
#pragma mark -
- (void)dealloc {
    self.imageURL=nil;
    self.status=nil;
	if(timer){
		[timer release];
	}
	[captionImageView removeFromSuperview];
	[captionImageView release];
	[coverView removeFromSuperview];
	[coverView release];
	[imageView removeFromSuperview];
	[imageView release];
	[captionView removeFromSuperview];
	[captionView release];
	[captionLabel removeFromSuperview];
	[captionLabel release];
	
	if(displayImage){
		[displayImage release];
	}
    [super dealloc];
}


@end

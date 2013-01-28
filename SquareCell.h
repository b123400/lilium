//
//  SquareCell.h
//  perSecond
//
//  Created by b123400 on 03/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRGridViewCell.h"
#import "SDWebImageManager.h"
#import "Status.h"
#import "OLImageView.h"

@interface SquareCell : BRGridViewCell <SDWebImageManagerDelegate> {
	UIImage *displayImage;
	NSURL *imageURL;
	OLImageView *imageView;
	UIView *captionView;
	UIImageView *captionImageView;
	UIImageView *coverView;
	UILabel *captionLabel;
	
	NSTimer *timer;
	Status *status;
}
@property (retain,nonatomic) NSURL *imageURL;
@property (readonly) UILabel *captionLabel;
@property (retain,nonatomic) Status *status;

@end
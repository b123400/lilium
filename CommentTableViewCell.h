//
//  CommentTableViewCell.h
//  perSecond
//
//  Created by b123400 Chan on 24/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"
#import "Comment.h"
#import "SDWebImageManager.h"

@interface CommentTableViewCell : ABTableViewCell<SDWebImageManagerDelegate>{
	Comment *comment;
	UIImage *profileImage;
}
@property (retain,nonatomic) Comment *comment;
@property (retain,nonatomic) UIImage *profileImage;

@end

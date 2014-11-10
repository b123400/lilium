//
//  BRGridViewCell.h
//  perSecond
//
//  Created by b123400 on 03/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRGridViewCellDelegate

-(void)cellDidMovedToWindow:(id)sender;
-(void)cellDidRemovedFromWindow:(id)sender; 
-(void)cellTapped:(id)sender;

@end


@interface BRGridViewCell : UIView {
	id <BRGridViewCellDelegate> gridView;
	NSString *reuseIdentifier;
	NSIndexPath *indexPath;
}
@property (assign) id <BRGridViewCellDelegate> gridView;
@property (retain,nonatomic) NSString *reuseIdentifier;
@property (assign) CGSize cellMargin;
@property (retain) NSIndexPath *indexPath;

-(instancetype)initWithReuseIdentifier:(NSString*)identifier;

@end

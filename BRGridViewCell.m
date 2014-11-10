//
//  BRGridViewCell.m
//  perSecond
//
//  Created by b123400 on 03/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRGridViewCell.h"


@implementation BRGridViewCell
@synthesize gridView,reuseIdentifier,indexPath;

/*- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}*/

-(instancetype)initWithReuseIdentifier:(NSString *)identifier{
	reuseIdentifier=[identifier retain];
	self=[self init];
	self.clearsContextBeforeDrawing=YES;
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
- (void)didMoveToSuperview{
	if(gridView){
		if(self.superview){
			[gridView cellDidMovedToWindow:self];
		}else{
			[gridView cellDidRemovedFromWindow:self];
		}
	}
	[super didMoveToSuperview];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[gridView cellTapped:self];
	[super touchesEnded:touches withEvent:event];
}
- (void)dealloc {
	[reuseIdentifier release];
    [super dealloc];
}


@end

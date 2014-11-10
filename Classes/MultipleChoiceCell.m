//
//  MultipleChoiceCell.m
//  perSecond
//
//  Created by b123400 on 21/1/13.
//
//

#import "MultipleChoiceCell.h"
#import "UIView+Interaction.h"

@implementation MultipleChoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setTouchReactionEnabled:YES];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(0, self.textLabel.frame.origin.y, self.frame.size.width, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(0, self.detailTextLabel.frame.origin.y, self.frame.size.width, self.detailTextLabel.frame.size.height);
}

@end

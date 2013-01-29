//
//  AboutViewController.h
//  perSecond
//
//  Created by b123400 on 29/1/13.
//
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

@interface AboutViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *appNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *versonLabel;
@property (retain, nonatomic) IBOutlet OHAttributedLabel *descriptionLabel;
@property (retain, nonatomic) IBOutlet UIButton *licenceButton;

@end

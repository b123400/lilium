//
//  SettingViewController.h
//  perSecond
//
//  Created by b123400 on 13/1/13.
//
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController{
    
}
@property (retain, nonatomic) IBOutlet UIButton *autoReloadButton;
@property (retain, nonatomic) IBOutlet UIButton *tumblrReblogButton;
@property (retain, nonatomic) IBOutlet UIButton *clearCacheButton;

- (IBAction)tumblrReblogButtonPressed:(id)sender;
- (IBAction)autoReloadPressed:(id)sender;
- (IBAction)clearCachePressed:(id)sender;

@end

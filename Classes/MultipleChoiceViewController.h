//
//  MultipleChoiceViewController.h
//  perSecond
//
//  Created by b123400 on 15/1/13.
//
//

#import <UIKit/UIKit.h>
#import "Choice.h"

@interface MultipleChoiceViewController : UIViewController{
    NSArray *choices;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSArray *choices;

+(MultipleChoiceViewController*)controllerWithChoices:(NSArray*)choices;
-(id)initWithChoices:(NSArray*)choices;

@end

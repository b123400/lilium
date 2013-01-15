//
//  MultipleChoiceViewController.m
//  perSecond
//
//  Created by b123400 on 15/1/13.
//
//

#import "MultipleChoiceViewController.h"

@interface MultipleChoiceViewController ()

@end

@implementation MultipleChoiceViewController
@synthesize choices;

+(MultipleChoiceViewController*)controllerWithChoices:(NSArray*)_choices{
    return [[[MultipleChoiceViewController alloc] initWithChoices:_choices] autorelease];
}
-(id)initWithChoices:(NSArray*)_choices{
    self = [self init];
    self.choices=_choices;
    return self;
}

-(id)init{
    return [self initWithNibName:@"MultipleChoiceViewController" bundle:NO];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text=self.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_titleLabel release];
    self.choices=nil;
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.textLabel.font=[UIFont fontWithName:@"Heiti TC" size:cell.textLabel.font.pointSize];
    }
    Choice *thisChoice=[choices objectAtIndex:indexPath.row];
    cell.textLabel.text=thisChoice.text;
    cell.detailTextLabel.text=thisChoice.detailText;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return choices.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Choice *thisChoice=[choices objectAtIndex:indexPath.row];
    thisChoice.action();
    [self.navigationController popViewControllerAnimated:YES];
}
@end

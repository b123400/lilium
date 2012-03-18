//
//  StatusDetailViewController.m
//  perSecond
//
//  Created by b123400 on 06/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "StatusDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "OHAttributedLabel.h"

@implementation StatusDetailViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/
-(id)initWithStatus:(Status*)_status{
	status=[_status retain];
	return [self init];
}
-(id)init{
	self = [super initWithNibName:@"StatusDetailViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	gridView.contentIndent=CGSizeMake(310, 10);
	gridView.cellSize=CGSizeMake(120, 120);
	gridView.numOfRow=3;
	gridView.alwaysBounceVertical=YES;
	gridView.alwaysBounceHorizontal=YES;
	gridView.showsHorizontalScrollIndicator=NO;
	gridView.showsVerticalScrollIndicator=NO;
	gridView.cellMargin=CGSizeMake(40, 40);
	gridView.alwaysBounceVertical=NO;
	[gridView addSubview:statusDetailView];
	[mainImageView setImageWithURL:status.meduimURL];
    [super viewDidLoad];
	
	OHAttributedLabel *textLabel=[[OHAttributedLabel alloc] initWithFrame:CGRectMake(mainImageView.frame.origin.x, mainImageView.frame.origin.y+mainImageView.frame.size.height, mainImageView.frame.size.width, 100)];
	textLabel.text=status.caption;
	[tableViewHeader addSubview:textLabel];
}
- (BRGridViewCell *)gridView:(id)gridView cellAtIndexPath:(NSIndexPath *)indexPath{
	return nil;
}
- (NSInteger)gridView:(id)gridView numberOfCellsInSection:(NSInteger)section{
	return 0;
}
- (NSInteger)numberOfSectionsInGridView:(id)gridView{
	return 0;
}
- (void)gridView:(id)gridView didSelectCell:(BRGridViewCell*)cell AtIndexPath:(NSIndexPath *)indexPath{
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[status release];
    [super dealloc];
}


@end

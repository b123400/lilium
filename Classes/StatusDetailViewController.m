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
#import "Attribute.h"
#import "Comment.h"
#import "CommentTableViewCell.h"
#import "UserViewController.h"
#import "UIImage-Tint.h"

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
	self=[self init];
	status=[_status retain];
	[status getCommentsAndReturnTo:self withSelector:@selector(didReceiveComments:)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentPosted)
                                                 name:StatusDidSentCommentNotification
                                               object:_status];
	return self;
}

-(id)init{
	self = [super initWithNibName:@"StatusDetailViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    commentLoading.hidden=YES;
	[mainImageView setImageWithURL:status.mediumURL placeholderImage:[status cachedImageOfSize:StatusImageSizeThumb]];
    [super viewDidLoad];
	
	OHAttributedLabel *textLabel=[[OHAttributedLabel alloc] initWithFrame:CGRectMake(mainImageView.frame.origin.x, mainImageView.frame.origin.y+mainImageView.frame.size.height+5, mainImageView.frame.size.width, 1000)];
	textLabel.extendBottomToFit=YES;
	textLabel.lineBreakMode=UILineBreakModeWordWrap;
	textLabel.numberOfLines=0;
	textLabel.backgroundColor=[UIColor clearColor];
	textLabel.textColor=[UIColor whiteColor];
	textLabel.text=status.caption;
	
	for(Attribute *thisAttribute in status.attributes){
		[textLabel addCustomLink:thisAttribute.url inRange:thisAttribute.range];
	}
	
	[imageWrapperView addSubview:textLabel];
	CGRect frame=textLabel.frame;
	frame.size=[textLabel sizeThatFits:textLabel.frame.size];
	textLabel.frame=frame;
    
    likeButton.frame=CGRectMake(imageWrapperView.frame.size.width-likeButton.frame.size.width, textLabel.frame.origin.y+textLabel.frame.size.height, likeButton.frame.size.width, likeButton.frame.size.height);
	
	frame=imageWrapperView.frame;
	frame.size.height=likeButton.frame.size.height+likeButton.frame.origin.y+5;
	imageWrapperView.frame=frame;
	
	imageWrapperScrollView.contentSize=CGSizeMake(imageWrapperView.frame.size.width, imageWrapperView.frame.size.height+imageWrapperView.frame.origin.y);
	mainScrollView.contentSize=CGSizeMake(commentTableView.frame.origin.x+commentTableView.frame.size.width, commentTableView.frame.origin.y+commentTableView.frame.size.height);
    
    if(!commentComposeView){
        commentComposeView=[[CommentComposeView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        commentComposeView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        commentComposeView.textField.delegate=self;
    }
    commentComposeView.frame=CGRectMake(10, mainScrollView.frame.size.height-commentComposeView.frame.size.height, mainScrollView.frame.size.width-20, commentComposeView.frame.size.height);
    if(status.user.type==StatusSourceTypeTumblr){
        commentComposeView.textField.placeholder=@"reblog with comment";
    }
    
    [self.view insertSubview:commentComposeView aboveSubview:mainScrollView];
    commentTableView.contentInset=UIEdgeInsetsMake(0, 0, 44, 0);
    imageWrapperScrollView.contentInset=UIEdgeInsetsMake(0, 0, 54, 0);
    
    [self refreshLikeButton];
}
-(void)didReceiveComments:(NSArray*)comments{
	[commentTableView reloadData];
}
-(void)refreshLikeButton{
    if(status.liked){
        [likeButton setImage:[[UIImage imageNamed:@"heart.png"] tintedImageUsingColor:[UIColor colorWithRed:238/255. green:0 blue:72/255. alpha:1.0]] forState:UIControlStateNormal];
    }else{
        [likeButton setImage:[[UIImage imageNamed:@"heart.png"] tintedImageUsingColor:[UIColor colorWithRed:171/255. green:242/255. blue:109/255. alpha:1.0]] forState:UIControlStateNormal];
    }
}
#pragma mark user interaction
- (IBAction)likeButtonClicked:(id)sender {
    status.liked=!status.liked;
    [self refreshLikeButton];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [commentComposeView.textField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [status submitComment:textField.text];
    [textField resignFirstResponder];
    [commentTableView reloadData];
    if(commentTableView.contentSize.height>commentTableView.frame.size.height){
        [commentTableView setContentOffset:CGPointMake(0, commentTableView.contentSize.height - commentTableView.bounds.size.height) animated:YES];
    }
    textField.text=@"";
    return YES;
}
-(void)commentPosted{
    [status getCommentsAndReturnTo:self withSelector:@selector(didReceiveComments:) cached:NO];
}
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = commentComposeView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	commentComposeView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = commentComposeView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	commentComposeView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}
#pragma mark table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	CommentTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
	if(!cell){
		cell=[[CommentTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	}
	cell.comment=[status.comments objectAtIndex:indexPath.row];
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [status.comments count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	float height=85;
	
	UIFont *cellFont = [UIFont fontWithName:@"Arial" size:12];
	CGSize constraintSize = CGSizeMake(tableView.frame.size.width-99, MAXFLOAT);
	CGSize labelSize = [((Comment*)[status.comments objectAtIndex:indexPath.row]).text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	height=labelSize.height+=64;
	
	if(height<85){
		height=85;
	};
	return height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *thisComment=[status.comments objectAtIndex:indexPath.row];
    if(thisComment.user!=[User me]){
        UserViewController *userViewController=[[[UserViewController alloc]initWithUser:thisComment.user] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    }
}
#pragma mark navigation
-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
	NSMutableArray *views=[NSMutableArray arrayWithObject:imageWrapperView];
	[views addObjectsFromArray:[commentTableView visibleCells]];
    [views addObject:commentComposeView];
	return views;
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
	[imageWrapperScrollView release];
	imageWrapperScrollView = nil;
	[mainScrollView release];
	mainScrollView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(commentComposeView)[commentComposeView release];
	[status release];
	[imageWrapperScrollView release];
	[mainScrollView release];
    [super dealloc];
}


@end

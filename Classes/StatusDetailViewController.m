//
//  StatusDetailViewController.m
//  perSecond
//
//  Created by b123400 on 06/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "StatusDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "Comment.h"
#import "CommentTableViewCell.h"
#import "UserViewController.h"
#import "UIImage-Tint.h"
#import "UIImageView+WebCache.h"
#import "BRImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "NichijyouNavigationController.h"

@interface StatusDetailViewController ()

-(void)loadResources;
-(void)layout;
-(void)didRefreshedImage;
-(void)userViewTapped;
-(void)imageTapped:(UITapGestureRecognizer*)gestureGecognizer;

@end

@implementation StatusDetailViewController
@synthesize delegate,status;
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
    [super viewDidLoad];
	
    if(!textLabel){
        textLabel=[[OHAttributedLabel alloc] initWithFrame:CGRectMake(mainImageView.frame.origin.x, mainImageView.frame.origin.y+mainImageView.frame.size.height+5, mainImageView.frame.size.width, 1000)];
        textLabel.extendBottomToFit=YES;
        textLabel.lineBreakMode=UILineBreakModeWordWrap;
        textLabel.numberOfLines=0;
        textLabel.backgroundColor=[UIColor clearColor];
        textLabel.textColor=[UIColor whiteColor];
        textLabel.font=[UIFont systemFontOfSize:15];
        textLabel.linkColor=[UIColor whiteColor];
    }
	if(!commentComposeView){
        commentComposeView=[[CommentComposeView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        commentComposeView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        commentComposeView.textField.delegate=self;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didRefreshedImage) name:SDWebCacheDidLoadedImageForImageViewNotification
                                              object:mainImageView];
    UITapGestureRecognizer *tapRecognizer=[[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapped:)] autorelease];
    tapRecognizer.numberOfTapsRequired=1;
    tapRecognizer.numberOfTouchesRequired=1;
    [tapRecognizer requireGestureRecognizerToFail:[(NichijyouNavigationController*)self.navigationController pinchGestureRecognizer]];
    [mainImageView addGestureRecognizer:tapRecognizer];
    UIPinchGestureRecognizer *pinchRecognizer=[[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(imagePinched:)]autorelease];
    [mainImageView addGestureRecognizer:pinchRecognizer];
    
    UIGestureRecognizer *userTap=[[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userViewTapped)] autorelease];
    [userTap requireGestureRecognizerToFail:[(NichijyouNavigationController*)self.navigationController pinchGestureRecognizer]];
    [userView addGestureRecognizer:userTap];
    
    [self loadResources];
    [self layout];
}
-(void)loadResources{
    [mainImageView setImageWithURL:status.mediumURL placeholderImage:[status cachedImageOfSize:StatusImageSizeThumb]];
    [status getCommentsAndReturnTo:self withSelector:@selector(didReceiveComments:)];
}
-(void)layout{
    commentLoading.hidden=YES;
	
    if(mainImageView.image){
        CGSize size=mainImageView.image.size;
        float height=size.height*(mainImageView.frame.size.width/size.width);
        height=MAX(height, mainImageView.frame.size.width);
        CGRect frame=mainImageView.frame;
        frame.size.height=height;
        mainImageView.frame=frame;
    }
    
    textLabel.frame=CGRectMake(mainImageView.frame.origin.x, mainImageView.frame.origin.y+mainImageView.frame.size.height+5, mainImageView.frame.size.width, 1000);
    textLabel.text=status.caption;
	
	for(Attribute *thisAttribute in status.attributes){
		[textLabel addCustomLink:thisAttribute.url inRange:thisAttribute.range];
	}
	
	[imageWrapperView addSubview:textLabel];
	CGRect frame=textLabel.frame;
	frame.size=[textLabel sizeThatFits:textLabel.frame.size];
	textLabel.frame=frame;
	
	frame=imageWrapperView.frame;
	frame.size.height=textLabel.frame.size.height+textLabel.frame.origin.y+5;
    if([status.caption isEqualToString:@""])frame.size.height-=5;
	imageWrapperView.frame=frame;
    
    if(!userView.superview){
        [imageWrapperScrollView addSubview:userView];
    }
    userView.frame=CGRectMake(imageWrapperView.frame.origin.x, imageWrapperView.frame.origin.y+imageWrapperView.frame.size.height, imageWrapperView.frame.size.width, userView.frame.size.height);
    displayNameLabel.text=status.user.displayName;
    [profileImageView setImageWithURL:status.user.profilePicture];
    
    imageWrapperScrollView.contentSize=CGSizeMake(imageWrapperView.frame.size.width, userView.frame.size.height+userView.frame.origin.y);
	mainScrollView.contentSize=CGSizeMake(commentTableView.frame.origin.x+commentTableView.frame.size.width, 1);
    
    
    commentComposeView.frame=CGRectMake(10, mainScrollView.frame.size.height-commentComposeView.frame.size.height, mainScrollView.frame.size.width-20, commentComposeView.frame.size.height);
    if(status.user.type==StatusSourceTypeTumblr){
        commentComposeView.textField.placeholder=@"reblog with comment";
    }
    
    [self.view insertSubview:commentComposeView aboveSubview:mainScrollView];
    commentTableView.contentInset=UIEdgeInsetsMake(0, 0, 44, 0);
    imageWrapperScrollView.contentInset=UIEdgeInsetsMake(0, 0, 44, 0);
    
    [self refreshLikeButton];
}
-(void)didReceiveComments:(NSArray*)comments{
	[commentTableView reloadData];
}
-(void)refreshLikeButton{
    if(status.liked){
        [likeButton setImage:[[UIImage imageNamed:@"heart.png"] tintedImageUsingColor:[UIColor colorWithRed:238/255. green:0 blue:72/255. alpha:1.0]] forState:UIControlStateNormal];
    }else{
        [likeButton setImage:[[UIImage imageNamed:@"heart.png"] tintedImageUsingColor:[UIColor colorWithRed:101/255.0 green:156/255.0 blue:60/255.0 alpha:1.0]] forState:UIControlStateNormal];
    }
}
-(void)didRefreshedImage{
    [UIView animateWithDuration:0.1 animations:^{
        [self layout];
    }];
}
#pragma mark - user interaction
- (IBAction)likeButtonClicked:(id)sender {
    status.liked=!status.liked;
    [self refreshLikeButton];
}

- (IBAction)actionButtonClicked:(id)sender {
    UIActionSheet *actionSheet= [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari",@"Save image", nil] autorelease];
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title=[actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Open in Safari"]){
        [[UIApplication sharedApplication] openURL:status.webURL];
    }else if([title isEqualToString:@"Save image"]){
        [SVProgressHUD show];
        [SVProgressHUD setStatus:@"Downloading"];
        [[SDWebImageManager sharedManager] downloadWithURL:status.fullURL delegate:self];
    }
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image{
    [SVProgressHUD setStatus:@"Saving"];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error{
    [SVProgressHUD dismissWithError:@"Cannot download image"];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
        [SVProgressHUD dismissWithError:@"Failed"];
    }
    else  // No errors
    {
        // Show message image successfully saved
        [SVProgressHUD dismissWithSuccess:@"Saved"];
    }
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
-(void)userViewTapped{
    UserViewController *userViewController=[[UserViewController alloc]initWithUser:status.user];
    [self.navigationController pushViewController:userViewController animated:YES];
    [userViewController release];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(scrollView==imageWrapperScrollView){
        if(scrollView.contentOffset.y<-60){
            //prev
            Status *prevStatus=[delegate previousImageForStatusViewController:self currentStatus:status];
            if(prevStatus){
                [UIView animateWithDuration:0.1 animations:^{
                    imageWrapperScrollView.layer.transform=CATransform3DMakeTranslation(0, 300, 0);
                    imageWrapperScrollView.layer.opacity=0;
                } completion:^(BOOL finished) {
                    if(finished){
                        [status release];
                        status=[prevStatus retain];
                        [self loadResources];
                        [self layout];
                    }
                    imageWrapperScrollView.layer.transform=CATransform3DMakeTranslation(0, -300, 0);
                    [UIView animateWithDuration:0.1 animations:^{
                        imageWrapperScrollView.layer.transform=CATransform3DIdentity;
                        imageWrapperScrollView.layer.opacity=1;
                    } completion:^(BOOL finished) {
                        
                    }];
                }];
            }
        }else if((scrollView.contentSize.height>=scrollView.frame.size.height&&scrollView.contentOffset.y>scrollView.contentSize.height-scrollView.frame.size.height+60)||
                 (scrollView.contentSize.height<scrollView.frame.size.height&&scrollView.contentOffset.y>60)){
            //next
            Status *nextStatus=[delegate nextImageForStatusViewController:self currentStatus:status];
            if(nextStatus){
                [UIView animateWithDuration:0.1 animations:^{
                    imageWrapperScrollView.layer.transform=CATransform3DMakeTranslation(0, -300, 0);
                    imageWrapperScrollView.layer.opacity=0;
                } completion:^(BOOL finished) {
                    if(finished){
                        [status release];
                        status=[nextStatus retain];
                        [self loadResources];
                        [self layout];
                    }
                    imageWrapperScrollView.layer.transform=CATransform3DMakeTranslation(0, 300, 0);
                    [UIView animateWithDuration:0.1 animations:^{
                        imageWrapperScrollView.layer.transform=CATransform3DIdentity;
                        imageWrapperScrollView.layer.opacity=1;
                    } completion:^(BOOL finished) {
                        
                    }];
                }];
            }
        }
    }
}
-(void)imageTapped:(UITapGestureRecognizer*)gestureRecognizer{
    if(gestureRecognizer.state==UIGestureRecognizerStateEnded){
        BRImageViewController *imageController=[[BRImageViewController alloc] initWithImageURL:status.fullURL placeHolder:mainImageView.image];
        imageController.initialFrame=[mainImageView.superview convertRect:mainImageView.frame toView:self.view];
        [self.navigationController pushViewController:imageController animated:NO];
        [imageController release];
    }
}
-(void)imagePinched:(UIPinchGestureRecognizer*)gestureRecognizer{
    if(gestureRecognizer.state==UIGestureRecognizerStateBegan){
        CGPoint point=[gestureRecognizer locationInView:mainImageView];
        CGPoint anchor=CGPointMake(point.x/mainImageView.frame.size.width, point.y/mainImageView.frame.size.height);
        mainImageView.layer.anchorPoint=anchor;
        mainImageView.center=[gestureRecognizer locationInView:mainImageView.superview];
    }else if(gestureRecognizer.state==UIGestureRecognizerStateChanged){
        if(gestureRecognizer.scale>1.0){
            mainImageView.layer.transform=CATransform3DMakeScale(gestureRecognizer.scale, gestureRecognizer.scale, 1.0);
        }
    }else if(gestureRecognizer.state==UIGestureRecognizerStateEnded||gestureRecognizer.state==UIGestureRecognizerStateCancelled){
        if(gestureRecognizer.scale<1.0){
            [UIView animateWithDuration:0.1 animations:^{
                mainImageView.layer.transform=CATransform3DIdentity;
            }];
        }else{
            BRImageViewController *imageController=[[BRImageViewController alloc] initWithImageURL:status.fullURL placeHolder:mainImageView.image];
            imageController.initialFrame=[mainImageView.superview convertRect:mainImageView.frame toView:self.view];
            [self.navigationController pushViewController:imageController animated:NO];
            
            CATransform3D transform=mainImageView.layer.transform;
            mainImageView.layer.transform=CATransform3DIdentity;
            imageController.finalFrame=[mainImageView.superview convertRect:mainImageView.frame toView:self.view];
            [imageController release];
            
            mainImageView.layer.transform=transform;
            [UIView animateWithDuration:0.1 animations:^{
                mainImageView.layer.transform=CATransform3DIdentity;
            }];
        }
    }
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
	NSMutableArray *views=[NSMutableArray arrayWithObject:imageWrapperScrollView];
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
    if(commentComposeView)[commentComposeView release];
    if(textLabel)[textLabel release];
    textLabel=nil;
	[imageWrapperScrollView release];
	imageWrapperScrollView = nil;
	[mainScrollView release];
	mainScrollView = nil;
    [userView release];
    userView = nil;
    [profileImageView release];
    profileImageView = nil;
    [displayNameLabel release];
    displayNameLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[status release];
	[imageWrapperScrollView release];
	[mainScrollView release];
    [userView release];
    [profileImageView release];
    [displayNameLabel release];
    [super dealloc];
}


@end

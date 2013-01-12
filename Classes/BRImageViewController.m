//
//  BRFullscreeImageViewController.m
//  perSecond
//
//  Created by b123400 on 12/1/13.
//
//

#import "BRImageViewController.h"
#import "UIImageView+WebCache.h"

@interface BRImageViewController ()

-(void)didRefreshedImage;
-(void)refreshContentInset;
-(void)pinched:(UIPinchGestureRecognizer*)gestureRecognizer;

@end

@implementation BRImageViewController
@synthesize imageView,scrollView,initialFrame;

-(id)initWithImage:(UIImage*)_image{
    image=[_image retain];
    return [self init];
}
-(id)initWithImageURL:(NSURL*)_url{
    url=[_url retain];
    return [self init];
}
-(id)initWithImageURL:(NSURL*)_url placeHolder:(UIImage*)_placeHolderImage{
    url=[_url retain];
    if(_placeHolderImage){
        placeHolderImage=[_placeHolderImage retain];
    }
    return [self init];
}
-(id)init{
    initialFrame=CGRectZero;
    lastPinchedScale=-1;
    return [super init];
}

-(void)dealloc{
    if(self.scrollView)self.scrollView.delegate=nil;
    if(url)[url release];
    if(placeHolderImage)[placeHolderImage release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    self.view.autoresizesSubviews=YES;
    
    self.scrollView=[[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)]autorelease];
    self.scrollView.delegate=self;
    self.scrollView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.bouncesZoom=YES;
    self.scrollView.scrollEnabled=YES;
    self.scrollView.alwaysBounceHorizontal=YES;
    self.scrollView.alwaysBounceVertical=YES;
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=3.0;
    self.scrollView.multipleTouchEnabled=YES;
    self.scrollView.userInteractionEnabled=YES;
    UIPinchGestureRecognizer *gestureRecognizer=[[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)] autorelease];
    gestureRecognizer.delegate=self;
    [self.scrollView addGestureRecognizer:gestureRecognizer];
    [self.view addSubview:self.scrollView];
    
    self.imageView=[[[UIImageView alloc]initWithFrame:self.scrollView.frame]autorelease];
    self.imageView.contentMode=UIViewContentModeScaleAspectFill;
    if(image){
        self.imageView.image=image;
    }else if(url&&placeHolderImage){
        [self.imageView setImageWithURL:url placeholderImage:placeHolderImage];
    }else if(url){
        [self.imageView setImageWithURL:url];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didRefreshedImage) name:SDWebCacheDidLoadedImageForImageViewNotification
                                              object:self.imageView];
    
    [self.scrollView addSubview:self.imageView];
    [self layout];
}
-(void)viewDidAppear:(BOOL)animated{
    if(image||placeHolderImage){
        CGRect imageViewFrame=[self.scrollView convertRect:self.imageView.frame toView:self.view];
        UIImageView *tempImageView=[[[UIImageView alloc]initWithFrame:initialFrame]autorelease];
        tempImageView.backgroundColor=[UIColor clearColor];
        tempImageView.contentMode=UIViewContentModeScaleAspectFill;
        if(image){
            tempImageView.image=image;
        }else if(placeHolderImage){
            tempImageView.image=placeHolderImage;
        }
        [self.view addSubview:tempImageView];
        self.imageView.hidden=YES;
        [UIView animateWithDuration:0.1 animations:^{
            tempImageView.frame=imageViewFrame;
        } completion:^(BOOL finished) {
            if(finished){
                [tempImageView removeFromSuperview];
                self.imageView.hidden=NO;
            }
        }];
    }
}
-(void)layout{
    if(self.imageView.image){
        self.scrollView.maximumZoomScale=1.0;
        self.scrollView.zoomScale=1.0;
        
        float widthPercentage=self.scrollView.frame.size.width/self.imageView.image.size.width;
        float heightPercentage=self.scrollView.frame.size.height/self.imageView.image.size.height;
        float percentage=MIN(widthPercentage, heightPercentage);
        
        self.imageView.frame=CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
        self.scrollView.minimumZoomScale=percentage;
        self.scrollView.contentSize=self.imageView.frame.size;
        [self refreshContentInset];
        self.scrollView.zoomScale=percentage;
    }
}
-(void)refreshContentInset{
    float x=(self.scrollView.frame.size.width-self.imageView.frame.size.width)/2;
    float y=(self.scrollView.frame.size.height-self.imageView.frame.size.height)/2;
    if(x<0)x=0;
    if(y<0)y=0;
    self.scrollView.contentInset=UIEdgeInsetsMake(y, x, y, x);
}
-(void)didRefreshedImage{
    [self layout];
}
-(void)viewDidUnload{
    self.scrollView.delegate=nil;
    [super viewDidUnload];
}
-(BOOL)shouldPopByPinch{
    return NO;
}
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)inScroll {
    return imageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self refreshContentInset];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)pinched:(UIPinchGestureRecognizer*)gestureRecognizer{
    NSLog(@"zoom %f min %f",self.scrollView.zoomScale,self.scrollView.minimumZoomScale);
    if(gestureRecognizer.state==UIGestureRecognizerStateBegan||gestureRecognizer.state==UIGestureRecognizerStateCancelled){
        lastPinchedScale=-1;
    }else if(gestureRecognizer.state==UIGestureRecognizerStateChanged) {
        lastPinchedScale=self.scrollView.zoomScale;
    }else if(gestureRecognizer.state==UIGestureRecognizerStateEnded){
        if(lastPinchedScale<self.scrollView.minimumZoomScale&&lastPinchedScale!=-1){
            CGRect frame=[self.scrollView convertRect:self.imageView.frame toView:self.view];
            UIImageView *tempImageView=[[[UIImageView alloc]initWithFrame:frame]autorelease];
            tempImageView.backgroundColor=[UIColor clearColor];
            tempImageView.contentMode=UIViewContentModeScaleAspectFill;
            tempImageView.image=self.imageView.image;
            [self.view addSubview:tempImageView];
            self.imageView.hidden=YES;
            scrollView.scrollEnabled=NO;
            scrollView.bouncesZoom=NO;
            [scrollView removeFromSuperview];
            [UIView animateWithDuration:0.1 animations:^{
                tempImageView.frame=initialFrame;
            } completion:^(BOOL finished) {
                if(finished){
                    [tempImageView removeFromSuperview];
                    [self retain];
                    [self.navigationController popViewControllerAnimated:NO];
                }
            }];
        }
        lastPinchedScale=-1;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

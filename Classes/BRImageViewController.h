//
//  BRFullscreeImageViewController.h
//  perSecond
//
//  Created by b123400 on 12/1/13.
//
//

#import <UIKit/UIKit.h>

@interface BRImageViewController : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate>{
    UIImage *image;
    NSURL *url;
    UIImage *placeHolderImage;
    CGRect initialFrame;
    
    UIImageView *imageView;
    UIScrollView *scrollView;
    
    float lastPinchedScale;
}
@property (nonatomic,retain)    UIImageView *imageView;
@property (nonatomic,retain)    UIScrollView *scrollView;
@property (nonatomic,assign)    CGRect initialFrame;

-(id)initWithImage:(UIImage*)image;
-(id)initWithImageURL:(NSURL*)url;
-(id)initWithImageURL:(NSURL*)url placeHolder:(UIImage*)placeHolderImage;

@end

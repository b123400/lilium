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
    CGRect finalFrame;
    
    UIImageView *imageView;
    UIScrollView *scrollView;
    
    float lastPinchedScale;
}
@property (nonatomic,retain)    UIImageView *imageView;
@property (nonatomic,retain)    UIScrollView *scrollView;
@property (nonatomic,assign)    CGRect initialFrame;
@property (nonatomic,assign)    CGRect finalFrame;

-(id)initWithImage:(UIImage*)image;
-(id)initWithImageURL:(NSURL*)url;
-(id)initWithImageURL:(NSURL*)url placeHolder:(UIImage*)placeHolderImage;

@end

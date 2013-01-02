//
//  LikeRequest.h
//  perSecond
//
//  Created by b123400 on 31/12/12.
//
//

#import "Request.h"
#import "Status.h"

@interface LikeRequest : Request{
    Status *targetStatus;
    BOOL isLike;
}
@property (nonatomic,retain) Status *targetStatus;
@property (nonatomic,assign) BOOL isLike;

@end

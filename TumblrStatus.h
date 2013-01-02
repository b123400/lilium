//
//  TumblrStatus.h
//  perSecond
//
//  Created by b123400 on 3/1/13.
//
//

#import "Status.h"

@interface TumblrStatus : Status{
    NSString *reblogKey;
}
@property (nonatomic,retain) NSString *reblogKey;

@end

//
//  UserRequest.h
//  perSecond
//
//  Created by b123400 on 4/1/13.
//
//

#import "Request.h"
#import "User.h"

@interface UserRequest : Request{
    StatusSourceType type;
    NSString *userID;
}
@property (nonatomic,assign) StatusSourceType type;
@property (nonatomic,retain) NSString *userID;

@end

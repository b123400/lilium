//
//  RelationshipRequest.h
//  perSecond
//
//  Created by b123400 on 7/1/13.
//
//

#import "UserRequest.h"

@interface RelationshipRequest : Request{
    User *targetUser;
}
@property (nonatomic,retain)    User *targetUser;

@end

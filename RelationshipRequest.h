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
    UserRelationship targetRelationship;
}
@property (nonatomic,retain) User *targetUser;
@property (nonatomic,assign) UserRelationship targetRelationship;

@end

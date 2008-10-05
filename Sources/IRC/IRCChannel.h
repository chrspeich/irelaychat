/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Backend Class -                                                         *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>
#import "IRCConversation.h"

extern NSString *IRCUserListHasChanged;
extern NSString *IRCUserJoinsChannel;
extern NSString *IRCUserLeavesChannel;
extern NSString *IRCUserHasGotMode;
extern NSString *IRCUserHasLoseMode;

@interface IRCChannel : IRCConversation {
	NSMutableArray	*tmpUserList;
	NSMutableArray	*userList;
}

@property(readonly) NSMutableArray	*userList;

- (void) join;
- (void) part;

@end

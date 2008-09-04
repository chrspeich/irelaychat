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

extern NSString *IRCUserListHasChanged;
extern NSString *IRCNewChannelMessage;
extern NSString *IRCUserJoinsChannel;
extern NSString *IRCUserLeavesChannel;
extern NSString *IRCUserHasGotMode;
extern NSString *IRCUserHasLoseMode;

@class IRCServer;

@interface IRCChannel : NSObject {
	NSString		*name;
	IRCServer		*server;
	NSMutableArray	*tmpUserList;
	NSMutableArray	*userList;
	NSMutableArray	*messages;
	uint			unreadedMessages;
	uint			unreadedHighlightedMessages;
}

- (id) initWithServer:(IRCServer*)server andName:(NSString*)name;
- (void) sendMessage:(NSString*)message;

@property(readonly) NSString		*name;
@property(readonly) IRCServer		*server;
@property(readonly) NSMutableArray	*userList;
@property(readonly) NSArray			*messages;
@property(readonly) uint			unreadedMessages;
@property(readonly) uint			unreadedHighlightedMessages;

- (void) resetUnreadedMessages;

- (bool) supportInputField;
- (bool) hasUserList;

@end

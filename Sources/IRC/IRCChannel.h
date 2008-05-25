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
	NSString	*name;
	IRCServer	*server;
	NSMutableArray *tmpUserList;
	NSMutableArray *userList;
	NSMutableArray *userModes;
	NSMutableArray *messages;
}

- (id) initWithServer:(IRCServer*)server andName:(NSString*)name;
- (void) sendMessage:(NSString*)message;

@property(readonly,copy) NSString	*name;
@property(readonly,retain) IRCServer*server;
@property(readonly,retain) NSMutableArray *userList;
@property(readonly) NSMutableArray *userModes;
@property(readonly) NSArray *messages;

@end

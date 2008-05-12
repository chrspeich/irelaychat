/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat- A better IRC Client for Mac OS X                              *
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

extern NSString *IRCConnected;
extern NSString *IRCDisconnected;
extern NSString *IRCJoinChannel;
extern NSString *IRCLeaveChannel;
extern NSString *IRCUserQuit;

@class IRCChannel;
@class IRCMessage;
@class IRCUser;
@class IRCProtocol;

@interface IRCServer : NSObject {
	NSString		*host;
	NSString		*port;
	NSString		*serverName;
	NSString		*nick;
	bool			isConnected;
	NSMutableArray	*channels;
	NSMutableArray	*observerObjects;
	NSMutableArray	*knownUsers;
	NSMutableArray	*messages;
	int				sock;
	IRCUser			*me;
	int				missedMessages;
	IRCProtocol		*protocol;
}

- (id) initWithHost:(NSString*)host andPort:(NSString*)port;
- (bool) connect;
- (IRCChannel*) joinChannel:(NSString*)name;
- (void) disconnect;
- (void) send:(NSString*)cmd;
- (void) addObserver:(id)observer selector:(SEL)selector message:(IRCMessage*)message;
- (void) addObserver:(id)observer selector:(SEL)selector pattern:(id)pattern;
- (void) removeObserver:(id)observer;
- (void) removeObserver:(id)observer selector:(SEL)selector message:(IRCMessage*)message;

- (NSArray*) knownUsers;
- (void) addUser:(IRCUser*)user;
- (void) removeUser:(IRCUser*)user;

@property(readonly)	NSString	*serverName;
@property(readonly)	NSString	*host;
@property(readonly)	NSString	*port;
@property(readwrite, copy)	NSString	*nick;
@property(readonly)			bool		isConnected;
@property(readonly)	NSMutableArray*channels;
@property(readonly) IRCUser *me;
@property(readonly) IRCProtocol *protocol;
@property(readonly) NSArray	*messages;

- (char *)readLine;

/* For Debug */
- (NSArray*) registerdObservers;
- (int) missedMessages;

@end

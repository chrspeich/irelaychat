//
//  IRCServer.h
//  iRelayChat
//
//  Created by Christian Speich on 17.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *IRCConnected;
extern NSString *IRCDisconnected;
extern NSString *IRCJoinChannel;
extern NSString *IRCLeaveChannel;
extern NSString *IRCUserQuit;

@class IRCChannel;
@class IRCMessage;
@class IRCUser;

@interface IRCServer : NSObject {
	NSString		*host;
	NSString		*port;
	NSString		*serverName;
	NSString		*nick;
	bool			isConnected;
	NSMutableArray	*channels;
	NSMutableArray	*observerObjects;
	NSMutableArray	*knownUsers;
	int				sock;
}

- (id) initWithHost:(NSString*)host andPort:(NSString*)port;
- (bool) connect;
- (IRCChannel*) joinChannel:(NSString*)name;
- (void) disconnect;
- (void) send:(NSString*)cmd;
- (void) addObserver:(id)observer selector:(SEL)selector message:(IRCMessage*)message;
- (void) removeObserver:(id)observer;
- (void) removeObserver:(id)observer selector:(SEL)selector message:(IRCMessage*)message;

- (NSArray*) knownUsers;
- (void) addUser:(IRCUser*)user;
- (void) removeUser:(IRCUser*)user;

@property(readonly,copy)	NSString	*serverName;
@property(readonly,copy)	NSString	*host;
@property(readonly,copy)	NSString	*port;
@property(readwrite,copy)	NSString	*nick;
@property(readonly)			bool		isConnected;
@property(readonly,retain)	NSMutableArray*channels;

- (char *)readLine;

@end

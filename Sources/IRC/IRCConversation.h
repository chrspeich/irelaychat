//
//  IRCConversation.h
//  iRelayChat
//
//  Created by Christian Speich on 03.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IRCServer;
@class IRCConversationMessage;

extern NSString *IRCConversationNewMessage;

@interface IRCConversation : NSObject {
	NSString		*name;
	IRCServer		*server;
	NSMutableArray	*_messages;
}

@property(readonly)	NSString	*name;
@property(readonly)	IRCServer	*server;
@property(readonly) NSArray		*messages;

- (id) initWithName:(NSString*)name onServer:(IRCServer*)server;
- (void) sendMessage:(NSString*)message;

- (bool) supportInputField;
- (bool) hasUserList;

- (void) registerObservers;
- (id) privMsgPattern;

// To be sure that we are KVO complimant we use an method
// which will send our KVO-notifications and normal
// Notifications via NSNotificationCenter
- (void) addMessage:(IRCConversationMessage*)message;

@end

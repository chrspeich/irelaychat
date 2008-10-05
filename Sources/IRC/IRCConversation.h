//
//  IRCConversation.h
//  iRelayChat
//
//  Created by Christian Speich on 03.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IRCServer;

extern NSString *IRCConversationNewMessage;

@interface IRCConversation : NSObject {
	NSString		*name;
	IRCServer		*server;
	NSMutableArray	*messages;
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

@end

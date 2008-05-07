//
//  IRCMessage.h
//  iRelayChat
//
//  Created by Christian Speich on 18.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class IRCUser;
@class IRCServer;

@interface IRCMessage : NSObject {
	IRCUser			*from;
	NSString			*command;
	NSMutableArray		*parameters;
	NSStringEncoding	encoding;
	char				*orgMessage;
	IRCServer			*server;
}

- (id)initWithCommand:(NSString*)command from:(IRCUser*)from andPrarameters:(NSArray*)parameters;
- (id)initWithOrginalMessage:(char*)message withEncoding:(NSStringEncoding)enc andServer:(IRCServer*)_server;

@property(readonly)		IRCUser				*from;
@property(readonly)		NSString			*command;
@property(readonly)		NSArray				*parameters;
@property(readonly)		char				*orgMessage;
@property(readonly)		IRCServer			*server;
@property(readwrite)	NSStringEncoding	encoding;

- (bool)isEqualToMessage:(IRCMessage*)message;
- (void)parseMessage;

@end

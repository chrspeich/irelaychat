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

- (id)initWithCommand:(NSString*)command from:(IRCUser*)from andPrarameters:(NSArray*)parameters  DEPRECATED_ATTRIBUTE;
- (id)initWithOrginalMessage:(char*)message withEncoding:(NSStringEncoding)enc andServer:(IRCServer*)_server DEPRECATED_ATTRIBUTE;

@property(readonly)		IRCUser				*from  DEPRECATED_ATTRIBUTE;
@property(readonly)		NSString			*command  DEPRECATED_ATTRIBUTE;
@property(readonly)		NSArray				*parameters  DEPRECATED_ATTRIBUTE;
@property(readonly)		char				*orgMessage  DEPRECATED_ATTRIBUTE;
@property(readonly)		IRCServer			*server  DEPRECATED_ATTRIBUTE;
@property(readwrite)	NSStringEncoding	encoding  DEPRECATED_ATTRIBUTE;

- (bool)isEqualToMessage:(IRCMessage*)message  DEPRECATED_ATTRIBUTE;
- (void)parseMessage  DEPRECATED_ATTRIBUTE;

@end

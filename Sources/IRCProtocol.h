//
//  IRCProtocol.h
//  iRelayChat
//
//  Created by Christian Speich on 12.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IRCServer;

@interface IRCProtocol : NSObject {
	IRCServer *server;
}

- (id) initWithServer:(IRCServer*)server;

- (id) patternNameReplyForChannel:(NSString*)channel;
- (id) patternNameReplyEndForChannel:(NSString*)channel;
- (id) patternPirvmsgFor:(NSString*)userOrChannel;
- (id) patternJoinForChannel:(NSString*)channel;
- (id) patternPartForChannel:(NSString*)channel;
- (id) patternModeForChannel:(NSString*)channel;
- (id) patternQuit;
- (id) patternPing;
- (id) patternNick;

- (NSString*) pongTo:(NSString*)user;
- (NSString*) nickTo:(NSString*)nick;
- (NSString*) user:(NSString*)user andRealName:(NSString*)realname;

@end

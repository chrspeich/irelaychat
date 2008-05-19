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
- (NSString*) namesFor:(NSString*)channel;
- (id) privMsg:(NSString*)message to:(NSString*)userOrChannel;

@property(readonly) int maxLineLength;

@end

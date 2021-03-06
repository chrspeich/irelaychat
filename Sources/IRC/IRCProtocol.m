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

#import "IRCProtocol.h"
#import "IRCServer.h"
#import "IRCUser.h"

@implementation IRCProtocol

- (id) initWithServer:(IRCServer*)inServer
{
	self = [super init];
	if (self != nil) {
		server = inServer;
	}
	return self;
}


- (id) patternNameReplyForChannel:(NSString*)channel
{
	return [NSString stringWithFormat:@"^(?i):(?<from>.+)\\s353\\s%@\\s=\\s%@\\s:(?<nicks>.*)$", server.me.nickname, channel];
}

- (id) patternNameReplyEndForChannel:(NSString*)channel
{
	return [NSString stringWithFormat:@"^(?i):(?<from>.+)\\s366\\s%@\\s%@\\s:(?<nicks>.*)$", server.me.nickname, channel];
}

- (id) patternPirvmsgTo:(NSString*)channel
{
	return [NSString stringWithFormat:@"^(?i):(?<from>.+)\\sPRIVMSG\\s%@\\s:(?<message>.*)$", channel];
}

- (id) patternPirvmsgFrom:(NSString*)user to:(NSString*)name
{
	return [NSString stringWithFormat:@"^(?i):(?<from>%@!.*)\\sPRIVMSG\\s%@\\s:(?<message>.*)$", user, name];
}

- (id) patternJoinForChannel:(NSString*)channel
{
	return [NSString stringWithFormat:@"^(?i):(?<from>.+)\\sJOIN\\s:%@$", channel];
}

- (id) patternPartForChannel:(NSString*)channel
{
	return [NSString stringWithFormat:@"^(?i):(?<from>.+)\\sPART\\s%@\\s:(?<reason>.*)$", channel];
}

- (id) patternModeForChannel:(NSString*)channel
{
	return [NSString stringWithFormat:@"^(?i):(?<from>.+)\\sMODE\\s%@\\s(?<change>[+-])(?<mode>.+)\\s(?<to>[\\S]+).*$", channel];
}

- (id) patternQuit
{
	return @"^(?i):(?<from>.+)\\sQUIT\\s:(?<reason>.*)$";
}

- (id) patternNick
{
	return @"^(?i):(?<from>.+)\\sNICK\\s:(?<to>.+)$";
}

- (id) patternPing
{
	return @"^(?i)PING\\s(?<user>.+)$";
}

- (NSString*) pongTo:(NSString*)user
{
	return [NSString stringWithFormat:@"PONG %@\r\n", user];
}

- (NSString*) nickTo:(NSString*)nick
{
	return [NSString stringWithFormat:@"NICK %@\r\n", nick];
}

- (NSString*) user:(NSString*)user andRealName:(NSString*)realname
{
	return [NSString stringWithFormat:@"USER %@ 0 * :%@\r\n", user, realname];
}

- (NSString*) namesFor:(NSString*)channel
{
	return [NSString stringWithFormat:@"NAMES %@\r\n", channel];
}

- (id) privMsg:(NSString*)message to:(NSString*)userOrChannel
{
	int allowdMessageLengthPerCommand = self.maxLineLength - strlen("PRIVMSG")
										- [userOrChannel length]
										- 3 /* 2 SPACES + : */
										- 2 /* \r\n */;
	NSMutableArray *commands = [NSMutableArray array];
	
	for (int i = 0; i < (float)[message length]/(float)allowdMessageLengthPerCommand; i++) {
		NSMutableString *command = [NSMutableString string];

		[command appendFormat:@"PRIVMSG %@ :",userOrChannel];
		NSRange range;
		range.location = allowdMessageLengthPerCommand*i;
		range.length = allowdMessageLengthPerCommand;

		if (range.length+range.location > [message length])
			range.length = [message length] - range.location;
		
		[command appendString:[message substringWithRange:range]];
		[command appendString:@"\r\n"];
		[commands addObject:command];
	}
	
	return commands;
}

- (NSString*) joinChannel:(NSString*)name
{
	return [NSString stringWithFormat:@"JOIN %@\r\n", name];
}

- (int) maxLineLength
{
	return 512;
}

@end

//
//  IRCProtocol.m
//  iRelayChat
//
//  Created by Christian Speich on 12.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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

- (id) patternPirvmsgFor:(NSString*)userOrChannel
{
	return [NSString stringWithFormat:@"^(?i):(?<from>.+)\\sPRIVMSG\\s%@\\s:(?<message>.*)$", userOrChannel];
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

@end

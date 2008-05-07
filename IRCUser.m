//
//  IRCUser.m
//  iRelayChat
//
//  Created by Christian Speich on 05.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCUser.h"
#import "IRCServer.h"

@interface IRCUser (PRIVATE)
- (id) initWithString:(NSString*)string onServer:(IRCServer*)server;
- (id) initWithNickname:(NSString*)string onServer:(IRCServer*)server;
@end

@implementation IRCUser

@synthesize nickname, user, host;

- (id) initWithString:(NSString*)string onServer:(IRCServer*)_server;
{
	self = [super init];
	if (self != nil) {	
		NSArray *firstComponents = [string componentsSeparatedByString:@"!"];
		if ([firstComponents count] < 2) {
			[self release];
			return nil;
		}
		NSArray *secondComponents = [[firstComponents objectAtIndex:1] componentsSeparatedByString:@"@"];
		if ([secondComponents count] < 2) {
			[self release];
			return nil;
		}
		
		nickname = [[firstComponents objectAtIndex:0] copy];
		user = [[secondComponents objectAtIndex:0] copy];
		host = [[secondComponents objectAtIndex:1] copy];
		
		server = _server;
		
		if (server) {
			[server addUser:self];
		}
	}
	return self;
}

- (id) initWithNickname:(NSString*)string onServer:(IRCServer*)_server;
{
	self = [super init];
	if (self != nil) {	
		nickname = string;
		user = nil;
		host = nil;
		
		server = _server;
		
		if (server) {
			[server addUser:self];
		}
	}
	return self;
}


- (bool) isMe
{
	// This is later for subclassing as IRCMeUser ;)
	return NO;
}

- (NSString*) string
{
	return [[[NSString alloc] initWithFormat:@"%@!%@@%@", nickname, user, host] autorelease];
}

- (bool) isEqualToUser:(IRCUser*)_user
{
	return (self.nickname == _user.nickname);
}

+ (id) userWithString:(NSString*)string onServer:(IRCServer*)server
{
	IRCUser *user = nil;
	IRCUser *searchForUser = [[self alloc] initWithString:string onServer:nil];
	
	if (!server)
		return nil;
		
	for (IRCUser *tmp in [server knownUsers]) {
		if ([tmp isEqualToUser:searchForUser]) {
			user = [tmp retain];
			break;
		}
	}
	[searchForUser release];
	
	if (!user) {
		user = [[self alloc] initWithString:string onServer:server];
	}
	else {
		[user retain];
	}
	
	return [user autorelease];
}

+ (id) userWithNickname:(NSString*)name onServer:(IRCServer*)server
{
	IRCUser *user = nil;
	IRCUser *searchForUser = [[self alloc] initWithNickname:name onServer:nil];

	if (!server)
		return nil;
		
	for (IRCUser *tmp in [server knownUsers]) {
		if ([tmp.nickname isEqualToString:name]) {
			user = [tmp retain];
			break;
		}
	}
	[searchForUser release];
	
	if (!user) {
		user = [[self alloc] initWithNickname:name onServer:server];
	}
	else {
		[user retain];
	}
	
	return [user autorelease];
}

@end

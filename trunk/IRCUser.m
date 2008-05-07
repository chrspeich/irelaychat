//
//  IRCUser.m
//  iRelayChat
//
//  Created by Christian Speich on 05.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCUser.h"
#import "IRCServer.h"
#import "IRCUserMode.h"
#import "IRCChannel.h"
#import "IRCMessage.h"

NSString *IRCUserChanged = @"iRelayChat-IRCUserChanged";

@interface IRCUser (PRIVATE)
- (id) initWithString:(NSString*)string onServer:(IRCServer*)server;
- (id) initWithNickname:(NSString*)string onServer:(IRCServer*)server;
- (void) setupObservers;
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
		if ([nickname characterAtIndex:0] == '+' || [nickname characterAtIndex:0] == '@') {
			NSMutableString *tmp = [nickname mutableCopy];
			[nickname release];
			[tmp deleteCharactersInRange:NSMakeRange(0, 1)];
			nickname = [tmp copy];
			[tmp release];
		}
		user = [[secondComponents objectAtIndex:0] copy];
		host = [[secondComponents objectAtIndex:1] copy];
		userModes = [[NSMutableDictionary alloc] init];
		
		server = _server;
		
		if (server) {
			[server addUser:self];
		}
		[self setupObservers];
	}
	return self;
}

- (id) initWithNickname:(NSString*)string onServer:(IRCServer*)_server;
{
	self = [super init];
	if (self != nil) {	
		nickname = [string copy];
		user = nil;
		host = nil;
		userModes = [[NSMutableDictionary alloc] init];
		
		if ([nickname characterAtIndex:0] == '+' || [nickname characterAtIndex:0] == '@') {
			NSMutableString *tmp = [nickname mutableCopy];
			[nickname release];
			[tmp deleteCharactersInRange:NSMakeRange(0, 1)];
			nickname = [tmp copy];
			[tmp release];
		}
		
		server = _server;
		
		if (server) {
			[server addUser:self];
		}
		[self setupObservers];
	}
	return self;
}

- (void) setupObservers
{
	[server removeObserver:self];
	[server addObserver:self selector:@selector(nickNameChanged:) message:[[IRCMessage alloc] initWithCommand:@"NICK" from:self andPrarameters:nil]];
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
	return [self.nickname isEqualToString:_user.nickname];
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

- (IRCUserMode*) userModeForChannel:(IRCChannel*)channel
{
	return [userModes objectForKey:channel.name];
}

- (void) setUserMode:(IRCUserMode*)userMode forChannel:(IRCChannel*)channel
{
	[userModes setObject:userMode forKey:channel.name];
}

- (void) nickNameChanged:(IRCMessage*)message
{
	[nickname release];
	[server removeUser:message.from];
	NSLog(@"test");
	nickname = [[message.parameters objectAtIndex:0] copy];
	[self setupObservers];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserChanged object:self];
}

@end

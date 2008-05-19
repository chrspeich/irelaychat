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

#import <ScreenSaver/ScreenSaver.h>
#import "IRCUser.h"
#import "IRCServer.h"
#import "IRCUserMode.h"
#import "IRCChannel.h"

NSString *IRCUserChanged = @"iRelayChat-IRCUserChanged";

@interface IRCUser (PRIVATE)
- (id) initWithString:(NSString*)string onServer:(IRCServer*)server;
- (id) initWithNickname:(NSString*)string onServer:(IRCServer*)server;
- (void) setupObservers;
@end

@implementation IRCUser

@synthesize nickname, user, host, server;

- (id) initWithString:(NSString*)string onServer:(IRCServer*)_server;
{
	self = [super init];
	if (self != nil) {	
		NSArray *firstComponents = [string componentsSeparatedByString:@"!"];
		if ([firstComponents count] < 2) {
			nickname = [string copy];
			user = nil;
			host = nil;
			userModes = [[NSMutableDictionary alloc] init];
		}
		else {
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
		}
		
		color = nil;
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
		
		color = nil;
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
//	[server addObserver:self selector:@selector(nickNameChanged:) message:[[IRCMessage alloc] initWithCommand:@"NICK" from:self andPrarameters:nil]];
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
	user.host = searchForUser.host;
	user.user = searchForUser.user;
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
		if ([tmp isEqualToUser:searchForUser]) {
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

- (NSColor*) color
{
	if (!color) {
		color = [NSColor colorWithDeviceRed:SSRandomFloatBetween(0.f,1.f) green:SSRandomFloatBetween(0.f,1.f) blue:SSRandomFloatBetween(0.f,1.f) alpha:1.f];
		[color retain];
	}
	return color;
}

@end

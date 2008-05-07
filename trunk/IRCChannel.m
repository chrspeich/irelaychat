//
//  IRCChannel.m
//  iRelayChat
//
//  Created by Christian Speich on 17.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCChannel.h"
#import "IRCServer.h"
#import "IRCMessage.h"
#import "IRCUser.h"

NSString *IRCUserListHasChanged  = @"iRelayChat-IRCUserListHasChanged";
NSString *IRCNewChannelMessage = @"iRelayChat-IRCNewChannelMessage";
NSString *IRCUserJoinsChannel = @"iRelayChat-IRCUserJoinsChannel";
NSString *IRCUserLeavesChannel = @"iRelayChat-IRCUserLeavesChannel";

@implementation IRCChannel

@synthesize name, server, userList;

- (id) initWithServer:(IRCServer*)_server andName:(NSString*)_name;
{
	self = [super init];
	if (self != nil) {
		name = _name;
		server = _server;
		tmpUserList = nil;
		userList = nil;
		
		NSMutableArray *para = [[NSMutableArray alloc] init];
		[para addObject:@"*"];
		[para addObject:@"*"];
		[para addObject:name];
		
		[server addObserver:self selector:@selector(userList:) message:[[IRCMessage alloc] initWithCommand:@"353" from:nil andPrarameters:para]];
		[para release];
		
		para = [[NSMutableArray alloc] init];
		[para addObject:@"*"];
		[para addObject:name];
		[server addObserver:self selector:@selector(userListEnd:) message:[[IRCMessage alloc] initWithCommand:@"366" from:nil andPrarameters:para]];
		[para release];
		
		para = [[NSMutableArray alloc] init];
		[para addObject:name];
		[server addObserver:self selector:@selector(channelMessage:) message:[[IRCMessage alloc] initWithCommand:@"PRIVMSG" from:nil andPrarameters:para]];
		[para release];
		
		para = [[NSMutableArray alloc] init];
		[para addObject:name];
		[server addObserver:self selector:@selector(userJoin:) message:[[IRCMessage alloc] initWithCommand:@"JOIN" from:nil andPrarameters:para]];
		[para release];
		
		para = [[NSMutableArray alloc] init];
		[para addObject:name];
		[server addObserver:self selector:@selector(userLeave:) message:[[IRCMessage alloc] initWithCommand:@"PART" from:nil andPrarameters:para]];
		[para release];
		
		[server send:[NSString stringWithFormat:@"JOIN %@", name]];
		[[NSNotificationCenter defaultCenter] postNotificationName:IRCJoinChannel object:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userQuits:) name:IRCUserQuit object:self.server];
		[NSTimer scheduledTimerWithTimeInterval:120.f target:self selector:@selector(reloadUserList) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) reloadUserList
{
	[server send:[NSString stringWithFormat:@"NAMES %@", name]];
}

- (void) sendMessage:(NSString*)message
{
	[server send:[NSString stringWithFormat:@"PRIVMSG %@ :%@", name, message]];
}

- (void) userList:(IRCMessage*)message
{
	if (!tmpUserList)
		tmpUserList = [[NSMutableArray alloc] init];
	
	[tmpUserList addObjectsFromArray:[[message.parameters objectAtIndex:3] componentsSeparatedByString:@" "]];
}

- (void) userListEnd:(IRCMessage*)message
{
	[tmpUserList sortUsingSelector:@selector(compare:)];
	if ([userList isEqualToArray:tmpUserList])
		NSLog(@"Nothing to change!");
	else
		NSLog(@"Something to change!");
	[userList release];
	userList = [tmpUserList mutableCopy];
	[tmpUserList release];
	tmpUserList = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
}

- (void) channelMessage:(IRCMessage*)message
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:message.from forKey:@"FROM"];
	[dict setObject:[message.parameters objectAtIndex:1] forKey:@"MESSAGE"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCNewChannelMessage object:self userInfo:dict];
}

- (void) userJoin:(IRCMessage*)message
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:message.from forKey:@"FROM"];
	[userList addObject:[message.from nickname]];
	[userList sortUsingSelector:@selector(compare:)];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserJoinsChannel object:self userInfo:dict];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
}

- (void) userLeave:(IRCMessage*)message
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:message.from forKey:@"FROM"];
	[userList removeObject:[message.from nickname]];
	[userList sortUsingSelector:@selector(compare:)];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserLeavesChannel object:self userInfo:dict];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
}

- (void) userQuits:(NSNotification*)noti
{
	[userList removeObject:[[noti userInfo] objectForKey:@"FROM"]];
	[userList sortUsingSelector:@selector(compare:)];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
}

@end

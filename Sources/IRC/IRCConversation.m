//
//  IRCConversation.m
//  iRelayChat
//
//  Created by Christian Speich on 03.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCConversation.h"
#import "IRCServer.h"
#import "IRCProtocol.h"
#import "IRCUser.h"
#import "IRCConversationMessage.h"

NSString *IRCConversationNewMessage = @"iRelayChat-IRCConversationNewMessage";

@interface IRCConversation (PRIVATE)


@end


@implementation IRCConversation

@synthesize name, server, messages;

- (id) initWithName:(NSString*)_name onServer:(IRCServer*)_server
{
	self = [super init];
	if (self != nil) {
		name = [_name retain];
		server = _server;
		
		messages = [[NSMutableArray alloc] init];
		
		[self registerObservers];
	}
	return self;
}

- (void) registerObservers
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[server removeObserver:self];
	[nc removeObserver:self];
	
	[server addObserver:self 
			   selector:@selector(newPrivmsg:) 
				pattern:[self privMsgPattern]];
	
	[nc addObserver:self 
		   selector:@selector(userQuits:) 
			   name:IRCUserQuit 
			 object:server];
	[nc addObserver:self 
		   selector:@selector(userChanged:) 
			   name:IRCUserChanged 
			 object:nil];
}

- (void) dealloc
{
	// Remove all Observations
	[server removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[name release];
	[messages release];
	
	[super dealloc];
}

- (bool) hasUserList
{
	return NO;
}

- (bool) supportInputField
{
	return YES;
}

- (void) sendMessage:(NSString*)message
{
	NSString *messageString = nil;
	IRCConversationMessage *mess;
	
	if ([message characterAtIndex:0] == '/') {
		// Do some stuff for resolving commando
		
	} else 
		messageString = message;
	
	if (!messageString)
		return;
	
	id commands = [server.protocol privMsg:messageString to:name];
	
	[server send:commands];
		
	mess = [[IRCConversationMessage alloc] initWithMessage:messageString fromUser:server.me];
	
	mess.conversation = self;
	mess.date = [NSDate date];
	
	[messages addObject:mess];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCConversationNewMessage 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:mess forKey:@"MESSAGE"]];
	
	[mess release];
}

- (void) newPrivmsg:(NSDictionary*)messageDict
{
	IRCConversationMessage *ircMessage;
	NSString *from;
	NSString *message;
	
	[[messageDict objectForKey:@"MESSAGE"]
	 getCapturesWithRegexAndReferences:[self privMsgPattern],@"${from}",&from,@"${message}",&message,nil];
	
	ircMessage = [[IRCConversationMessage alloc] initWithMessage:message 
														fromUser:[IRCUser userWithString:from onServer:self.server]];
	
	ircMessage.conversation = self;
	ircMessage.date = [messageDict objectForKey:@"TIME"];
	
	[messages addObject:ircMessage];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCConversationNewMessage 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:ircMessage forKey:@"MESSAGE"]];

	[ircMessage release];
}

- (bool) isLeaf
{
	return YES;
}

- (NSArray*) userList
{
	return [NSArray array];
}

- (id) privMsgPattern
{
	return [server.protocol patternPirvmsgFrom:name to:server.me.nickname];
}

@end

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

@synthesize name, server, messages=_messages;

- (id) initWithName:(NSString*)_name onServer:(IRCServer*)_server
{
	self = [super init];
	if (self != nil) {
		name = [_name retain];
		server = _server;
		
		_messages = [[NSMutableArray alloc] init];
		
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
	[_messages release];
	
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
	
	[self addMessage:mess];

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
	
	[self addMessage:ircMessage];

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

// To be sure that we are KVO complimant we use an method
// which will send our KVO-notifications and normal
// Notifications via NSNotificationCenter
- (void) addMessage:(IRCConversationMessage*)message
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSMutableArray *messages;
	// We do not add nil or so
	if (!message)
		return;
	
	// Get an mutable KVO complimant Array
	messages = [self mutableArrayValueForKey:@"messages"];
	
	// Add our message, the array (ok, it's a proxy) will send all
	// KVO notifications
	[messages addObject:message];
	
	// So, now send a Noficication and privide via userInfo the new
	// message
	[nc postNotificationName:IRCConversationNewMessage 
					  object:self 
					userInfo:[NSDictionary dictionaryWithObject:message 
														 forKey:@"MESSAGE"]];
}

@end

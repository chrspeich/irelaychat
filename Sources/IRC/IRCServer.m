//
//  IRCServer.m
//  iRelayChat
//
//  Created by Christian Speich on 17.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCServer.h"
#import "IRCMessage.h"
#import "IRCObserveContainer.h"
#import "IRCChannel.h"
#import "IRCMeUser.h"
#import "IRCProtocol.h"
#include <sys/socket.h>

NSString *IRCConnected = @"iRelayChat-IRCConnected";
NSString *IRCDisconnected = @"iRelayChat-IRCDisonnected";
NSString *IRCJoinChannel = @"iRelayChat-IRCJoinChannel";
NSString *IRCLeaveChannel = @"iRelayChat-IRCLeaveChannel";
NSString *IRCUserQuit = @"iRelayChat-IRCUserQuit";

@implementation IRCServer

@synthesize serverName, host, port, isConnected, channels, me, protocol, messages;

- (id) initWithHost:(NSString*)_host andPort:(NSString*)_port;
{
	self = [super init];
	if (self != nil) {
		host = [_host retain];
		port = [_port retain];
		isConnected = NO;
		channels = [[NSMutableArray alloc] init];
		nick = @"kleinw2by";
		serverName = @"FreeNode";
		observerObjects = [[NSMutableArray alloc] init];
		knownUsers = [[NSMutableArray alloc] init];
		messages = [[NSMutableArray alloc] init];
		protocol = [[IRCProtocol alloc] initWithServer:self];
		me = [IRCMeUser userWithNickname:nick onServer:self];
		missedMessages = 0;
		[self addObserver:self selector:@selector(ping:) pattern:[self.protocol patternPing]];
		[self addObserver:self selector:@selector(userQuit:) pattern:[self.protocol patternQuit]];
		[self addObserver:self selector:@selector(changeUserName:) pattern:[self.protocol patternNick]];
	}
	return self;
}

- (bool) connect
{
	struct sockaddr_in address;
	struct in_addr inaddr;
	struct hostent *_host;
	int status;
	//freenode=140.211.166.3
	if (!inet_aton("140.211.166.3", &inaddr)) {
		NSLog(@"inet_aton fails");
		return NO;
	}
	
	_host = gethostbyaddr(&inaddr, sizeof(inaddr), AF_INET);
	if (!_host) {
		NSLog(@"gethostbyaddr fails");
		return NO;
	}
	
	sock = socket(PF_INET, SOCK_STREAM, 0);
	if (sock < 0) {
		NSLog(@"socket fails");
		return NO;
	}
	
	address.sin_family = AF_INET;
	address.sin_port = htons(6667);
	
	memcpy(&address.sin_addr, _host->h_addr_list[0], sizeof(address.sin_addr));
	
	status = connect(sock, (struct sockaddr *)&address, sizeof(address));
	if (status != 0) {
		NSLog(@"connect fails");
		perror("connect");
		return NO;
	}
	
	isConnected = YES;
	
	[NSThread detachNewThreadSelector:@selector(runLoop) toTarget:self withObject:nil];
	
	[self send:[self.protocol nickTo:nick]];
	[self send:[self.protocol user:nick andRealName:@"Christian Speich"]];
	
	return YES;
}

- (void) send:(NSString*)cmd
{
	NSString *sendCmd = [[NSString alloc] initWithFormat:@"%@\n", cmd];
	printf("< %s", [sendCmd UTF8String]);
	send(sock, [sendCmd UTF8String], strlen([sendCmd UTF8String]), 0);
	[sendCmd release];
}

- (void) runLoop
{
	while(1) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		fd_set read_fd, execpt_fd;
		FD_ZERO(&read_fd);
		FD_SET(sock, &read_fd);
		FD_ZERO(&execpt_fd);
		FD_SET(sock, &execpt_fd);
	
		select(sock+1, &read_fd, NULL, &execpt_fd, NULL);

		if ([[NSThread currentThread] isCancelled])
			[NSThread exit];
		
		if (FD_ISSET(sock, &read_fd)) {
			char *line;
			
			line = [self readLine];
			
			printf("> %s\n", line);
			fflush(0);
			
			IRCMessage *message = [[IRCMessage alloc] initWithOrginalMessage:line withEncoding:NSUTF8StringEncoding andServer:self];
			
			NSString *messageLine = [NSString stringWithCString:message.orgMessage encoding:message.encoding];
						
			int matched = 0;
			
			@synchronized(observerObjects)
			{
				for (IRCObserveContainer *container in observerObjects) {
					if (container.message && [container.message isEqualToMessage:message]) {
						[container.observer performSelectorOnMainThread:container.selector withObject:message waitUntilDone:NO];
						matched++;
					}
					else if (container.pattern && [messageLine isMatchedByRegex:container.pattern]) {
						[container.observer performSelectorOnMainThread:container.selector withObject:messageLine waitUntilDone:NO];
						matched++;
					}
				}
			}
			
			NSDictionary *dict;
			NSDate *date = [NSDate date];

			if (matched < 2) {
				missedMessages++;
				dict = [NSDictionary dictionaryWithObjectsAndKeys:messageLine,@"MESSAGE",[date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],@"TIME",@"YES",@"MISSED",nil];
			}
			else
				dict = [NSDictionary dictionaryWithObjectsAndKeys:messageLine,@"MESSAGE",[date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],@"TIME",@"NO",@"MISSED",nil];
			
			[messages addObject:dict];
			
			[message release];
			free(line);
		}
		[pool release];
	}
}

- (NSString*)nick
{
	return [nick copy];
}

- (void)setNick:(NSString*)_nick
{
	nick = [_nick copy];
	if (self.isConnected)
		[self send:[NSString stringWithFormat:@"NICK %@", nick]];
}

- (IRCChannel*) joinChannel:(NSString*)name
{
	IRCChannel* channel = [[IRCChannel alloc] initWithServer:self
													 andName:name];
	[channels addObject:channel];
	return channel;
}

- (void) disconnect
{
	isConnected = NO;
	[self send:@"QUIT"];
	close(sock);
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCDisconnected object:self];
}

- (void) addObserver:(id)observer selector:(SEL)selector message:(IRCMessage*)message
{
	IRCObserveContainer *container = [[IRCObserveContainer alloc] init];
	container.selector = selector;
	container.observer = observer;
	container.message = message;
	@synchronized(observerObjects)
	{
		[observerObjects addObject:container];
	}
	[container release];
}

- (void) addObserver:(id)observer selector:(SEL)selector pattern:(id)pattern
{
	IRCObserveContainer *container = [[IRCObserveContainer alloc] init];
	container.selector = selector;
	container.observer = observer;
	container.pattern = pattern;
	@synchronized(observerObjects)
	{
		[observerObjects addObject:container];
	}
	[container release];
}

- (void) removeObserver:(id)observer
{
	@synchronized(observerObjects) 
	{
		for (IRCObserveContainer* container in observerObjects) {
			if (container.observer == observer)
				[observerObjects removeObject:container];
		}
	}
}

- (void) removeObserver:(id)observer selector:(SEL)selector message:(IRCMessage*)message;
{
	@synchronized(observerObjects)
	{
		for (IRCObserveContainer* container in observerObjects) {
			if (container.observer == observer &&
				container.selector == selector &&
				[message isEqualToMessage:container.message])
				[observerObjects removeObject:container];
		}
	}
}

- (NSArray*) registerdObservers
{
	return observerObjects;
}

- (int) missedMessages
{
	return missedMessages;
}

- (void) ping:(NSString*)messageLine
{
	NSString *user = NULL;
	/* Just ping back to the Server */
	
	[messageLine getCapturesWithRegexAndReferences:[self.protocol patternPing],@"${user}",&user,nil];
	
	[self send:[self.protocol pongTo:user]];
}

- (void) userQuit:(NSString*)messageLine
{
	NSString *from = NULL, *reason = NULL;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	[messageLine getCapturesWithRegexAndReferences:[self.protocol patternQuit],@"${from}",&from,@"${reason}",&reason,nil];
	
	[dict setObject:[IRCUser userWithString:from onServer:self] forKey:@"FROM"];
	[dict setObject:reason forKey:@"MESSAGE"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserQuit object:self userInfo:dict];
}

- (NSArray*) knownUsers
{
	NSArray *copy = [knownUsers copy];
	return [copy autorelease];
}

- (void) addUser:(IRCUser*)user
{
	[user retain];
	[knownUsers addObject:user];
}

- (void) changeUserName:(NSString*)messageLine
{
	IRCUser *user;
	NSString *from = NULL, *to = NULL;
	
	[messageLine getCapturesWithRegexAndReferences:[self.protocol patternNick],@"${from}",&from,@"${to}",&to,nil];

	user = [IRCUser userWithString:from onServer:self];
	NSLog(@"TO: %@", to);
	user.nickname = to;
}

- (void) removeUser:(IRCUser*)user
{
	[knownUsers removeObject:user];
}

#define IRC_MAX_LINE_LENGTH 512

- (char *) readLine
{
	char *line;
	int i;
	bool cr;
	char c;
	
	line = malloc(IRC_MAX_LINE_LENGTH*sizeof(char));
	
	for (i = 0; i < IRC_MAX_LINE_LENGTH; i++) {
		if (recv(sock, &c, 1, 0) == -1) {
			free(line);
			return NULL;
		}
		
		if (i >= IRC_MAX_LINE_LENGTH) {
			NSLog(@"The Server '%@' sends Message against RFC 2812! Skip message.", self.host);
			free(line);
			return NULL;
		}
		
		if (c == '\n') {
			/* if there is a \r befor overwrite it */
			if (cr) {
				i--;
			}
			
			line[i] = '\0';
			break;
		}
		else {
			cr = (c == '\r');
			line[i] = c;
		}
	}
	
	return line;
}

@end

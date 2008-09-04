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

#import "IRCServer.h"
#import "IRCChannel.h"
#import "IRCMeUser.h"
#import "IRCProtocol.h"
#import "InternetRelayChat.h"
#include <sys/socket.h>

NSString *IRCConnected = @"iRelayChat-IRCConnected";
NSString *IRCDisconnected = @"iRelayChat-IRCDisonnected";
NSString *IRCJoinChannel = @"iRelayChat-IRCJoinChannel";
NSString *IRCLeaveChannel = @"iRelayChat-IRCLeaveChannel";
NSString *IRCUserQuit = @"iRelayChat-IRCUserQuit";

@implementation IRCServer

@synthesize serverName, name=serverName, host, port, isConnected, channels, me, protocol, messages;

- (id) initWithHost:(NSString*)_host andPort:(NSString*)_port;
{
	self = [super init];
	if (self != nil) {
		[[[InternetRelayChat sharedInternetRelayChat] servers] addObject:self];
		host = [_host retain];
		port = [_port retain];
		isConnected = NO;
		channels = [[NSMutableArray alloc] init];
		nick = @"blablebl";
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
/*	socketPort = [[NSSocketPort alloc] initRemoteWithTCPPort: 6667 host: @"140.211.166.3"];
	
	if (![socketPort isValid])
		NSLog(@"is not valid");
	
	NSFileHandle* sHandle = [[NSFileHandle alloc] initWithFileDescriptor: [socketPort socket] closeOnDealloc: YES];

	[sHandle writeData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	sock = [sHandle fileDescriptor];
	
*/	struct sockaddr_in address;
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

- (void) send:(id)cmd
{
	if ([cmd isKindOfClass:[NSArray class]]) {
		for (NSString *command in cmd) {
			[self send:command];
		}
	}
	else if ([cmd isKindOfClass:[NSString class]]) {
		NSString *command;
		if ([cmd characterAtIndex:[cmd length]-1] != '\n') {
			command = [cmd stringByAppendingString:@"\r\n"];
			NSLog(@"Warning: Message has no \r\n at the end. Append it");
		} else
			command = cmd;
		
		printf("< %s", [command UTF8String]);
		send(sock, [command UTF8String], [command length], 0);
	}
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
			NSMutableDictionary *message;
			NSDate *date = [NSDate date];
			NSString *messageLine;
			int matched = 0;
			
			line = [self readLine];
			
			if ((int)line == EOF) {
				isConnected = NO;
				[NSThread exit];
			}
			
			messageLine = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
			
			if (!messageLine)
				messageLine = [NSString stringWithCString:line encoding:NSASCIIStringEncoding];
			
			printf("> %s\n", [messageLine UTF8String]);
			fflush(0);
			
			message = [NSMutableDictionary dictionary];
			
			[message setObject:messageLine forKey:@"MESSAGE"];
			[message setObject:date forKey:@"TIME"];
			
			@synchronized(observerObjects)
			{
				for (NSDictionary *dict in observerObjects) {
					if ([dict objectForKey:@"PATTERN"] && [messageLine isMatchedByRegex:[dict objectForKey:@"PATTERN"]]) {
						[[dict objectForKey:@"OBSERVER"] performSelectorOnMainThread:NSSelectorFromString([dict objectForKey:@"SELECTOR"]) withObject:message waitUntilDone:NO];
						matched++;
					}
				}
			}

			if (!matched) {
				missedMessages++;
				[message setObject:@"YES" forKey:@"MISSED"];
			}
			else
				[message setObject:@"NO" forKey:@"MISSED"];
			
			[messages addObject:message];
			
			@synchronized(observerObjects)
			{
				for (NSDictionary *dict in observerObjects) {
					if (![dict objectForKey:@"PATTERN"]) {
						[[dict objectForKey:@"OBSERVER"] performSelectorOnMainThread:NSSelectorFromString([dict objectForKey:@"SELECTOR"]) withObject:message waitUntilDone:NO];
						matched++;
					}
				}
			}
			
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

- (void) addObserver:(id)observer selector:(SEL)selector pattern:(id)pattern
{
	NSDictionary *dict = [[NSDictionary alloc] 
						  initWithObjectsAndKeys:	observer,@"OBSERVER",
								NSStringFromSelector(selector),@"SELECTOR",
													pattern,@"PATTERN",
													Nil];
	@synchronized(observerObjects)
	{
		[observerObjects addObject:dict];
	}
	[dict release];
}

- (void) removeObserver:(id)observer
{
	@synchronized(observerObjects) 
	{
		for (NSDictionary* dict in observerObjects) {
			if ([dict objectForKey:@"OBSERVER"] == observer)
				[observerObjects removeObject:dict];
		}
	}
}

- (void) removeObserver:(id)observer selector:(SEL)selector pattern:(NSString*)pattern;
{
	@synchronized(observerObjects)
	{
		for (NSDictionary* dict in observerObjects) {
			if ([dict objectForKey:@"OBSERVER"] == observer &&
				[[dict objectForKey:@"SELECTOR"] isEqualToString:NSStringFromSelector(selector)] &&
				[[dict objectForKey:@"PATTERN"] isEqualToString:pattern])
				[observerObjects removeObject:dict];
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

- (void) ping:(NSDictionary*)message
{
	NSString *user = NULL;
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	[messageLine getCapturesWithRegexAndReferences:[self.protocol patternPing],@"${user}",&user,nil];
	
	[self send:[self.protocol pongTo:user]];
}

- (void) userQuit:(NSDictionary*)message
{
	NSString *from = NULL, *reason = NULL;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	[messageLine getCapturesWithRegexAndReferences:[self.protocol patternQuit],@"${from}",&from,@"${reason}",&reason,nil];
	
	[dict setObject:[IRCUser userWithString:from onServer:self] forKey:@"FROM"];
	[dict setObject:reason forKey:@"MESSAGE"];
	[dict setObject:[message objectForKey:@"TIME"] forKey:@"TIME"];
		
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserQuit object:self userInfo:dict];
	
	[dict release];
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

- (void) changeUserName:(NSDictionary*)message
{
	IRCUser *user;
	NSString *from = NULL, *to = NULL;
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	[messageLine getCapturesWithRegexAndReferences:[self.protocol patternNick],@"${from}",&from,@"${to}",&to,nil];

	user = [IRCUser userWithString:from onServer:self];
	NSLog(@"TO: %@", to);
	user.nickname = to;
}

- (void) removeUser:(IRCUser*)user
{
	[knownUsers removeObject:user];
}

- (char *) readLine
{
	char *line;
	int i;
	bool cr;
	char c;
	
	line = malloc(protocol.maxLineLength*sizeof(char));
	
	for (i = 0; i < protocol.maxLineLength; i++) {
		if (recv(sock, &c, 1, 0) == -1) {
			free(line);
			return NULL;
		}
		
		if (c == 0) {
			NSLog(@"The Server '%@' has close the socket.", self.host);
			free(line);
			return (char*)EOF;
		}
		
		if (i >= protocol.maxLineLength) {
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

- (bool) isLeaf
{
	return NO;
}

- (bool) supportInputField
{
	return NO;
}

- (bool) hasUserList
{
	return NO;
}

- (NSArray*) userList
{
	return [NSArray array];
}

- (NSArray*) userModes
{
	return [NSArray array];
}

@end

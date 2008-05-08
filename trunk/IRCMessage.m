//
//  IRCMessage.m
//  iRelayChat
//
//  Created by Christian Speich on 18.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCMessage.h"
#import "IRCUser.h"

@implementation IRCMessage

@synthesize from, command, parameters, orgMessage, server;

- (id)initWithCommand:(NSString*)_command from:(IRCUser*)_from andPrarameters:(NSArray*)_parameters;
{
	self = [super init];
	if (self != nil) {
		command = [_command retain];
		from = [_from retain];
		parameters = [_parameters copy];
		orgMessage = NULL;
		self.encoding = NSUTF8StringEncoding;
	}
	return self;
}

- (id)initWithOrginalMessage:(char*)message withEncoding:(NSStringEncoding)enc andServer:(IRCServer*)_server
{
	self = [super init];
	if (self != nil) {
		orgMessage = malloc(strlen(message)*sizeof(char)+1);
		strlcpy(orgMessage,  message, strlen(message)+1);
		server = _server;
		self.encoding = enc;
	}
	return self;
}


- (bool)isEqualToMessage:(IRCMessage*)message
{
	if (from && ![from isEqualToUser:message.from])
		return NO;
	
	if (![command isEqualToString:@"*"] && ([command caseInsensitiveCompare:message.command] != NSOrderedSame))
		return NO;
	
	if ([parameters count] == 0 || [message.parameters count] == 0)
		return YES;
	
	if (!message.parameters || !self.parameters)
		return YES;
	
	NSUInteger i, count = ([parameters count]<[message.parameters count]?[parameters count]:[message.parameters count]);
	for (i = 0; i < count; i++) {
		NSString *string = [parameters objectAtIndex:i];
		NSString *compString = [message.parameters objectAtIndex:i];
		
		if (![string isEqualToString:@"*"] && ([string caseInsensitiveCompare:compString] != NSOrderedSame))
			return NO;
	}
	
	return YES;
}

- (void) dealloc
{
	[from release];
	[command release];
	[parameters release];
	
	if (orgMessage)
		free(orgMessage);
	
	[super dealloc];
}

- (NSStringEncoding) encoding
{
	return encoding;
}

- (void) setEncoding:(NSStringEncoding)enc
{
	encoding = enc;
	if (orgMessage != NULL)
		[self parseMessage];
}

- (void) parseMessage
{
	NSString *cmd = [[NSString alloc] initWithCString:orgMessage encoding:encoding];
	if (!cmd) {
		/* Our Encoding does not work, use ASCII */
		cmd = [[NSString alloc] initWithCString:orgMessage encoding:NSASCIIStringEncoding];
		encoding = NSASCIIStringEncoding;
	}
	NSMutableString *tmp;
	NSArray	 *cmdComponents = [cmd componentsSeparatedByString:@" "];
	NSUInteger i=2, count;
	
	[from release];
	[command release];
	[parameters release];
	
	if ([cmdComponents count] < 2) {
		return;
	}
	
	tmp = [[NSMutableString alloc] initWithString:[cmdComponents objectAtIndex:0]];
	if ([tmp characterAtIndex:0] == ':') {
		[tmp deleteCharactersInRange:NSMakeRange(0, 1)];
		from = [IRCUser userWithString:tmp onServer:self.server];

		command = [[cmdComponents objectAtIndex:1] copy];
	}
	else {
		from = nil;
		command = tmp;
		i=1;
	}
	
	parameters = [[NSMutableArray alloc] init];
	
	count = [cmdComponents count];
	NSMutableString *lastParameter = nil;
	for (i; i < count; i++) {
		NSString * parameter = [cmdComponents objectAtIndex:i];
		
		if (![parameter length])
			continue;
		
		if (lastParameter) {
			
			[lastParameter appendFormat:@" %@", parameter];
		}
		else if ([parameter characterAtIndex:0] == ':') {
			tmp = [[NSMutableString alloc] initWithString:parameter];
			[tmp deleteCharactersInRange:NSMakeRange(0, 1)];
			lastParameter = tmp;
		}
		else {
			[parameters addObject:parameter];
		}
	}
	
	if (lastParameter) {
		[parameters addObject:lastParameter];
		[lastParameter release];
	}
}

@end

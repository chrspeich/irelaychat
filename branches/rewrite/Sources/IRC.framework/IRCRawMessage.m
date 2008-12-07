//
//  IRCRawMessage.m
//  iRelayChat
//
//  Created by Christian Speich on 09.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCRawMessage.h"

@interface IRCRawMessage (PRIVATE)

- (void) parseMessage;

@end

@implementation IRCRawMessage

- (id) initWithCString: (char*)cstring usingEncoding:(NSStringEncoding)iencoding
{
	self = [self init];
	if (self != nil) {
		encoding = iencoding;
		
		// Make a private copy of the Message
		rawCString = malloc(sizeof(cstring));
		strcpy(rawCString, cstring);
		
		[self parseMessage];
	}
	return self;
}

- (void) dealloc
{
	free(rawCString);
	[rawString release];
	self.user = Nil;
	self.command = Nil;
	self.args = Nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Getters and Setters

- (NSStringEncoding) encoding 
{
	return encoding;
}

- (void) setEncoding: (NSStringEncoding) iencoding
{
	if (encoding == iencoding)
		return;
	
	encoding = iencoding;
	// The encoding has changed, so we have to reparse the message
	[self parseMessage];
}

- (NSString*) user 
{
	return [user retain];
}

- (void) setUser:(NSString*) iuser
{
	if ([iuser isEqualToString:user])
		return;
	
	[user release];
	user = [iuser retain];
}

- (NSString*) command 
{
	return [command retain];
}

- (void) setCommand:(NSString*) icommand
{
	if ([icommand isEqualToString:command])
		return;
	
	[command release];
	command = [icommand retain];
}

- (NSArray*) args 
{
	return [args retain];
}

- (void) setArgs:(NSArray*) iargs
{
	if ([iargs isEqualToArray:args])
		return;
	
	[args release];
	args = [iargs retain];
}

- (char*) rawCString
{
	return rawCString;
}

#pragma mark -
#pragma mark Debug Methods

- (NSString*) description 
{
	NSString *description;
	
	description = [[NSString alloc] 
				   initWithFormat:@"<%@: %p>(User=@\"%@\", Command=@\"%@\", Args={@\"%@\"})",
				   [self className], self, user, command, 
				   [args componentsJoinedByString:@"\", @\""]];
	
	return description;
}

#pragma mark -
#pragma mark Private Methods

- (void) parseMessage
{
	NSArray *components;
	NSMutableArray *tmpArgs;
	
	// Release the old strings
	[rawString release];
	self.user = Nil;
	self.command = Nil;
	self.args = Nil;
	
	rawString = [[NSString alloc] initWithCString:rawCString 
										 encoding:[self encoding]];
	
	// Looks like we have a wrong encoding
	// raise an execption
	// TODO: Autofigure out which encoding is the right/best
	if (!rawString)
		[NSException raise:@"Wrong Encoding"
					format:@"Can't create the rawString. Probbaly the encoding is wrong."];
	
	components = [rawString componentsSeparatedByString:@" "];
	
	// First component is the User
	// If we have a : at the beginig of the user, so remove it
	if ([[components objectAtIndex:0] characterAtIndex:0] == ':')
		self.user = [[components objectAtIndex:0] substringFromIndex:1];
	else
		self.user = [components objectAtIndex:0];
	
	// The second component is the command
	self.command = [components objectAtIndex:1];
	
	// Assemble the args array
	tmpArgs = [[NSMutableArray alloc] init];
	
	NSUInteger i, count = [components count];
	for (i = 2; i < count; i++) {
		NSString * arg = [components objectAtIndex:i];
		
		// All remain components are one argument
		if ([arg characterAtIndex:0] == ':') {
			NSMutableString *tmp = [NSMutableString string];
			
			[tmp appendString:[arg substringFromIndex:1]];
			
			for(i=i+1; i < count; i++)
				[tmp appendFormat:@" %@", [components objectAtIndex:i]];
			
			[tmpArgs addObject:tmp];
		}
		
		// It's a normal arg
		else 
			[tmpArgs addObject:arg];
	}
	
	// Make the args array imutable
	self.args = [[tmpArgs copy] autorelease];
	
	[tmpArgs release];
}

@end

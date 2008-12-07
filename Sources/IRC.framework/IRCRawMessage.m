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

- (id) initWithCString: (char*)cstring usingEncoding:(NSStringEncoding)_encoding
{
	self = [self init];
	if (self != nil) {
		encoding = _encoding;
		
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
	
	[super dealloc];
}

#pragma mark -
#pragma mark Getters

- (NSStringEncoding) encoding {
	return encoding;
}

- (NSString*) user {
	return [user retain];
}

- (NSString*) command {
	return [command retain];
}

- (NSArray*) args {
	return [args retain];
}

#pragma mark -
#pragma mark Debug Methods

- (NSString*) description {
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
	[user release];
	[command release];
	[args release];
	
	rawString = [[NSString alloc] initWithCString:rawCString 
										 encoding:[self encoding]];
	
	// Looks like we have a wrong encoding
	// raise an execption
	// TODO: Autofigure out which encoding is the right/best
	if (!rawString)
		[NSException raise:@"Wrong Encoding"
					format:@"Can't create the rawString. Probbaly the encoding is wrong."];
	
	components = [rawString componentsSeparatedByString:@" "];
	
	// The First component is the user
	user = [components objectAtIndex:0];
	
	// If we have a : at the beginig of the user, so remove it
	if ([user characterAtIndex:0] == ':')
		user = [user substringFromIndex:1];
	
	// The second component is the command
	command = [components objectAtIndex:1];
	
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
	args = [tmpArgs copy];
	
	[tmpArgs release];
}

@end

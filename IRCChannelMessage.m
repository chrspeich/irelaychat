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
 * This file contains a basics class for a Channel Message. It provides      *
 * methods for getting the plain text and an html 'useable' text. It also    *
 * dedects if the Message is an 'action' or is a message thats must be       *
 * highlighted why the users name or one of the word that are defined by the *
 * user is in the message.                                                   *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "IRCChannelMessage.h"
#import "IRCMessage.h"
#import "IRCUser.h"
#import "IRCServer.h"
#import <RegexKit/RegexKit.h>

@implementation IRCChannelMessage

@synthesize highlight, action, from, message;

- (id) initWithUser:(IRCUser*)user andMessage:(NSString*)inMessage;
{
	self = [super init];
	if (self != nil) {
		from = [user retain];
		message = [inMessage retain];
		
		if ([message isMatchedByRegex:[NSString stringWithFormat:@"(^|\\s|<|>|,)(%@)(:|,|\\s|\\?|!|\\.|<|>|$)", from.server.me.nickname]])
			highlight = YES;
		else
			highlight = NO;
		
		if ([message isMatchedByRegex:@"\001ACTION.*\001"]) {
			NSMutableString *tmp = [message mutableCopy];
			[message release];
			[tmp deleteCharactersInRange:NSMakeRange(0, 7)];
			[tmp deleteCharactersInRange:NSMakeRange([tmp length] - 1, 1)];
			message = [tmp copy];
			[tmp release];
			action = YES;
		} else
			action = NO;
	}
	return self;
}


- (id) initWithIRCMessage:(IRCMessage*)_message
{
	self = [super init];
	if (self != nil) {
		from = [_message.from retain];
		message = [[_message.parameters lastObject] retain];
		
		if ([message isMatchedByRegex:[NSString stringWithFormat:@"(^|\\s|<|>|,)(%@)(:|,|\\s|\\?|!|\\.|<|>|$)", _message.server.me.nickname]])
			highlight = YES;
		else
			highlight = NO;
		
		if ([message isMatchedByRegex:@"\001ACTION.*\001"]) {
			NSMutableString *tmp = [message mutableCopy];
			[message release];
			[tmp deleteCharactersInRange:NSMakeRange(0, 7)];
			[tmp deleteCharactersInRange:NSMakeRange([tmp length] - 1, 1)];
			message = [tmp copy];
			[tmp release];
			action = YES;
		} else
			action = NO;
	}
	return self;
}

- (void) dealloc
{
	[from release];
	[message release];
	
	[super dealloc];
}


+ (NSString*) urlRegex
{
	/* Thanks to James Johnston for the basis of the Pattern - http://regexlib.com/REDetails.aspx?regexp_id=1016 */
	return @"(?<message>(((ht|f)tp(s)?|irc)://)?[\\d\\w-.]+?\\.(a[cdefgilmnoqrstuwz]|b[abdefghijmnorstvwyz]|c[acdfghiklmnoruvxyz]|d[ejkmnoz]|e[ceghrst]|f[ijkmnor]|g[abdefghilmnpqrstuwy]|h[kmnrtu]|i[delmnoqrst]|j[emop]|k[eghimnprwyz]|l[abcikrstuvy]|m[acdghklmnopqrstuvwxyz]|n[acefgilopruz]|om|p[aefghklmnrstwy]|qa|r[eouw]|s[abcdeghijklmnortuvyz]|t[cdfghjkmnoprtvwz]|u[augkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]|aero|arpa|biz|com|coop|edu|info|int|gov|mil|museum|name|net|org|pro)(?<!&|=)(?!\\.\\s|\\.{3}).*?)(?<end>\\s|$)";
}

- (NSString*) htmlUseableMessage
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableString *html = [[NSMutableString alloc] init];
	
	[html appendString:message];
	
	/* Escape some chararcters to use it in html */
	[html replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"'" withString:@"&#39;" options:0 range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, [html length])];
	
	[html match:[IRCChannelMessage urlRegex] replace:RKReplaceAll withString:@"<a href=\"${message}\">${message}</a>${end}"];

	NSLog(@"html %@", html);
	
	NSString *result = [html copy];
	[html release];
	[pool release];
	return [result autorelease];
}

@end

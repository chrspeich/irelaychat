//
//  IRCConversationMessage.m
//  iRelayChat
//
//  Created by Christian Speich on 03.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCConversationMessage.h"
#import <AutoHyperlinks/AutoHyperlinks.h>
#import "IRCUser.h"
#import "IRCServer.h"

@interface IRCConversationMessage (PRIVAT)

- (NSAttributedString*) attributedStringFromMessage:(NSString*)message;
- (void) checkForHighlight;
- (void) checkForAction;
- (void) createHtmlString;

@end


@implementation IRCConversationMessage

- (id) initWithMessage:(NSString*)message fromUser:(IRCUser*)_user
{
	self = [super init];
	if (self != nil) {
		user = [_user retain];
		type = IRCConversationMessageText;
		action = NO;
		highlight = NO;
		
		messageString = [[self attributedStringFromMessage:message] retain];
		
		[self checkForHighlight];
		[self checkForAction];
	}
	return self;
}

- (id) initJoinWithUser:(IRCUser*)_user
{
	self = [super init];
	if (self != nil) {
		user = [_user retain];
		type = IRCConversationMessageJoin;
		action = NO;
		highlight = NO;
	}
	return self;
}

- (id) initPartWithUser:(IRCUser*)_user andReason:(NSString*)reason
{
	self = [super init];
	if (self != nil) {
		user = [_user retain];
		type = IRCConversationMessagePart;
		action = NO;
		highlight = NO;
		
		messageString = [self attributedStringFromMessage:reason];
	}
	return self;
}

- (id) initQuitWithUser:(IRCUser*)_user andReason:(NSString*)reason;
{
	self = [super init];
	if (self != nil) {
		user = [_user retain];
		type = IRCConversationMessageQuit;
		action = NO;
		highlight = NO;
		
		messageString = [self attributedStringFromMessage:reason];
	}
	return self;
}

- (void) dealloc
{
	[user release];
	[messageString release];
	[htmlString release];
	[date release];
	
	[super dealloc];
}


- (NSAttributedString*) attributedStringFromMessage:(NSString*)message
{
	NSMutableAttributedString *string;
	AHHyperlinkScanner *hyperlinkScanner;
	
	string = [[NSMutableAttributedString alloc] initWithString:message];
	
	// Maybe do here some stuff

	// Dedect URL's in the String...
	hyperlinkScanner = [AHHyperlinkScanner hyperlinkScannerWithAttributedString:string];
	
	[string release];
	
	return [hyperlinkScanner linkifiedString];
}

- (void) checkForAction
{
	NSMutableAttributedString *tmp;
	
	if ([messageString isMatchedByRegex:@"\001ACTION.*\001"]) {
		tmp = [messageString mutableCopy];
		
		[tmp deleteCharactersInRange:NSMakeRange(0, 7)];
		[tmp deleteCharactersInRange:NSMakeRange([tmp length] - 1, 1)];
		
		[messageString release];
		messageString = [tmp copy];
		[tmp release];
		
		action = YES;
	}
	else
		action = NO;
}

- (void) checkForHighlight
{
	NSMutableString *highlightedWords;
	NSArray *extraWordsToHighlight;
	
	highlightedWords = [[NSMutableString alloc] init];
	extraWordsToHighlight = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExtraWordsToHighlight"];
	
	[highlightedWords appendString:user.server.me.nickname];
	
	if (extraWordsToHighlight && [extraWordsToHighlight count] > 0)
		[highlightedWords appendFormat:@"|%@",[extraWordsToHighlight componentsJoinedByString:@"|"]];
	
	if ([messageString isMatchedByRegex:[NSString stringWithFormat:@"(^|\\s|<|>|,)(%@)(:|,|\\s|\\?|!|\\.|<|>|$)", highlightedWords]])
		highlight = YES;
	else
		highlight = NO;
}

- (void) createHtmlString
{
	NSMutableString *string;
	NSUInteger index;
	NSRange range;
	
	string = [[NSMutableString alloc] init];
	
	for (index = 0; index < [messageString length]; index = range.location + range.length) {
		NSDictionary *attributes;
		NSString *substring;
		
		attributes = [messageString attributesAtIndex:index effectiveRange:&range];
		substring = [[messageString string] substringWithRange:range];
		
		// ToDo escape html
		substring = [substring stringByReplacingOccurrencesOfString:@"'" withString:@"&#39;"];
		substring = [substring stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
		substring = [substring stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
		substring = [substring stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
		
		if ([attributes objectForKey:NSLinkAttributeName]) {
			NSURL *url = [attributes objectForKey:NSLinkAttributeName];
			substring = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", [url absoluteString], substring];
		}
		
		[string appendString:substring];
	}
	
	htmlString = [string copy];
	[string release];
}

- (NSString*) htmlString
{
	if (!htmlString)
		[self createHtmlString];
	
	return htmlString;
}

- (IRCUser*) user
{
	return user;
}

- (bool) highlight
{
	return highlight;
}

- (bool) action
{
	return action;
}

@synthesize messageString;
@synthesize conversation;
@synthesize date;
@synthesize type;

@end

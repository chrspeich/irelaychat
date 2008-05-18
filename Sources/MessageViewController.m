/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Frontend Class -                                                        *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "MessageViewController.h"
#import "IRCChannelMessage.h"
#import "IRCUser.h"

@implementation MessageViewController

- (id) initWithMessageView:(WebView*)inMessageView;
{
	self = [super init];
	if (self != nil) {
		messageView = [inMessageView retain];
		
		[self loadTemplate];
	}
	return self;
}

- (void) loadTemplate
{
	NSString *template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MessageTemplate" ofType:@"html"]];
	WebFrame *mainFrame = [messageView mainFrame];
	[mainFrame loadHTMLString:template baseURL:[NSURL URLWithString:[[NSBundle mainBundle] resourcePath]]];
}

- (void) addMessage:(IRCChannelMessage*)message
{
	NSString *mode;
	
	if (message.from.isMe && message.action)
		mode = @"self_action_message";
	else if (message.from.isMe)
		mode = @"self_message";
	else if (message.action)
		mode = @"action_message";
	else if (message.highlight)
		mode = @"highlighted_message";
	else
		mode = @"message";
		
	NSString *script = [NSString stringWithFormat:@"appendMessage('%@','%@', '%@', '%i,%i,%i');", message.from.nickname, [self escapeString:[message htmlUseableMessage]], mode, (int)([message.from.color redComponent]*255.f), (int)([message.from.color greenComponent]*255.f), (int)([message.from.color blueComponent]*255.f)];
	[messageView stringByEvaluatingJavaScriptFromString:script];
}

- (void) userJoins:(NSString*)user channel:(NSString*)channel
{
	NSString *script = [NSString stringWithFormat:@"appendJoin('%@','%@');", user, channel];
	[messageView stringByEvaluatingJavaScriptFromString:script];
}

- (void) userLeaves:(NSString*)user channel:(NSString*)channel
{
	NSString *script = [NSString stringWithFormat:@"appendLeave('%@','%@');", user, channel];
	[messageView stringByEvaluatingJavaScriptFromString:script];
}

- (void) userQuit:(NSString*)user withMessage:(NSString*)message
{
	NSString *script = [NSString stringWithFormat:@"appendQuit('%@','%@');", user, [self escapeString:message]];
	[messageView stringByEvaluatingJavaScriptFromString:script];
}

- (void) user:(NSString*)user remove:(NSString*)mode toUser:(NSString*)user2
{
	NSString *script = [NSString stringWithFormat:@"appendRemoveMode('%@','%@','%@');", user, mode, user2];
	[messageView stringByEvaluatingJavaScriptFromString:script];
}

- (void) user:(NSString*)user give:(NSString*)mode toUser:(NSString*)user2
{
	NSString *script = [NSString stringWithFormat:@"appendGiveMode('%@','%@','%@');", user, mode, user2];
	[messageView stringByEvaluatingJavaScriptFromString:script];
}

- (NSString*) escapeString:(NSString*)string
{
	NSString *tmp;
	tmp = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	tmp = [tmp stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
	return tmp;
}

@end

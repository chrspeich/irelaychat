//
//  MessageWindowController.m
//  iRelayChat
//
//  Created by Christian Speich on 03.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"


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

- (void) addMessage:(NSString*)message fromUser:(NSString*)user highlighted:(BOOL)highlighted
{
	NSString *script = [NSString stringWithFormat:@"appendMessage('%@','%@', '%@');", user, [self escapeString:message], highlighted?@"highlighted_message":@"message"];
	[messageView stringByEvaluatingJavaScriptFromString:script];
}

- (void) addMyMessage:(NSString*)message withUserName:(NSString*)user
{
	NSString *script = [NSString stringWithFormat:@"appendMessage('%@','%@', 'self_message');", user, [self escapeString:message]];
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

- (NSString*) escapeString:(NSString*)string
{
	NSString *tmp;
	tmp = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	tmp = [tmp stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
	return tmp;
}

@end

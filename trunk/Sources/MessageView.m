//
//  MessageView.m
//  iRelayChat
//
//  Created by Christian Speich on 22.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MessageView.h"
#import "IRCChannel.h"
#import "HTMLCache.h"
#import "MessageStyleDefault.h"

@implementation MessageView

@synthesize content;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		webView = [[WebView alloc] initWithFrame:frame frameName:@"MessageView" groupName:@"MessageView"];
        content = nil;

		[self addSubview:webView];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:IRCNewChannelMessage object:nil];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {

}

- (void) setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[webView setFrame:frame];
}

- (void) newMessage:(NSNotification*)noti
{
	if ([content unproxy] == [noti object]) {
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"appendHTML('%@');",[MessageStyleDefault htmlForChannelMessage:[[noti userInfo] objectForKey:@"MESSAGE"]]]];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	WebFrame *mainFrame = [webView mainFrame];
	NSString *html = [[HTMLCache sharedCache] htmlForObject:[content unproxy]];

	[mainFrame loadHTMLString:html baseURL:[NSURL URLWithString:[[NSBundle mainBundle] resourcePath]]];
}

@end

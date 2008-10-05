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

#import "MessageView.h"
#import "IRCChannel.h"
#import "HTMLCache.h"
#import "MessageStyleDefault.h"

@implementation MessageView

@synthesize content;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		webViews = [[NSMutableDictionary alloc] init];
        content = nil;
		currentWebView = nil;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:IRCConversationNewMessage object:nil];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {

}

- (void) setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[currentWebView setFrame:[self bounds]];
}

- (void) newMessage:(NSNotification*)noti
{
	if ([webViews objectForKey:[[noti object] valueForKey:@"name"]]) {
		[[webViews objectForKey:[[noti object] valueForKey:@"name"]] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"appendHTML('%@');",[MessageStyleDefault htmlForChannelMessage:[[noti userInfo] objectForKey:@"MESSAGE"]]]];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[currentWebView removeFromSuperview];
	
	if ([webViews objectForKey:[content valueForKey:@"name"]]) {
		[self addSubview:[webViews objectForKey:[content valueForKey:@"name"]]];
		currentWebView = [webViews objectForKey:[content valueForKey:@"name"]];
	} else {
		currentWebView = [[WebView alloc] initWithFrame:[self bounds]];
		WebFrame *mainFrame = [currentWebView mainFrame];
		NSString *html = [[HTMLCache sharedCache] htmlForObject:[content unproxy]];

		[mainFrame loadHTMLString:html baseURL:[NSURL URLWithString:[[NSBundle mainBundle] resourcePath]]];
		[webViews setObject:currentWebView forKey:[content valueForKey:@"name"]];
		[currentWebView setPolicyDelegate:self];
		[self addSubview:currentWebView];
	}
	[currentWebView setFrame:[self bounds]];
}

- (void)webView:(WebView *)sender
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
		  frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSURL *url = [actionInformation objectForKey:WebActionOriginalURLKey];
		
	//Ignore file URLs, but open anything else
	if (![url isFileURL]) {
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
		
	[listener ignore];
}

@end

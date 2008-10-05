//
//  AboutController.m
//  iRelayChat
//
//  Created by Christian Speich on 05.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"


@implementation AboutController

- (id) init
{
	self = [super init];
	if (self != nil) {
		if (![NSBundle loadNibNamed:@"AboutWindow" owner:self]) {
			[self release];
			return nil;
		}
		
		//[webView setDrawsBackground:NO];
		
		[[webView mainFrame] loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"]] baseURL:[NSURL URLWithString:[[NSBundle mainBundle] resourcePath]]];
		
		[webView setPolicyDelegate:self];
		
		NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
		
		[versionsField setStringValue:[NSString stringWithFormat:@"Version %@ (%@)", [dict objectForKey:@"CFBundleShortVersionString"], [dict objectForKey:@"CFBundleVersion"]]];
		
	}
	return self;
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

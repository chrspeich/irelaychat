//
//  HTMLCache.m
//  iRelayChat
//
//  Created by Christian Speich on 25.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HTMLCache.h"
#import "IRCChannel.h"
#import "MessageStyleDefault.h"

@implementation HTMLCache

- (id) init
{
	self = [super init];
	if (self != nil) {
		cache = [[NSMutableDictionary alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:IRCNewChannelMessage object:nil];
	}
	return self;
}


+ (id) sharedCache
{
	static id cache = nil;
	
	if (!cache)
		cache = [[self alloc] init];
	
	return cache;
}

- (NSString*) htmlForObject:(id)object
{
	NSString *html = [cache objectForKey:[object name]];
		
	if (!html)
		html = [self buildContentFor:object];
		
	return html;
}

- (void) clear
{
	@synchronized(cache) {
		[cache removeAllObjects];
	}
}

- (void) newMessage:(NSNotification*)noti
{
	@synchronized(cache) {
		if ([cache objectForKey:[[noti object] name]] != nil) {
			NSString *html = [cache objectForKey:[[noti object] name]];
		
			html = [html stringByReplacingOccurrencesOfString:@"<!-- Insert Place Holder -->" withString:[NSString stringWithFormat:@"%@\n<!-- Insert Place Holder -->",[MessageStyleDefault htmlForChannelMessage:[[noti userInfo] objectForKey:@"MESSAGE"]]]];

			[cache setObject:html forKey:[[noti object] name]];
		}
		else {
			NSString *html = [MessageStyleDefault template];
		
			html = [html stringByReplacingOccurrencesOfString:@"<!-- Insert Place Holder -->" withString:[NSString stringWithFormat:@"%@\n<!-- Insert Place Holder -->",[MessageStyleDefault htmlForChannelMessage:[[noti userInfo] objectForKey:@"MESSAGE"]]]];

			[cache setObject:html forKey:[[noti object] name]];
		}
	}
}

- (NSString*) buildContentFor:(id)object
{
	@synchronized(cache) {
		NSString *html = [MessageStyleDefault template];
		
		if ([object isKindOfClass:[IRCChannel class]]) {
			for (IRCChannelMessage *message in [object messages]) {
				html = [html stringByReplacingOccurrencesOfString:@"<!-- Insert Place Holder -->" withString:[NSString stringWithFormat:@"%@\n<!-- Insert Place Holder -->",[MessageStyleDefault htmlForChannelMessage:message]]];
			}
		}
		
		[cache setObject:html forKey:[[object unproxy] name]];
		return html;
	}
}

@end

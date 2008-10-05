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

#import "HTMLCache.h"
#import "IRCChannel.h"
#import "IRCConversationMessage.h"
#import "MessageStyleDefault.h"

@interface HTMLCache (Private)

- (NSString*) buildContentFor:(id)object;

@end


@implementation HTMLCache

- (id) init
{
	self = [super init];
	if (self != nil) {
		cache = [[NSMutableDictionary alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:IRCConversationNewMessage object:nil];
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
		NSString *html = [cache objectForKey:[[noti object] name]];
		
		if (!html)
			html = [MessageStyleDefault template];
		
		html = [html stringByReplacingOccurrencesOfString:@"<!-- Insert Place Holder -->" withString:[NSString stringWithFormat:@"%@\n<!-- Insert Place Holder -->",[MessageStyleDefault htmlForChannelMessage:[[noti userInfo] objectForKey:@"MESSAGE"]]]];

		[cache setObject:html forKey:[[noti object] name]];
	}
}

- (NSString*) buildContentFor:(id)object
{
	NSString *html = [MessageStyleDefault template];

	@synchronized(cache) {
		if ([object isKindOfClass:[IRCChannel class]]) {
			for (IRCConversationMessage *message in [object messages]) {
				html = [html stringByReplacingOccurrencesOfString:@"<!-- Insert Place Holder -->" withString:[NSString stringWithFormat:@"%@\n<!-- Insert Place Holder -->",[MessageStyleDefault htmlForChannelMessage:message]]];
			}
		}
		
		[cache setObject:html forKey:[[object unproxy] name]];
	}
	
	return html;

}

@end

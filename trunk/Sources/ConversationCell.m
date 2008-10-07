//
//  ConversationCell.m
//  iRelayChat
//
//  Created by Christian Speich on 06.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ConversationCell.h"
#import "IRCConversation.h"
#import "IRCServer.h"

@implementation ConversationCell

- (void)setObjectValue:(id < NSObject >)_object
{
	if (![_object isKindOfClass:[IRCConversation class]] &&
		![_object isKindOfClass:[IRCServer class]])
		return;
	
	NSLog(@"set %@", object);

}

@end

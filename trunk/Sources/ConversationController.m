//
//  ConversationController.m
//  iRelayChat
//
//  Created by Christian Speich on 07.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ConversationController.h"
#import "IRCConversation.h"
#import "IRCChannel.h"

@implementation ConversationController

@synthesize conversation=m_conversation;

- (id) initWithConversation:(IRCConversation*)conversation
{
	self = [super init];
	if (self != nil) {
		m_conversation = conversation;
	}
	return self;
}


// Does our Conversation support an InputField?
// TODO: - Maybe if we are not vocied in a +m Channel we should hide it?
- (bool) supportInputField
{
	return YES;
}

// Does our Conversation need/support an userList?
// - For Query's a userList is completly useless, so hide it
- (bool) hasUserList
{
	// If our Conversation responds to "userList", we have a userList
	// so return YES
	if ([self.conversation respondsToSelector:@selector(userList:)])
		return YES;
	
	// Otherwise we don't ne a userList
	return NO;
}

// A conversation is mostly at the end of path and does 
// not have 'underconversaions', so return here YES
- (bool) isLeaf
{
	return YES;
}

// Return the userList of our Conversation
// or Nil if the Conversation does not have on
- (NSArray*) userList
{
	if ([self hasUserList])
		return [self.conversation performSelector:@selector(userList:)];
	
	return Nil;
}

// Return the messages of our Conversation
- (NSArray*) messages
{
	return [self.conversation messages];
}

// Simply return the name
- (NSString*) name
{
	return [self.conversation name];
}

// Vadilate menuItems thats want to be vadilated
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	// We will identify a Item via selector
	SEL selector = [menuItem action];
	
	// We should vadialte the TimeStamps Menu Item
	if (@selector(showOrHideTimeStamps:) == selector) {
		// We show the Time Stamps, so let us display the Hide Label
		if ([self isShowTimeStamps]) {
			[menuItem setTitle:NSLocalizedString(@"HideTimeStamps", @"Hide Time Stamps")];
		}
		
		// We dont show Time Stamps, so let us display the Show Label
		else {
			[menuItem setTitle:NSLocalizedString(@"ShowTimeStamps", @"Show Time Stamps")];
		}
		
		// The item is in every Conversation valid, so just return YES
		return YES;
	}
	
	// We should vadilate the Join Messages Menu Item
	else if (@selector(showOrHideJoinMessages:) == selector) {
		// We show the Join Messages, let us display the Hide Label
		if ([self isShowJoinMessages]) {
			[menuItem setTitle:NSLocalizedString(@"HideJoinMessages", @"Hide Join Messages")];
		}
		
		// We dont show Join Messages, let us display the Show Label
		else {
			[menuItem setTitle:NSLocalizedString(@"ShowJoinMessages", @"Show Join Messages")];
		}
		
		// The item is only valid if the conversation is a channel
		if ([self.conversation isKindOfClass:[IRCChannel class]])
			return YES;
		else
			return NO;
	}
	
	// We should vadilate the Par Messages Menu Item
	else if (@selector(showOrHidePartMessages:) == selector) {
		// We show the Part Messages, let us display the Hide Label
		if ([self isShowPartMessages]) {
			[menuItem setTitle:NSLocalizedString(@"HidePartMessages", @"Hide Part Messages")];
		}
		
		// We dont show, so display the Show Label
		else {
			[menuItem setTitle:NSLocalizedString(@"ShowPartMessages", @"Show Part Messages")];
		}
		
		// the item is only for channels valid
		if ([self.conversation isKindOfClass:[IRCChannel class]])
			return YES;
		else
			return NO;
	}
	
	// We should vadilate the Quit Message Menu Item
	else if (@selector(showOrHideQuitMessages:) == selector) {
		// We show the Quit Messages, so display the Hide Label
		if ([self isShowQuitMessages]) {
			[menuItem setTitle:NSLocalizedString(@"HideQuitMessages", @"Hide Quit Messages")];
		}
		
		// we dont, so display the Show Label
		else {
			[menuItem setTitle:NSLocalizedString(@"ShowQuitMessages", @"Show Quit Messages")];
		}

		// TODO: is not valid for Consoles, but correctly consoles are not
		//       implemented, so return YES
		return YES;
	}
	
	// Return by default YES,
	// so is every MenuItem valid until we will specially validate it :)
	return YES;
}

// Does we should show Time Stamps?
// - look for "local" Settings
// - look for "global" Settings
- (bool) isShowTimeStamps
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
}

@end

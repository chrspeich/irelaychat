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
// or Nil if the Conversation does not have one
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
	NSString *value;
	
	//Fetch the value form the UserDefaults
	value = [defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@", [[self name] uppercaseString]]];
	
	// We have costume Settings for Time Stamps, so return the Value
	if (value)
			return [value boolValue];
	
	// We dont have local Settings for this Conversation
	// return the global Settings
	return [defaults boolForKey:@"showTimeStamps"];
}

// Set the value for Time Stamps
// - if the new value is equal to the default just remove the costume Setting
- (void) setShowTimeStamps:(bool)showTimeStamps
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *costumeSettings;
	NSMutableDictionary *allCostumeSetting;
	
	// If the new and old value are equal, skip
	if ([self isShowTimeStamps] == showTimeStamps)
		return;
	
	// Notify all KVO observers that we will change the Time Stamps value
	[self willChangeValueForKey:@"showTimeStamps"];
		
	// Get the dictionary which hold the costume settings for this conversation
	// and made it mutable
	//  - conversations are identifyed via the name (uppercase)
	costumeSettings = [[defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@", [[self name] uppercaseString]]] mutableCopy];
	
	// When the new value is equal to the default value, remove the costume Setting
	if ([defaults boolForKey:@"showTimeStamps"] == showTimeStamps) {
		[costumeSettings removeObjectForKey:@"showTimeStamps"];
	}
	
	// otherwise set the new value
	else {
		[costumeSettings setValue:showTimeStamps ? @"YES" : @"NO" forKey:@"showTimeStamps"];
	}

	// Fetch the Dictionary for all costume Conversations Settings and made it mutable
	allCostumeSetting = [[defaults valueForKey:@"costumeConversationsSettings"] mutableCopy];
	
	// Set oure new costume settings
	[allCostumeSetting setValue:costumeSettings forKey:[[self name] uppercaseString]];
	[defaults setValue:allCostumeSetting forKey:@"costumeConversationsSettings"];
	
	
	// Notify all KVO observers that we are done...
	[self didChangeValueForKey:@"showTimeStamps"];
	
	// Release the costume Settings dictonarys
	[costumeSettings release];
	[allCostumeSetting release];
}

// Does we should show Join Messages?
// - if our conversation is not a Channel return NO
// - look for "local" Settings
// - look for "global" Settings
- (bool) isShowJoinMessages
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *value;
	
	// if our conversation is not a Channel return NO
	if ([self.conversation isKindOfClass:[IRCChannel class]])
		return NO;
	
	// Fetch the value from userDefaults
	value = [defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@.showJoinMessages", [[self name] uppercaseString]]];
	
	// We have costume settings for show Join Messages, so return the value
	if (value)
		return [value boolValue];
	
	// We dont have local Settings for this Conversation
	// return the global Settings
	return [defaults boolForKey:@"showJoinMessages"];
}

// Set the value for show Join Messages
- (void) setShowJoinMessages:(bool)showJoinMessages
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *costumeSettings;
	NSMutableDictionary *allCostumeSettings;
	
	// If the new and old value are equal, skip
	if ([self isShowJoinMessages] == showJoinMessages)
		return;
	
	// Notify all KVO observers that we will change the Show Join Messages value
	[self willChangeValueForKey:@"showJoinMessages"];
	
	// Get the dictionary which hold s the costume settings for this
	// conversation and make it mutable
	costumeSettings = [[defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@", [[self name] uppercaseString]]] mutableCopy];
	
	// If the new value is equal to the default value, so remove them from the
	// costume settings dictionary
	if ([defaults boolForKey:@"showJoinMessages"] == showJoinMessages) {
		[costumeSettings removeObjectForKey:@"showJoinMessages"];
	}
	
	// otherwise set the new value
	else {
		[costumeSettings setValue:showJoinMessages ? @"YES" : @"NO" forKey:@"showJoinMessages"];
	}
	
	// Fetch the Dictionary for all costume Conversations settings and make it mutable
	allCostumeSettings = [[defaults valueForKey:@"costumeConversationsSettings"] mutableCopy];
	
	// Set our new costume settings
	[allCostumeSettings setValue:costumeSettings forKey:[[self name] uppercaseString]];
	[defaults setValue:allCostumeSettings forKey:@"costumeConversationsSettings"];

	// Notify all KVO observers that we are done
	[self didChangeValueForKey:@"showJoinMessages"];
	
	// Release the costume settings dictionarys
	[costumeSettings release];
	[allCostumeSettings release];
}

// Does we should show Part Messages?
// - if our conversation is not a Channel return NO
// - look for "local" Settings
// - look for "global" Settings
- (bool) isShowPartMessages
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *value;
	
	// if our conversation is not a Channel return NO
	if ([self.conversation isKindOfClass:[IRCChannel class]])
		return NO;
	
	// Fetch the value from userDefaults
	value = [defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@.showPartMessages", [[self name] uppercaseString]]];
	
	// We have costume settings for show Part Messages, so return the value
	if (value)
		return [value boolValue];
	
	// We dont have local Settings for this Conversation
	// return the global Settings
	return [defaults boolForKey:@"showPartMessages"];
}

// Set the value for show Part Messages
- (void) setShowPartMessages:(bool)showPartMessages
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *costumeSettings;
	NSMutableDictionary *allCostumeSettings;
	
	// If the new and old value are equal, skip
	if ([self isShowPartMessages] == showPartMessages)
		return;
	
	// Notify all KVO observers that we will change the Show Part Messages value
	[self willChangeValueForKey:@"showPartMessages"];
	
	// Get the dictionary which hold s the costume settings for this
	// conversation and make it mutable
	costumeSettings = [[defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@", [[self name] uppercaseString]]] mutableCopy];
	
	// If the new value is equal to the default value, so remove them from the
	// costume settings dictionary
	if ([defaults boolForKey:@"showPartMessages"] == showPartMessages) {
		[costumeSettings removeObjectForKey:@"showPartMessages"];
	}
	
	// otherwise set the new value
	else {
		[costumeSettings setValue:showPartMessages ? @"YES" : @"NO" forKey:@"showPartMessages"];
	}
	
	// Fetch the Dictionary for all costume Conversations settings and make it mutable
	allCostumeSettings = [[defaults valueForKey:@"costumeConversationsSettings"] mutableCopy];
	
	// Set our new costume settings
	[allCostumeSettings setValue:costumeSettings forKey:[[self name] uppercaseString]];
	[defaults setValue:allCostumeSettings forKey:@"costumeConversationsSettings"];
	
	// Notify all KVO observers that we are done
	[self didChangeValueForKey:@"showPartMessages"];
	
	// Release the costume settings dictionarys
	[costumeSettings release];
	[allCostumeSettings release];
}

// Does we should show Join Messages?
// - look for "local" Settings
// - look for "global" Settings
- (bool) isShowQuitMessages
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *value;
	
	// Fetch the value from userDefaults
	value = [defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@.showQuitMessages", [[self name] uppercaseString]]];
	
	// We have costume settings for show Quit Messages, so return the value
	if (value)
		return [value boolValue];
	
	// We dont have local Settings for this Conversation
	// return the global Settings
	return [defaults boolForKey:@"showQuitMessages"];
}

// Set the value for show Part Messages
- (void) setShowQuitMessages:(bool)showQuitMessages
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *costumeSettings;
	NSMutableDictionary *allCostumeSettings;
	
	// If the new and old value are equal, skip
	if ([self isShowQuitMessages] == showQuitMessages)
		return;
	
	// Notify all KVO observers that we will change the Show Quit Messages value
	[self willChangeValueForKey:@"showQuitMessages"];
	
	// Get the dictionary which hold s the costume settings for this
	// conversation and make it mutable
	costumeSettings = [[defaults valueForKeyPath:[NSString stringWithFormat:@"costumeConversationsSettings.%@", [[self name] uppercaseString]]] mutableCopy];
	
	// If the new value is equal to the default value, so remove them from the
	// costume settings dictionary
	if ([defaults boolForKey:@"showQuitMessages"] == showQuitMessages) {
		[costumeSettings removeObjectForKey:@"showQuitMessages"];
	}
	
	// otherwise set the new value
	else {
		[costumeSettings setValue:showQuitMessages ? @"YES" : @"NO" forKey:@"showQuitMessages"];
	}
	
	// Fetch the Dictionary for all costume Conversations settings and make it mutable
	allCostumeSettings = [[defaults valueForKey:@"costumeConversationsSettings"] mutableCopy];
	
	// Set our new costume settings
	[allCostumeSettings setValue:costumeSettings forKey:[[self name] uppercaseString]];
	[defaults setValue:allCostumeSettings forKey:@"costumeConversationsSettings"];
	
	// Notify all KVO observers that we are done
	[self didChangeValueForKey:@"showQuitMessages"];
	
	// Release the costume settings dictionarys
	[costumeSettings release];
	[allCostumeSettings release];
}

#pragma mark - Interface Builder Actions -

// Toggle show TimeStamps settings
- (IBAction) showOrHideTimeStamps:(id)sender
{
	// Get the current value, invert it and set it, so simple it can be
	[self setShowTimeStamps: ! [self isShowTimeStamps]];
}

// Toggle show Join Message settings
- (IBAction) showOrHideJoinMessages:(id)sender
{
	// Get the current value, invert it and set
	[self setShowJoinMessages: ! [self isShowJoinMessages]];
}

// Toggle show Part Messages settings
- (IBAction) showOrHidePartMessages:(id)sender
{
	// Get the current value, invert it and set it
	[self setShowPartMessages: ! [self isShowPartMessages]];
}

// Toggle show Quit Message settings
- (IBAction) showOrHideQuitMessages:(id)sender
{
	// Get the current value, invert it and set
	[self setShowQuitMessages: ! [self isShowQuitMessages]];
}

@end

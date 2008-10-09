/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Backend Class -                                                         *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "IRCChannel.h"
#import "IRCServer.h"
#import "IRCUser.h"
#import "IRCUserMode.h"
#import "IRCConversationMessage.h"
#import "IRCProtocol.h"

NSString *IRCUserListHasChanged  = @"iRelayChat-IRCUserListHasChanged";
NSString *IRCUserJoinsChannel = @"iRelayChat-IRCUserJoinsChannel";
NSString *IRCUserLeavesChannel = @"iRelayChat-IRCUserLeavesChannel";
NSString *IRCUserHasGotMode = @"iRelayChat-IRCUserHasGotMode";
NSString *IRCUserHasLoseMode = @"iRelayChat-IRCUserHasLoseMode";

NSComparisonResult sortUsers(id first, id second, void *contex) {
	IRCChannel *channel = (IRCChannel*)contex;

	IRCUserMode *firstMode = [first userModeForChannel:channel];
	IRCUserMode *secondMode = [second userModeForChannel:channel];
	
	if (firstMode.hasOp && !secondMode.hasOp)
		return NSOrderedAscending;
	
	if (!firstMode.hasOp && secondMode.hasOp)
		return NSOrderedDescending;
	
	if (firstMode.hasVoice && !secondMode.hasVoice)
		return NSOrderedAscending;
	
	if (!firstMode.hasVoice && secondMode.hasVoice)
		return NSOrderedDescending;
	
	return [[first nickname] compare:[second nickname]];
}

@implementation IRCChannel

@synthesize userList;

- (id) initWithName:(NSString*)_name onServer:(IRCServer*)_server
{
	self = [super initWithName:_name onServer:_server];
	if (self != nil) {
		userList = [[NSMutableArray alloc] init];

		[NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(reloadUserList) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) registerObservers
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[super registerObservers];
	
	[server addObserver:self 
			   selector:@selector(userList:) 
				pattern:[server.protocol patternNameReplyForChannel:name]];
	[server addObserver:self 
			   selector:@selector(userListEnd:) 
				pattern:[server.protocol patternNameReplyEndForChannel:name]];
	[server addObserver:self 
			   selector:@selector(userJoin:) 
				pattern:[server.protocol patternJoinForChannel:name]];
	[server addObserver:self
			   selector:@selector(userLeave:)
				pattern:[server.protocol patternPartForChannel:name]];
	[server addObserver:self 
			   selector:@selector(modeChanged:) 
				pattern:[server.protocol patternModeForChannel:name]];
	
	[nc addObserver:self 
		   selector:@selector(userQuits:) 
			   name:IRCUserQuit 
			 object:self.server];
	[nc addObserver:self 
		   selector:@selector(userChanged:) 
			   name:IRCUserChanged 
			 object:nil];
}

- (void) dealloc
{
	[tmpUserList release];
	[userList release];
	
	[super dealloc];
}


- (void) reloadUserList
{
	[server send:[server.protocol namesFor:name]];
}

- (void) userList:(NSDictionary*)message
{
	NSString *nicksString;
	NSArray *nicks;
	
	if (!tmpUserList)
		tmpUserList = [[NSMutableArray alloc] init];
	
	[[message objectForKey:@"MESSAGE"] 
	 getCapturesWithRegexAndReferences:[server.protocol patternNameReplyForChannel:name],@"${nicks}",&nicksString,nil];
	
	nicks = [nicksString componentsSeparatedByString:@" "];
	
	for (NSString *nickname in nicks) {
		IRCUser *user;
		IRCUserMode *mode;
		
		if ([nickname isEqualToString:@""] ||
			[nickname isEqualToString:@" "])
			continue;
		
		user = [IRCUser userWithNickname:nickname onServer:self.server];
		mode = [[IRCUserMode alloc] initFromUserString:nickname];
		
		[user setUserMode:mode forChannel:self];
		
		[tmpUserList addObject:user];
		
		[mode release];
		[user release];
	}
}

- (void) userListEnd:(NSDictionary*)message
{	
	[tmpUserList sortUsingFunction:sortUsers context:self];
	
	if (![userList isEqualToArray:tmpUserList]) {
		NSLog(@"we've loosed some changes!");
		
		[userList removeAllObjects];
		[userList addObjectsFromArray:tmpUserList];

		[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
	}
	
	NSLog(@"user list %@", userList);
	
	[tmpUserList release];
	tmpUserList = nil;
}

- (void) userJoin:(NSDictionary*)message
{
	NSString *from;
	IRCUser *user;
	IRCConversationMessage *ircMessage;
	
	[[message objectForKey:@"MESSAGE"]
	 getCapturesWithRegexAndReferences:[server.protocol patternJoinForChannel:name],@"${from}",&from,nil];

	user = [IRCUser userWithString:from onServer:self.server];
	
	ircMessage = [[IRCConversationMessage alloc] initJoinWithUser:user];
	
	ircMessage.conversation = self;
	ircMessage.date = [message objectForKey:@"TIME"];
	
	[self addMessage:ircMessage];
	
	[userList addObject:user];
	[userList sortUsingFunction:sortUsers context:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
	
	[ircMessage release];
}

- (void) userLeave:(NSDictionary*)message
{
	NSString *from;
	NSString *reason;
	IRCUser *user;
	IRCConversationMessage *ircMessage;
	
	[[message objectForKey:@"MESSAGE"]
	 getCapturesWithRegexAndReferences:[server.protocol patternPartForChannel:name],@"${from}",&from,@"${reason}",&reason,nil];
	
	user = [IRCUser userWithString:from onServer:self.server];
	
	ircMessage = [[IRCConversationMessage alloc] initPartWithUser:user andReason:reason];
	
	ircMessage.conversation = self;
	ircMessage.date = [message objectForKey:@"TIME"];
	
	[self addMessage:ircMessage];
	
	[userList removeObject:user];
	[userList sortUsingFunction:sortUsers context:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
	
	[ircMessage release];
}

- (void) modeChanged:(NSDictionary*)message
{
	NSString *from = NULL, *change = NULL, *mode = NULL, *to = NULL;
	IRCUser *user;
	IRCUserMode *currentMode;
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	[messageLine getCapturesWithRegexAndReferences:[server.protocol patternModeForChannel:name],@"${from}",&from,@"${change}",&change,@"${mode}",&mode,@"${to}",&to,nil];
	
	user = [IRCUser userWithNickname:to onServer:server];
	currentMode = [user userModeForChannel:self];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:user forKey:@"USER"];
	[dict setObject:[IRCUser userWithString:from onServer:self.server] forKey:@"FROM"];
	
	if ([change isEqualToString:@"+"]) {
		if ([mode isEqualToString:@"o"] && !currentMode.hasOp) {
			currentMode.hasOp = YES;
			
			[dict setObject:@"Op" forKey:@"MODE"];
		}
		else if ([mode isEqualToString:@"v"] && !currentMode.hasVoice) {
			currentMode.hasVoice = YES;
			
			[dict setObject:@"Voice" forKey:@"MODE"];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserHasGotMode object:self userInfo:dict];
	}
	else if ([change isEqualToString:@"-"]) {
		if ([mode isEqualToString:@"o"] && currentMode.hasOp) {
			currentMode.hasOp = NO;
			
			[dict setObject:@"Op" forKey:@"MODE"];
		}
		else if ([mode isEqualToString:@"v"] && currentMode.hasVoice) {
			currentMode.hasVoice = NO;
			
			[dict setObject:@"Voice" forKey:@"MODE"];
		}	
		[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserHasLoseMode object:self userInfo:dict];
	}
	
	[userList sortUsingFunction:sortUsers context:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
	[dict release];
}

- (void) userQuits:(NSNotification*)noti
{
	IRCConversationMessage *message;
	
	if (![userList containsObject:[[noti userInfo] objectForKey:@"FROM"]])
		return;
	
	message = [[IRCConversationMessage alloc] initQuitWithUser:[[noti userInfo] objectForKey:@"FROM"]
													 andReason:[[noti userInfo] objectForKey:@"MESSAGE"]];
	
	message.conversation = self;
	message.date = [[noti userInfo] objectForKey:@"TIME"];
	
	[self addMessage:message];
	
	[userList removeObject:[[noti userInfo] objectForKey:@"FROM"]];
	[userList sortUsingFunction:sortUsers context:self];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged 
														object:self];
	
	[message release];
}

- (void) userChanged:(NSNotification*)noti
{
	[userList sortUsingFunction:sortUsers context:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
}

- (bool) isLeaf
{
	return YES;
}

- (bool) supportInputField
{
	return YES;
}

- (bool) hasUserList
{
	return YES;
}

- (void) join
{
	[server send:[server.protocol joinChannel:name]];
}

- (id) privMsgPattern
{
	return [server.protocol patternPirvmsgTo:name];
}

@end

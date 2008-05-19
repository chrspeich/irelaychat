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
#import "IRCChannelMessage.h"
#import "IRCProtocol.h"

NSString *IRCUserListHasChanged  = @"iRelayChat-IRCUserListHasChanged";
NSString *IRCNewChannelMessage = @"iRelayChat-IRCNewChannelMessage";
NSString *IRCUserJoinsChannel = @"iRelayChat-IRCUserJoinsChannel";
NSString *IRCUserLeavesChannel = @"iRelayChat-IRCUserLeavesChannel";
NSString *IRCUserHasGotMode = @"iRelayChat-IRCUserHasGotMode";
NSString *IRCUserHasLoseMode = @"iRelayChat-IRCUserHasLoseMode";

NSComparisonResult sortUsers(id first, id second, void *contex) {
	IRCChannel *channel = (IRCChannel*)contex;

	IRCUserMode *firstMode = [first userModeForChannel:channel];
	IRCUserMode *secondMode = [second userModeForChannel:channel];
	
	if ((firstMode.hasOp && secondMode.hasOp) ||
		(firstMode.hasVoice && secondMode.hasVoice))
		return [[first nickname] compare:[second nickname]];
	
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

@synthesize name, server, userList;

- (id) initWithServer:(IRCServer*)_server andName:(NSString*)_name;
{
	self = [super init];
	if (self != nil) {
		name = _name;
		server = _server;
		tmpUserList = nil;
		userList = nil;
				
		[server addObserver:self selector:@selector(userList:) pattern:[server.protocol patternNameReplyForChannel:name]];
		[server addObserver:self selector:@selector(userListEnd:) pattern:[server.protocol patternNameReplyEndForChannel:name]];
		[server addObserver:self selector:@selector(channelMessage:) pattern:[server.protocol patternPirvmsgFor:name]];
		[server addObserver:self selector:@selector(userJoin:) pattern:[server.protocol patternJoinForChannel:name]];
		[server addObserver:self selector:@selector(userLeave:) pattern:[server.protocol patternPartForChannel:name]];
		[server addObserver:self selector:@selector(modeChanged:) pattern:[server.protocol patternModeForChannel:name]];
		
		[server send:[NSString stringWithFormat:@"JOIN %@", name]];
		[[NSNotificationCenter defaultCenter] postNotificationName:IRCJoinChannel object:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userQuits:) name:IRCUserQuit object:self.server];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged:) name:IRCUserChanged object:nil];
		[NSTimer scheduledTimerWithTimeInterval:120.f target:self selector:@selector(reloadUserList) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) reloadUserList
{
	[server send:[server.protocol namesFor:name]];
}

- (void) sendMessage:(NSString*)message
{
	NSString *messageString;
	if ([message characterAtIndex:0] == '/') {
		NSMutableArray *components = [[message componentsSeparatedByString:@" "] mutableCopy];
		NSString *command = [components objectAtIndex:0];
		[components removeObjectAtIndex:0];
		
		if ([command isEqualToString:@"/action"] || [command isEqualToString:@"/me"]) {
			messageString = [NSString stringWithFormat:@"\001ACTION %@\001", [components componentsJoinedByString:@" "]];
		}
		[components release];
	}
	else {
		messageString = message;
	}
	
	id commands = [server.protocol privMsg:messageString to:name];
	
	[server send:commands];

	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	IRCChannelMessage *mess = [[IRCChannelMessage alloc] initWithUser:server.me andMessage:messageString];
	[dict setObject:mess forKey:@"MESSAGE"];
		
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCNewChannelMessage object:self userInfo:dict];
	[mess release];
}

- (void) userList:(NSDictionary*)message
{
	NSString *nicks = NULL;
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	if (!tmpUserList)
		tmpUserList = [[NSMutableArray alloc] init];
	
	[messageLine getCapturesWithRegexAndReferences:[server.protocol patternNameReplyForChannel:name],@"${nicks}",&nicks,nil];
		
	NSArray *users = [nicks componentsSeparatedByString:@" "];
	
	for (NSString *username in users) {
		if ([username isEqualToString:@""] || [username isEqualToString:@" "])
			continue;
		IRCUser *user = [IRCUser userWithNickname:username onServer:self.server];
		IRCUserMode *mode = [[IRCUserMode alloc] initFromUserString:username];
		[user setUserMode:mode forChannel:self];
		[mode release];
		[tmpUserList addObject:user];
		[user release];
	}
}

- (void) userListEnd:(NSDictionary*)message
{
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	[tmpUserList sortUsingFunction:sortUsers context:self];
	if (![userList isEqualToArray:tmpUserList]) {
		NSLog(@"we've loosed some changes!");
		[userList release];
		userList = tmpUserList;
		tmpUserList = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
	}
	else {
		[tmpUserList release];
		tmpUserList = nil;
	}

}

- (void) channelMessage:(NSDictionary*)_message
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSString *from = NULL, *message = NULL;
	NSString *messageLine;
	
	messageLine = [_message objectForKey:@"MESSAGE"];
	
	[messageLine getCapturesWithRegexAndReferences:[server.protocol patternPirvmsgFor:name],@"${from}",&from,@"${message}",&message,nil];
	
	IRCChannelMessage *mess = [[IRCChannelMessage alloc] initWithUser:[IRCUser userWithString:from onServer:self.server] andMessage:message];
	[dict setObject:mess forKey:@"MESSAGE"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCNewChannelMessage object:self userInfo:dict];
	[mess release];
}

- (void) userJoin:(NSDictionary*)message
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSString *from = NULL;
	IRCUser *user;
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	[messageLine getCapturesWithRegexAndReferences:[server.protocol patternJoinForChannel:name],@"${from}",&from,nil];
	
	user = [IRCUser userWithString:from onServer:self.server];
	
	[dict setObject:user forKey:@"FROM"];
	[userList addObject:user];
	[userList sortUsingFunction:sortUsers context:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserJoinsChannel object:self userInfo:dict];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
}

- (void) userLeave:(NSDictionary*)message
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSString *from = NULL, *reason = NULL;
	IRCUser *user;
	NSString *messageLine;
	
	messageLine = [message objectForKey:@"MESSAGE"];
	
	[messageLine getCapturesWithRegexAndReferences:[server.protocol patternPartForChannel:name],@"${from}",&from,@"${reason}",&reason,nil];
	
	user = [IRCUser userWithString:from onServer:self.server];
	
	[dict setObject:user forKey:@"FROM"];
	[dict setObject:reason forKey:@"REASON"];
	[userList removeObject:user];
	[userList sortUsingFunction:sortUsers context:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserLeavesChannel object:self userInfo:dict];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
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
	if ([userList containsObject:[[noti userInfo] objectForKey:@"FROM"]]) {
		[userList removeObject:[[noti userInfo] objectForKey:@"FROM"]];
		[userList sortUsingFunction:sortUsers context:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserQuit object:self userInfo:[noti userInfo]];
		[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
	}
}

- (void) userChanged:(NSNotification*)noti
{
	[userList sortUsingFunction:sortUsers context:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:IRCUserListHasChanged object:self];
}

@end

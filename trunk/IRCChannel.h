//
//  IRCChannel.h
//  iRelayChat
//
//  Created by Christian Speich on 17.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *IRCUserListHasChanged;
extern NSString *IRCNewChannelMessage;
extern NSString *IRCUserJoinsChannel;
extern NSString *IRCUserLeavesChannel;
extern NSString *IRCUserHasGotMode;
extern NSString *IRCUserHasLoseMode;

@class IRCServer;

@interface IRCChannel : NSObject {
	NSString	*name;
	IRCServer	*server;
	NSMutableArray *tmpUserList;
	NSMutableArray *userList;
}

- (id) initWithServer:(IRCServer*)server andName:(NSString*)name;
- (void) sendMessage:(NSString*)message;

@property(readonly,copy) NSString	*name;
@property(readonly,retain) IRCServer*server;
@property(readonly,retain) NSArray *userList;

@end

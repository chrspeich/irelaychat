//
//  InternetRelayChat.h
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface InternetRelayChat : NSObject {
	NSMutableArray	*servers;
	NSMutableArray	*plugins;
}

+ (id) sharedInternetRelayChat;

- (void) searchForPlugins;

@property(readonly) NSMutableArray *servers;
@property(readonly) NSMutableArray *plugins;

@end

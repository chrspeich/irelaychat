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
}

+ (id) sharedInternetRelayChat;

@property(readonly) NSMutableArray *servers;

@end

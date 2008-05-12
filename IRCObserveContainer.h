//
//  IRCObserveContainer.h
//  iRelayChat
//
//  Created by Christian Speich on 18.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IRCMessage;

@interface IRCObserveContainer : NSObject {
	SEL		selector;
	id		observer;
	id		pattern;
	IRCMessage *message;
}

@property(readwrite, assign) SEL selector;
@property(readwrite, assign) id	observer;
@property(readwrite, assign) IRCMessage *message;
@property(readwrite, retain) id pattern;

@end

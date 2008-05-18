//
//  IRCUserMode.h
//  iRelayChat
//
//  Created by Christian Speich on 07.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IRCUserMode : NSObject {
	bool hasOp;
	bool hasVoice;
}

- (id) initFromUserString:(NSString*)string;
- (id) initOp;
- (id) initVoice;
- (id) initOpAndVoice;

@property	bool	hasOp;
@property bool	hasVoice;

@end

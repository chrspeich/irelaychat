//
//  TestPlugin.h
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TestPlugin : NSObject {
	int _id;
	bool active;
}

@property(readonly) NSString *name;
@property(readonly) NSString *version;
@property(readonly) NSString *author;
@property(readonly) NSString *description;
@property(readonly) NSImage *icon;
@property bool active;

@end

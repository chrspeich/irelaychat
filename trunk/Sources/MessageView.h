//
//  MessageView.h
//  iRelayChat
//
//  Created by Christian Speich on 22.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MessageView : NSView {
	id			content;
	WebView		*webView;
}

@property(assign) id content;

@end

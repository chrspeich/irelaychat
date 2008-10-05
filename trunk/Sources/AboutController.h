//
//  AboutController.h
//  iRelayChat
//
//  Created by Christian Speich on 05.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AboutController : NSWindowController {
	IBOutlet WebView *webView;
	IBOutlet NSTextField *versionsField;
}

@end

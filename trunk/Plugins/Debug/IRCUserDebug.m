//
//  IRCUserDebug.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCUserDebug.h"
#import "InternetRelayChat.h"

@implementation IRCUserDebug

- (id) init
{
	self = [super init];
	if (self != nil) {
		prefsView = nil;
		serversArray = [[NSClassFromString(@"InternetRelayChat") sharedInternetRelayChat] servers];
	}
	return self;
}


+ (NSArray*) preferencePanes
{
	return nil;
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefsView) {
        loaded = [NSBundle loadNibNamed:@"IRCUserDebug" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Users";
}


- (NSImage *)paneIcon
{
    return [NSImage imageNamed:@"NSEveryone"];
}


- (NSString *)paneToolTip
{
    return @"Users";
}


- (BOOL)allowsHorizontalResizing
{
    return NO;
}


- (BOOL)allowsVerticalResizing
{
    return NO;
}

@end

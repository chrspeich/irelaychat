//
//  IRCMessagesDebug.m
//  iRelayChat
//
//  Created by Christian Speich on 31.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCMessagesDebug.h"


@implementation IRCMessagesDebug

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
        loaded = [NSBundle loadNibNamed:@"IRCMessagesDebug" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Messages";
}


- (NSImage *)paneIcon
{
    return nil;
}


- (NSString *)paneToolTip
{
    return @"Messages";
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

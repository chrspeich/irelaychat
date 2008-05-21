//
//  RawLog.m
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RawLog.h"
#import "InternetRelayChat.h"
#import "IRCServer.h"

@implementation RawLog

- (NSString*) name
{
	return @"RawLog";
}

- (NSString*) version
{
	return @"0.0.1";
}

- (NSString*) author
{
	return @"Christian Speich";
}

- (NSString*) description
{
	return @"Logs the all Messages thats are recived and sended.";
}

- (NSImage*) icon
{
	return nil;
}

- (void) log
{
	for (IRCServer *server in [[NSClassFromString(@"InternetRelayChat") sharedInternetRelayChat] servers]) {
		NSMutableString *log = [[NSMutableString alloc] init];
		
		for (NSDictionary *dict in [server messages]) {
			[log appendFormat:@"%@\n",[dict objectForKey:@"MESSAGE"]];
		}
		[log writeToFile:@"/Users/kleinweby/Desktop/Freenode.log" atomically:NO];
		[log release];
	}
}

- (bool) load
{
	[NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(log) userInfo:Nil repeats:YES];
	return YES;
}

- (void) unload
{
	NSLog(@"unload");
}

@end

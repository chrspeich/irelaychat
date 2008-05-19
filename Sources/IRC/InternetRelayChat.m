//
//  InternetRelayChat.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InternetRelayChat.h"


@implementation InternetRelayChat

@synthesize servers;

- (id) init
{
	self = [super init];
	if (self != nil) {
		servers = [[NSMutableArray alloc] init];
	}
	return self;
}


+ (id) sharedInternetRelayChat
{
	static id shared = nil;
	
	if (!shared)
		shared = [[self alloc] init];
	
	return shared;
}

@end

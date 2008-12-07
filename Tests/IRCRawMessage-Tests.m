//
//  IRCRawMessage-Tests.m
//  iRelayChat
//
//  Created by Christian Speich on 17.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCRawMessage-Tests.h"
#import "IRCRawMessage.h"

@implementation IRCRawMessage_Tests

- (void) testSplitingOfMessages {
	IRCRawMessage *rawMessage;
	NSArray *args;
	
	rawMessage = [[IRCRawMessage alloc] initWithCString:":zelazny.freenode.net 001 blablebl :Welcome to the freenode IRC Network blablebl" usingEncoding:NSUTF8StringEncoding];
	
	STAssertEqualObjects(@"zelazny.freenode.net", [rawMessage user], 
						 @"The User didnt match!");
	
	STAssertEqualObjects(@"001", [rawMessage command],
						 @"The Command should be '001' instand of '%@'",
						 [rawMessage command]);
	
	STAssertEquals(NSUTF8StringEncoding, (int)[rawMessage encoding],
				   @"The Encoding should be UTF8(%i) instand of '%i'",
				   NSUTF8StringEncoding, [rawMessage encoding]);
	
	args = [rawMessage args];
	
	STAssertEquals(2, (int)[args count],
				   @"The arguments count is wrong!",
				   [args count]);
	
	STAssertEqualObjects(@"blablebl", [args objectAtIndex:0],
						 @"First argument is wrong!",
						 [args objectAtIndex:0]);
	
	STAssertEqualObjects(@"Welcome to the freenode IRC Network blablebl", [args objectAtIndex:1],
						 @"The second argument is wrong!",
						 [args objectAtIndex:1]);
	
	NSLog(@"%@", rawMessage);
	
	[rawMessage release];
}

@end

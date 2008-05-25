//
//  HTMLCache.h
//  iRelayChat
//
//  Created by Christian Speich on 25.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HTMLCache : NSObject {
	NSMutableDictionary *cache;
}

+ (id) sharedCache;

- (NSString*) htmlForObject:(id)object;
- (void) clear;

@end

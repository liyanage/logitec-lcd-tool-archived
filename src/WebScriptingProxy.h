//
//  WebScriptingProxy.h
//  LogitechLCDTool
//
//  Created by Marc Liyanage on 28.12.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WebScriptingProxy : NSObject {
	id delegate;
	NSMutableDictionary *appleScripts;
	struct timeval lastUpdateTime;
}

- (id)initWithAppDelegate:(id)aDelegate;
- (void)setupAppleScripts;
- (BOOL)updateTooFrequent;
- (NSString *)runSystemScript:(NSString *)key;
- (void)registerUserScript:(NSString *)key code:(NSString *)code;
- (NSString *)runUserScript:(NSString *)key;
- (NSAppleScript *)compileAppleScript:(NSString *)code;
@end

@interface NSObject (WebScriptingProxyAppDelegate)

- (BOOL)webViewUpdatesAllowed;
- (void)clearOffscreenWebView;

@end

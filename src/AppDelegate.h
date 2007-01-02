/* AppDelegate */

#import <Cocoa/Cocoa.h>
#import "UsbHidDevice.h"
#import <WebKit/WebKit.h>
#import "AlwaysOnWindow.h"
#import "WebScriptingProxy.h"

#include <sys/time.h>

@interface AppDelegate : NSObject
{
	//NSString *imageUrl
	//NSString *htmlCode;
	NSString *selectedTabIdentifier;
	NSImage *currentImage;
	UsbHidDevice *uhd;
	AlwaysOnWindow *webViewWindow;
	WebView *offscreenWebView;
	WebScriptingProxy *scriptingProxy;
	BOOL allowWebViewUpdates;
	WebScriptObject *currentWindowScriptObject;
}

- (IBAction)displayUrlTabContents:(id)sender;
- (IBAction)displayHtmlTabContents:(id)sender;
- (IBAction)displayCurrentTabContents:(id)sender;
- (void)setupOffscreenWebView;
- (void)setupScriptingProxy;
- (void)clearOffscreenWebView;
- (BOOL)webViewUpdatesAllowed;
- (IBAction)showHelp:(id)sender;
- (void)setupNotificationSubscription;
- (void)runJavaScript:(NSString *)code;


@end



#import "AppDelegate.h"

@implementation AppDelegate


// http://www.rogueamoeba.com/utm/archives/rslight.c



- (void)awakeFromNib {
	uhd = [[UsbHidDevice alloc] init];
	[self setValue:@"htmlCode" forKey:@"selectedTabIdentifier"];
	[self setupOffscreenWebView];
	[self setupScriptingProxy];
	[self setupNotificationSubscription];
}


- (void)dealloc {
	[uhd release];
	[webViewWindow release];
	[scriptingProxy release];
	[super dealloc];
}


- (void)setupScriptingProxy {
	scriptingProxy = [[WebScriptingProxy alloc] initWithAppDelegate:self];
}


- (void)setupOffscreenWebView {
	webViewWindow = [[AlwaysOnWindow alloc] initWithContentRect:NSMakeRect(0, 0, 160, 43) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	offscreenWebView = [[[WebView alloc] initWithFrame:NSMakeRect(0, 0, 160, 43)] autorelease]; // retained by window
	[[webViewWindow contentView] addSubview:offscreenWebView];
	[webViewWindow setReleasedWhenClosed:NO];
	[offscreenWebView setFrameLoadDelegate:self];
	[offscreenWebView setUIDelegate:self]; // for JS alert()
}


- (void)setupNotificationSubscription {
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(buttonEventListener:)
		name:@"ButtonEvent" object:uhd];
}


- (void)buttonEventListener:(NSNotification *)notification {

	NSDictionary *userInfo = [notification userInfo];
	if ([userInfo valueForKey:@"isApplicationButton"]) {
		NSString *button = [userInfo valueForKey:@"button"];
		NSString *upDown = [userInfo valueForKey:@"upDown"];
		[self runJavaScript:[NSString stringWithFormat:@"handleButton('%@', '%@');", button, upDown]];
		return;
	}
	
	if (![[userInfo valueForKey:@"upDown"] isEqualToString:@"up"]) return;

	NSString *button = [userInfo valueForKey:@"button"];
	if (
		[button isEqualToString:@"PlayPause"] ||
		[button isEqualToString:@"PreviousTrack"] ||
		[button isEqualToString:@"NextTrack"]
	) {
		[scriptingProxy runSystemScript:[@"iTunes" stringByAppendingString:button]];
	}

}


- (void)runJavaScript:(NSString *)code {
	if (!currentWindowScriptObject) return;
	[currentWindowScriptObject evaluateWebScript:code];
}



- (IBAction)displayUrlTabContents:(id)sender {
	NSString *imageUrl = [[NSUserDefaults standardUserDefaults] valueForKey:@"imageUrl"];
	if (!imageUrl) {
		NSLog(@"sendImageAtUrl: NULL URL");
		return;
	}
	
	NSImage *img = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]] autorelease];
	[self setValue:img forKey:@"currentImage"];
	[uhd sendImage:[[img representations] objectAtIndex:0]];
}


- (IBAction)displayHtmlTabContents:(id)sender {
	NSString *htmlCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"htmlCode"];
	if (!htmlCode) return;
	allowWebViewUpdates = YES;
	[[offscreenWebView mainFrame] loadHTMLString:htmlCode baseURL:NULL];
	// continue in frame load completion delegate method below
}


- (IBAction)displayCurrentTabContents:(id)sender {
	if ([selectedTabIdentifier isEqualToString:@"htmlCode"]) {
		[self displayHtmlTabContents:sender];
	} else {
		[self clearOffscreenWebView];
		[self displayUrlTabContents:sender];
	}
}


- (void)captureWebView {
	[offscreenWebView display];
	[offscreenWebView lockFocus];
	NSBitmapImageRep *bmr = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, 160, 43)] autorelease];
	[offscreenWebView unlockFocus];
	NSImage *img = [[[NSImage alloc] initWithSize:NSMakeSize(160, 43)] autorelease];
	[img addRepresentation:bmr];
	[self setValue:img forKey:@"currentImage"];
	[uhd sendImage:bmr];
}


- (void)clearOffscreenWebView {
	allowWebViewUpdates = NO;
	[[offscreenWebView mainFrame] loadHTMLString:@"" baseURL:NULL];
}

- (BOOL)webViewUpdatesAllowed {
	return allowWebViewUpdates;
}

- (void)setupDefaultPrefs {
	NSString *prefsFile = [[NSBundle mainBundle] pathForResource:@"DefaultPrefs" ofType:@"plist"];
	NSDictionary *defaultPrefs = [NSDictionary dictionaryWithContentsOfFile:prefsFile];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	id key, keys = [defaultPrefs keyEnumerator];
	while (key = [keys nextObject]) {
		if ([defaults valueForKey:key]) continue;
		[defaults setValue:[defaultPrefs valueForKey:key] forKey:key];
	}
// registerDefaults doesn't seem to trigger KVO/bindings
/*    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
		@"http://www.entropy.ch/images/logitech-example.png", @"imageUrl",
		nil];
    [defaults registerDefaults:appDefaults];
*/
}



/* sent to first responder when the user selects the Help menu */

- (IBAction)showHelp:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.entropy.ch/software/macosx/lcdtool/?showhelp"]];
}



/* start app delegate methods */

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self setupDefaultPrefs];
}

/* end app delegate methods */



/* start WebView frame load delegate methods */

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	// NSLog(@"frameload finished %@", frame);
	if (!allowWebViewUpdates) return;
	[self performSelectorOnMainThread:@selector(captureWebView) withObject:nil waitUntilDone:NO];
}

- (void)webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject {
	[windowScriptObject setValue:scriptingProxy forKey:@"application"];
	[self setValue:windowScriptObject forKey:@"currentWindowScriptObject"];
}

/* end WebView frame load delegate methods */


/* start WebView ui delegate methods */

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message {
	NSLog(@"JavaScript alert message: %@", message);
}

/* end WebView ui delegate methods */



@end

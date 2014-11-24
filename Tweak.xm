/**
 *  IO Tracker
**/
#import <Foundation/Foundation.h>
#import "substrate.h"

#import "FLogObjectiveC.h"
#import "WebSocketServer/WebSocketServer.h"

%group NetIOHooks

%hook NSURLConnection
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
	DUMP_STACK("NSURLConnection sendSynchronousRequest:");

	FLogInfo("NSURLConnection sendSynchronousRequest: %s", TO_CSTR([request URL]));
#if LOG_LEVEL > LOG_LEVEL_FLOW
	FLogFlow("headers:\n%s", TO_CSTR([request allHTTPHeaderFields]));
	NSString *bodyText = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
	FLogFlow("body:\n%s", TO_CSTR(bodyText));
#endif

	NSData *responseData = %orig(request, response, error);
#if LOG_LEVEL > LOG_LEVEL_FLOW
	NSString *payload = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	FLogFlow("response:\n%s", TO_CSTR(payload));
#endif
	return responseData;
}
%end

%end	// end of group NetHooks


%group FileIOHooks

%hook NSData
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag {
	DUMP_STACK("NSData writeToFile:");

	BOOL origResult = %orig(path, flag);
	FLogWarn("NSData writeToFile(%s):atomically:", TO_CSTR(path));
	return origResult;
}
- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)mask error:(NSError **)errorPtr {
	DUMP_STACK("NSData writeToFile:");

	BOOL origResult = %orig(path, mask, errorPtr);
	FLogWarn("NSData writeToFile(%s):options:error:", TO_CSTR(path));
	return origResult;
}
%end

%hook NSFileHandle
+ (id)fileHandleForReadingAtPath:(NSString *)path {
	DUMP_STACK("NSFileHandle fileHandleForReadingAtPath:");
	
	id origResult = %orig(path);
	FLogWarn("NSFileHandle fileHandleForReadingAtPath(%s):", TO_CSTR(path));
	return origResult;
}
+ (id)fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)error {
	DUMP_STACK("NSFileHandle fileHandleForReadingFromURL:");

	id origResult = %orig(url, error);
	FLogWarn("NSFileHandle fileHandleForReadingFromURL(%s):", TO_CSTR(url));
	return origResult;
}
%end

%end	// end of group FileHooks

%group InitWebSocket

%hook UIApplication
- (id)init {
	self = %orig;
	if (self) {
		// init server when launched
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			NSLog(@"WebSocket - Server init");
			[[WebSocketServer sharedInstance] initialize];
		}];

		// start/stop server for background
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			NSLog(@"WebSocket - Server start");
			[[WebSocketServer sharedInstance] startServer];
		}];
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			NSLog(@"WebSocket - Server stop");
			[[WebSocketServer sharedInstance] stopServer];
		}];
	}

	return self;
}
%end

%end	// end of group InitHTTPServer


// NSLog to FLogInfo
MSHook(void, NSLogv, NSString *format, va_list args) {
	//DUMP_STACK("NSLog()");

	_NSLogv(format, args);

	NSString *logResult = [[NSString alloc] initWithFormat:format arguments:args];
	FLogInfo("%s", TO_CSTR(logResult));
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"IOTracker Init");

	// Init FileLog
	NSString *filename;
	if ([[NSBundle mainBundle] bundleIdentifier]) {
		filename = [NSString stringWithFormat:@"%@_iotrace.log", [[NSBundle mainBundle] bundleIdentifier]];
	} else {
		filename = @"nobundle_iotrace.log";
	}
	[[FLogObjectiveC sharedInstance] initWithFileName:filename path:@"/var/logs/filelog" maxLine:50000];

	// export NSLog to FLogInfo
	MSHookFunction(NSLogv, MSHake(NSLogv));


	// Hooks
	%init(NetIOHooks);			// HTTP/openURL
	%init(FileIOHooks);			// File/Data

	// WebSocket
	%init(InitWebSocket);

	[pool drain];
}
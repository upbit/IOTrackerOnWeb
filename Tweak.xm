/**
 *  IO Tracker
**/
#import <Foundation/Foundation.h>
#import <CFNetwork/CFHTTPMessage.h>
#import "substrate.h"

#import "FLogObjectiveC.h"
#import "NSURLConnectionDelegateProxy.h"
#import "WebSocketServer/WebSocketServer.h"

#pragma mark - NetIOHooks

%group NetIOHooks

%hook NSURLConnection

- (id)initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate {
	NSURLConnectionDelegateProxy *delegateProxy = [[NSURLConnectionDelegateProxy alloc] initWithOriginalDelegate:delegate];
	id origResult = %orig(request, delegateProxy);
	return origResult;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately {
	NSURLConnectionDelegateProxy *delegateProxy = [[NSURLConnectionDelegateProxy alloc] initWithOriginalDelegate:delegate];
	id origResult = %orig(request, delegateProxy, startImmediately);
	return origResult;
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
	DUMP_STACK("NSURLConnection sendSynchronousRequest:");

	FLogWarn("NSURLConnection sendSynchronousRequest: %s", TO_CSTR([request URL]));
#if LOG_LEVEL >= LOG_LEVEL_FLOW
	FLogFlow("headers:\n%s", TO_CSTR([request allHTTPHeaderFields]));
	NSString *bodyText = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
	if (bodyText) {
		FLogFlow("body:\n%s", TO_CSTR(bodyText));
	}
#endif

	NSData *responseData = %orig(request, response, error);
#if LOG_LEVEL >= LOG_LEVEL_FLOW
	NSString *payload = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	if (payload) {
		FLogFlow("%s response:\n%s", TO_CSTR([request URL]), TO_CSTR(payload));
	}
#endif
	return responseData;
}

%end

%end	// end of group NetHooks

#pragma mark - C/C++ Hooks

// NSLog to FLogInfo
MSHook(void, NSLogv, NSString *format, va_list args) {
	//DUMP_STACK("NSLog()");

	_NSLogv(format, args);

	NSString *logResult = [[NSString alloc] initWithFormat:format arguments:args];
	FLogInfo("%s", TO_CSTR(logResult));
}

/*
static int (*original_connect)(int sockfd, struct sockaddr * serv_addr, int addrlen);
static int replaced_connect(int sockfd, struct sockaddr * serv_addr, int addrlen) {
	DUMP_STACK("connect()");
	return original_connect(sockfd, serv_addr, addrlen);
}

static int (*original_send)(int sockfd, const void *buf, size_t len, int flags);
static int replaced_send(int sockfd, const void *buf, size_t len, int flags) {
	DUMP_STACK("send()");
	return original_send(sockfd, buf, len, flags);
}

//MSHookFunction((void *)connect, (void *)replaced_connect, (void **) &original_connect);
//MSHookFunction((void *)send, (void *)replaced_send, (void **) &original_send);
*/

#pragma mark - WebSocket

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

#pragma mark - %ctor

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

	// WebSocket
	%init(InitWebSocket);

	[pool drain];
}
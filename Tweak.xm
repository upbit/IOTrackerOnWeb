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

%hook __NSCFURLSession

- (id)dataTaskWithURL:(NSURL *)url {
	FLogWarn("NSURLSession dataTaskWithURL: %s", TO_CSTR(url));
	id origResult = %orig(url);
	return origResult;
}

- (id)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
	FLogWarn("NSURLSession dataTaskWithURL:completionHandler: %s", TO_CSTR(url));
/*
	void (^replace_completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = ^(NSData *data, NSURLResponse *response, NSError *error) {
		completionHandler(data, response, error);

#if LOG_LEVEL >= LOG_LEVEL_FLOW
		if (!error) {
			NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			FLogFlow("NSURLSession dataTaskWithURL:completionHandler: response:\n%s", TO_CSTR(payload));
		} else {
			FLogFlow("NSURLSession dataTaskWithURL:completionHandler: error:%s", TO_CSTR(error));
		}
#endif
	};
*/
	id origResult = %orig(url, completionHandler);
	return origResult;
}

- (id)dataTaskWithRequest:(NSURLRequest *)request {
	FLogWarn("NSURLSession dataTaskWithRequest: %s", TO_CSTR(request));
	id origResult = %orig(request);
	return origResult;
}

- (id)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
	FLogWarn("NSURLSession dataTaskWithRequest:completionHandler: %s", TO_CSTR(request));
	id origResult = %orig(request, completionHandler);
	return origResult;
}

%end


%hook UIWebView

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)encodingName baseURL:(NSURL *)baseURL {
	DUMP_STACK("UIWebView loadData:baseURL:");

	FLogWarn("UIWebView loadData:baseURL: %s", TO_CSTR(baseURL));
	FLogFlow("data(%s, %s):\n%s", TO_CSTR(MIMEType), TO_CSTR(encodingName), TO_CSTR(data));

	%orig(data, MIMEType, encodingName, baseURL);
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	DUMP_STACK("UIWebView loadHTMLString:baseURL:");

	FLogWarn("UIWebView loadHTMLString:baseURL: %s", TO_CSTR(baseURL));
	FLogFlow("html:\n%s", TO_CSTR(string));

	%orig(string, baseURL);
}

- (void)loadRequest:(NSURLRequest *)request {
	DUMP_STACK("UIWebView loadRequest:");

	FLogWarn("UIWebView loadRequest: %s", TO_CSTR([request URL]));
#if LOG_LEVEL >= LOG_LEVEL_FLOW
	FLogFlow("headers:\n%s", TO_CSTR([request allHTTPHeaderFields]));
	NSString *bodyText = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
	FLogFlow("body:\n%s", TO_CSTR(bodyText));
#endif

	%orig(request);
}

%end


%hook UIApplication

- (BOOL)openURL:(NSURL *)url {
	DUMP_STACK("UIApplication openURL:");

	FLogWarn("UIApplication openURL: %s", TO_CSTR(url));
	return %orig(url);
}

- (BOOL)canOpenURL:(NSURL *)url {
	DUMP_STACK("UIApplication canOpenURL:");

	FLogWarn("UIApplication canOpenURL: %s", TO_CSTR(url));
	return %orig(url);
}

%end

%end	// end of group NetHooks


#pragma mark - FileIOHooks

%group FileIOHooks

%hook NSData
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag {
	//DUMP_STACK("NSData writeToFile:");

	BOOL origResult = %orig(path, flag);
	FLogWarn("NSData writeToFile:atomically: %s", TO_CSTR(path));
	return origResult;
}
- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)mask error:(NSError **)errorPtr {
	//DUMP_STACK("NSData writeToFile:");

	BOOL origResult = %orig(path, mask, errorPtr);
	FLogWarn("NSData writeToFile:options:error: %s", TO_CSTR(path));
	return origResult;
}
%end

%hook NSFileHandle

+ (id)fileHandleForReadingAtPath:(NSString *)path {
	DUMP_STACK("NSFileHandle fileHandleForReadingAtPath:");
	
	id origResult = %orig(path);
	FLogWarn("NSFileHandle fileHandleForReadingAtPath: %s", TO_CSTR(path));
	return origResult;
}
+ (id)fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)error {
	DUMP_STACK("NSFileHandle fileHandleForReadingFromURL:");

	id origResult = %orig(url, error);
	FLogWarn("NSFileHandle fileHandleForReadingFromURL: %s", TO_CSTR(url));
	return origResult;
}

%end

%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path {
	FLogWarn("NSFileManager fileExistsAtPath: %s", TO_CSTR(path));
	return %orig(path);
}
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
	FLogWarn("NSFileManager fileExistsAtPath:isDirectory: %s", TO_CSTR(path));
	return %orig(path, isDirectory);
}

- (NSData *)contentsAtPath:(NSString *)path {
	FLogWarn("NSFileManager contentsAtPath: %s", TO_CSTR(path));
	return %orig(path);
}

%end

%end	// end of group FileHooks

#pragma mark - C/C++ Hooks

// NSLog to FLogInfo
MSHook(void, NSLogv, NSString *format, va_list args) {
	//DUMP_STACK("NSLog()");

	_NSLogv(format, args);

	NSString *logResult = [[NSString alloc] initWithFormat:format arguments:args];
	FLogInfo("%s", TO_CSTR(logResult));
}

MSHook(CFHTTPMessageRef, CFHTTPMessageCreateRequest, CFAllocatorRef alloc, CFStringRef requestMethod, CFURLRef url, CFStringRef httpVersion) {
	DUMP_STACK("CFHTTPMessageCreateRequest()");

	FLogWarn("CFHTTPMessageCreateRequest: %s %s %s", TO_CSTR(requestMethod), TO_CSTR(url), TO_CSTR(httpVersion));

	CFHTTPMessageRef origResult = _CFHTTPMessageCreateRequest(alloc, requestMethod, url, httpVersion);
	return origResult;
};

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
	%init(FileIOHooks);			// File/Data

	// CFNetwork Hooks
	MSHookFunction(CFHTTPMessageCreateRequest, MSHake(CFHTTPMessageCreateRequest));


	// WebSocket
	%init(InitWebSocket);

	[pool drain];
}
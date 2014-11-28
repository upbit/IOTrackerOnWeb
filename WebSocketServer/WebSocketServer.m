#import "WebSocketServer.h"
#import "WebSocketConnection.h"

#define LISTEN_PORT		(8080)			// WebServer port
#define MAX_RETRY_NUM	(5)				// max retry for default port, 5 for delay (2+4+8+16) secs

@implementation WebSocketServer

+ (WebSocketServer *)sharedInstance {
	static WebSocketServer *sharedInstance = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (void)initialize {
	static dispatch_once_t once;
	
	dispatch_once(&once, ^{
		NSLog(@"WebSocket - Initializing Server on: %@", [[NSBundle mainBundle] bundleIdentifier]);

		httpServer = [[HTTPServer alloc] init];
		[httpServer setConnectionClass:[WebSocketConnection class]];

		[httpServer setType:@"_http._tcp."];

		[httpServer setPort:LISTEN_PORT];
		[httpServer setDocumentRoot:@"/var/www/filelog"];

		[self startServer];
	});
}

- (void)startServer {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSError *error = nil;
		int max_retry = MAX_RETRY_NUM;

		while (max_retry-- > 0) {
			// openURL: will cause Code=48 "Address already in use", just sleep and retry
			if (max_retry == 0) {
				[httpServer setPort:0];		// last retry, use auto port
			}

			BOOL ret = [httpServer start:&error];
			if (ret) {
				NSLog(@"WebSocket - Listen on port %d", [httpServer listeningPort]);
				break;
			}

			int sleep_time = 2;
			for (int i = MAX_RETRY_NUM-max_retry; i > 1; i--) {
				sleep_time *= 2;
			}
			NSLog(@"WebSocket - Error restart server: %@, retry last %d sleep %ds", error, max_retry, sleep_time);
			sleep(sleep_time);
		}
	});
}

- (void)stopServer {
	[httpServer stop];
}

@end

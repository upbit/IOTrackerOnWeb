#import "WebSocketServer.h"
#import "WebSocketConnection.h"

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

		[httpServer setPort:8080];
		[httpServer setDocumentRoot:@"/var/www/filelog"];

		[self startServer];
	});
}

- (void)startServer {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSError *error = nil;
		int max_retry = 10;

		while (max_retry-- > 0) {
			// openURL: will cause Code=48 "Address already in use", just sleep and retry
			BOOL ret = [httpServer start:&error];
			if (ret) {
				NSLog(@"WebSocket - Listen on port %d", [httpServer listeningPort]);
				break;
			}

			NSLog(@"WebSocket - Error restart server: %@, retry last %d", error, max_retry);
			sleep(3);
		}
	});
}

- (void)stopServer {
	[httpServer stop];
}

@end

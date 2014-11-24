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
		
		NSError *error = nil;
		if (![httpServer start:&error]) {
			NSLog(@"WebSocket - Error starting Server: %@", error);
			return;
		}
	});
}

- (BOOL)startServer {
	NSError *error;
	BOOL ret = [httpServer start:&error];
	if (!ret) {
		NSLog(@"Error start WebSocket server: %@", error);
	}
	return ret;
}

- (void)stopServer {
	[httpServer stop];
}

@end

#import "WebSocketConnection.h"
#import "FLogObjectiveC.h"

#import "HTTPResponse.h"
#import "HTTPMessage.h"
#import "HTTPDynamicFileResponse.h"
#import "GCDAsyncSocket.h"

#import "FilelogWebSocket.h"

@implementation WebSocketConnection

- (NSDictionary *)replaceWebSocketLocationWithName:(NSString *)socketName {
	NSMutableDictionary *replaceDict = [NSMutableDictionary dictionary];

	// WEBSOCKET_URL
	NSString *wsLocation;
	NSString *wsHost = [request headerField:@"Host"];
	if (wsHost == nil) {
		NSString *port = [NSString stringWithFormat:@"%hu", [asyncSocket localPort]];
		wsLocation = [NSString stringWithFormat:@"ws://localhost:%@/%@", port, socketName];
	} else {
		wsLocation = [NSString stringWithFormat:@"ws://%@/%@", wsHost, socketName];
	}
	[replaceDict setObject:wsLocation forKey:@"WEBSOCKET_URL"];

	// FILELOG_NAME
	NSString *full_path = [[FLogObjectiveC sharedInstance] fullPath];
	[replaceDict setObject:full_path forKey:@"FILELOG_NAME"];

	return replaceDict;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
	NSLog(@"WebSocket - [HTTP %@] %@", method, path);

	if (([path isEqualToString:@"/"]) || ([path isEqualToString:@"/index.html"])) {
		return [[HTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path] forConnection:self
						   separator:@"%%" replacementDictionary:[self replaceWebSocketLocationWithName:@"flog"]];
	}

	return [super httpResponseForMethod:method URI:path];
}

- (WebSocket *)webSocketForURI:(NSString *)path
{
	NSLog(@"WebSocket - [ws] %@", path);
	
	if ([path isEqualToString:@"/flog"]) {
		return [[FilelogWebSocket alloc] initWithRequest:request socket:asyncSocket];		
	}
	
	return [super webSocketForURI:path];
}

@end

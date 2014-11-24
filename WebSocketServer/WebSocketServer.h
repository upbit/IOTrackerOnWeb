#ifndef __WEB_SOCKET_SERVER_H__
#define __WEB_SOCKET_SERVER_H__

#import <Foundation/Foundation.h>
#import "HTTPServer.h"

@interface WebSocketServer : NSObject {
@public
	HTTPServer *httpServer;
}

+ (WebSocketServer *)sharedInstance;
- (void)initialize;
- (BOOL)startServer;
- (void)stopServer;

@end

#endif
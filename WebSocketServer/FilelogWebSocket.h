#ifndef __FILELOG_WEB_SOCKET_H__
#define __FILELOG_WEB_SOCKET_H__

#import "WebSocket.h"

@interface FilelogWebSocket : WebSocket {}
@property (assign) int slavePTY;
@property (assign) int masterPTY;
@property (assign) pid_t childPID;
@end

#endif

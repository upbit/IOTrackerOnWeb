#ifndef __FILELOG_OBJECTIVE_C_H__
#define __FILELOG_OBJECTIVE_C_H__

#include "filelog.h"

/**
 * -DLOG_LEVEL=
 *	0 - Disable					LOG_LEVEL_DISABLE
 *	1 - Error					LOG_LEVEL_ERROR
 *	2 - Warning					LOG_LEVEL_WARN
 *	3 - Info					LOG_LEVEL_INFO
 *	4 - Debug					LOG_LEVEL_DEBUG
 *	5 - Flow					LOG_LEVEL_FLOW / LOG_LEVEL_ALL
**/

// Usage:
//	NSString *filename = [NSString stringWithFormat:@"%@_trace", [[NSBundle mainBundle] bundleIdentifier]];
//	[[FLogObjectiveC sharedInstance] initWithFileName:filename path:@"" maxLine:10000];
@interface FLogObjectiveC : NSObject {
@public
	logfile_t stLog;
	logfile_t *pstLog;
}

+ (FLogObjectiveC *)sharedInstance;
- (void)initWithFileName:(NSString *)filename path:(NSString *)path maxLine:(NSUInteger)maxLine;
- (NSString *)fullPath;
@end

// Fast Marcos
#define INSTANCE_FILELOG 		([FLogObjectiveC sharedInstance]->pstLog)

#define FLogError(fmt, ...)		LOG_ERROR(INSTANCE_FILELOG, fmt, ##__VA_ARGS__)
#define FLogWarn(fmt, ...)		LOG_WARN(INSTANCE_FILELOG, fmt, ##__VA_ARGS__)
#define FLogInfo(fmt, ...)		LOG_INFO(INSTANCE_FILELOG, fmt, ##__VA_ARGS__)
#define FLogDebug(fmt, ...)		LOG_DEBUG(INSTANCE_FILELOG, fmt, ##__VA_ARGS__)
#define FLogFlow(fmt, ...)		LOG_FLOW(INSTANCE_FILELOG, fmt, ##__VA_ARGS__)

// Helper Marcos
#define TO_CSTR(id)				[[NSString stringWithFormat:@"%@", id] cStringUsingEncoding:NSUTF8StringEncoding]
#define DUMP_STACK(msg)			FLogFlow("%s\n%s", msg, TO_CSTR([NSThread callStackSymbols]))

#endif
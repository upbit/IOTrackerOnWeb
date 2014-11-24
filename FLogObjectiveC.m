#include "FLogObjectiveC.h"

@implementation FLogObjectiveC

+ (FLogObjectiveC *)sharedInstance {
	static FLogObjectiveC *sharedInstance = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (void)initWithFileName:(NSString *)filename path:(NSString *)path maxLine:(NSUInteger)maxLine {
	static dispatch_once_t once;
	
	dispatch_once(&once, ^{
		pstLog = &stLog;
		
		NSString *full_path = [NSString stringWithFormat:@"%@/%@", path, filename];
		NSLog(@"FLogObjectiveC PATH: %@", full_path);

		INIT_LOG(pstLog, (const char *)[full_path cStringUsingEncoding:NSUTF8StringEncoding], (const unsigned long)maxLine);
	});
}

- (NSString *)fullPath {
	return [[NSString alloc] initWithCString:(const char*)pstLog->szLogPath encoding:NSUTF8StringEncoding];
}

@end

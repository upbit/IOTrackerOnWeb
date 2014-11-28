// Modify from Introspy-iOS
// https://github.com/iSECPartners/Introspy-iOS/blob/master/src/hooks/NSURLConnectionDelegateProx.m
#import "NSURLConnectionDelegateProxy.h"
#import "FLogObjectiveC.h"

@implementation NSURLConnectionDelegateProxy

@synthesize originalDelegate;

- (NSURLConnectionDelegateProxy*)initWithOriginalDelegate:(id)origDelegate {
	self = [super init];
	if (self) {
		self.originalDelegate = origDelegate;
	}
	return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	return [originalDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)sel {
	return originalDelegate;
}

- (void)dealloc {
	[originalDelegate release];
	[super dealloc];
}

#pragma mark - HOOKS

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DUMP_STACK("NSURLConnectionDelegate connection:didReceiveResponse:");

	FLogWarn("NSURLConnectionDelegate connection:didReceiveResponse: (%s) %s", TO_CSTR([response MIMEType]), TO_CSTR([response URL]));

	[originalDelegate connection:connection didReceiveResponse:response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	DUMP_STACK("NSURLConnectionDelegate connection:didReceiveData:");

	[originalDelegate connection:connection didReceiveData:data];

#if LOG_LEVEL >= LOG_LEVEL_FLOW
	NSString *bodyText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (bodyText) {
		// cut bodyText down if too long
		if ([bodyText length] > 2048) {
			bodyText = [[bodyText substringWithRange:NSMakeRange(0, 2048)] stringByAppendingString:@" ..."];
		}
		FLogFlow("%s body:\n%s", TO_CSTR([connection.currentRequest URL]), TO_CSTR(bodyText));
	}
#endif
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	DUMP_STACK("NSURLConnectionDelegate connection:willCacheResponse:");

	NSURLRequest *request = connection.currentRequest;
	FLogWarn("NSURLConnectionDelegate connection:willCacheResponse: %s", TO_CSTR([request URL]));

	NSCachedURLResponse * origResult = [originalDelegate connection:connection willCacheResponse:cachedResponse];

#if LOG_LEVEL >= LOG_LEVEL_FLOW
	NSString *bodyText = [[NSString alloc] initWithData:[origResult data] encoding:NSUTF8StringEncoding];
	FLogFlow("body:\n%s", TO_CSTR(bodyText));
#endif
	return origResult;
}

@end

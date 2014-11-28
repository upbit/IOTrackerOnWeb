#ifndef __NSURL_CONNECTION_DELEGATE_PROXY_H__
#define __NSURL_CONNECTION_DELEGATE_PROXY_H__

// Modify from Introspy-iOS
// https://github.com/iSECPartners/Introspy-iOS/blob/master/src/hooks/NSURLConnectionDelegateProx.h

@interface NSURLConnectionDelegateProxy : NSObject <NSURLConnectionDelegate> {
	id originalDelegate;		// The NSURLConnectionDelegate we're going to proxy
}

// Need retain or the delegate gets freed before we're done using it.
@property (retain) id originalDelegate;

- (NSURLConnectionDelegateProxy*)initWithOriginalDelegate:(id)origDelegate;

// Mirror the original delegate's list of implemented methods
- (BOOL)respondsToSelector:(SEL)sel;
- (id)forwardingTargetForSelector:(SEL)sel;
- (void)dealloc;

#pragma mark - HOOKS

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;

@end

#endif
/**
 *  IO Tracker
**/
#import <Foundation/Foundation.h>
#import <CFNetwork/CFHTTPMessage.h>
#import "substrate.h"

#import "FLogObjectiveC.h"
#import "NSURLConnectionDelegateProxy.h"
#import "WebSocketServer/WebSocketServer.h"

@interface WFeedSource : NSObject <NSCoding, NSCopying> {
	BOOL _userGenerated;
	BOOL _userRemoved;
	unsigned _sourceType;
	NSString* _name;
	NSString* _uuid;
	NSString* _thumbnailUrl;
	UIImage* _thumbnail;
}
@property(assign, nonatomic, getter=isUserRemoved) BOOL userRemoved;
@property(assign, nonatomic, getter=isUserGenerated) BOOL userGenerated;
@property(retain, nonatomic) UIImage* thumbnail;
@property(retain, nonatomic) NSString* thumbnailUrl;
@property(retain, nonatomic) NSString* uuid;
@property(retain, nonatomic) NSString* name;
@property(assign, nonatomic) unsigned sourceType;
+(id)feedSourceWithUserGeneratedTopic:(id)userGeneratedTopic;
+(id)feedSourceWithDictionary:(id)dictionary sourceType:(unsigned)type;
+(id)feedSourceWithDictionary:(id)dictionary;
-(id)copyWithZone:(NSZone*)zone;
-(void)encodeWithCoder:(id)coder;
-(id)initWithCoder:(id)coder;
-(id)thumbnailNotificationName;
-(id)thumbnailCachePath;
-(id)topicDictionaryRepresentation;
-(unsigned)hash;
-(BOOL)isEqual:(id)equal;
-(id)initWithUserGeneratedTopic:(id)userGeneratedTopic;
-(id)initWithDictionary:(id)dictionary sourceType:(unsigned)type;
@end

@interface WPagableFeed : NSObject {
	BOOL _endReached;
	NSString* _scrollId;
}
@property(assign, nonatomic, getter=isEndReached) BOOL endReached;
@property(retain, nonatomic) NSString* scrollId;
@end

@interface WFeed : WPagableFeed {
	BOOL _requireLocation;
	BOOL _timeSortAsc;
	BOOL _sortValueAsc;
	BOOL _ignoreSortValue;
	BOOL _persistedFeed;
	unsigned _feedType;
	NSString* _reqType;
	NSString* _uuid;
	NSString* _name;
	NSString* _displayName;
	NSString* _endpoint;
	NSString* _fetchKey;
	WFeedSource* _feedSource;
	NSString* _wid;
	int _countLimit;
	NSNumber* _whisperCount;
	NSNumber* _heartCount;
	NSString* _fetchSort;
	double _latitude;
	double _longitude;
}
@property(retain, nonatomic) NSString* fetchSort;
@property(assign, nonatomic) double longitude;
@property(assign, nonatomic) double latitude;
@property(retain, nonatomic) NSNumber* heartCount;
@property(retain, nonatomic) NSNumber* whisperCount;
@property(assign, nonatomic) int countLimit;
@property(assign, nonatomic) BOOL persistedFeed;
@property(assign, nonatomic) BOOL ignoreSortValue;
@property(assign, nonatomic) BOOL sortValueAsc;
@property(assign, nonatomic) BOOL timeSortAsc;
@property(readonly, assign, nonatomic) NSString* wid;
@property(readonly, assign, nonatomic) WFeedSource* feedSource;
@property(readonly, assign, nonatomic) BOOL requireLocation;
@property(readonly, assign, nonatomic) NSString* fetchKey;
@property(readonly, assign, nonatomic) NSString* endpoint;
@property(readonly, assign, nonatomic) NSString* displayName;
@property(readonly, assign, nonatomic) NSString* name;
@property(readonly, assign, nonatomic) NSString* uuid;
@property(readonly, assign, nonatomic) NSString* reqType;
@property(assign, nonatomic) unsigned feedType;
+(id)feedWithDictionary:(id)dictionary endpoint:(id)endpoint fetchKey:(id)key reqType:(id)type;
+(id)feedWithSearchQuery:(id)searchQuery;
+(id)feedWithRelatedWid:(id)relatedWid;
+(id)feedWithParentWid:(id)parentWid;
+(id)feedWithNearbyFeedSource:(id)nearbyFeedSource;
+(id)feedWithFeedSource:(id)feedSource;
+(id)feedWithDefaultFeedType:(unsigned)defaultFeedType;
-(void)encodeWithCoder:(id)coder;
-(id)initWithCoder:(id)coder;
-(BOOL)canShareFeed;
-(BOOL)canEnableNearby;
-(id)additionalParameters;
-(id)updateNotificationName;
-(id)fetchNotificationName;
-(BOOL)isEqual:(id)equal;
-(id)initWithSearchQuery:(id)searchQuery;
-(id)initWithRelatedWid:(id)relatedWid;
-(id)initWithParentWid:(id)parentWid;
-(id)initWithFeedSource:(id)feedSource nearby:(BOOL)nearby;
-(id)initWithDefaultFeedType:(unsigned)defaultFeedType;
-(id)initWithUuid:(id)uuid name:(id)name displayName:(id)name3 endpoint:(id)endpoint fetchKey:(id)key;
-(id)initWithDictionary:(id)dictionary endpoint:(id)endpoint fetchKey:(id)key reqType:(id)type;
@end

@interface WFeedItem : NSObject {
}
@property(assign, nonatomic) double sortValue;
@property(retain, nonatomic) NSString* shortUrl;
@property(retain, nonatomic) NSString* imageUrl;
@property(retain, nonatomic) NSString* text;
@property(retain, nonatomic) NSDate* timeStamp;
@property(retain, nonatomic) NSString* feedUuid;
-(void)refreshFromDictionary:(id)dictionary feed:(id)feed;
-(void)primitiveAddToFeed:(id)feed;
-(void)primitiveRefreshFromDictionary:(id)dictionary;
@end

@interface WWhisper : WFeedItem {
	BOOL _hasImage;
	BOOL _hasThumbnail;
	UIImage* _thumbnail;
	UIImage* _image;
	UIImage* renderTextImage;
	NSMutableArray* _recentRepliesObjsCache;
}
@property(retain, nonatomic) NSMutableArray* recentRepliesObjsCache;
@property(retain, nonatomic) NSData* displayGroup;
@property(retain, nonatomic) NSNumber* fontType;
@property(retain, nonatomic) NSString* avatar;
@property(retain, nonatomic) NSString* inReplyToWid;
@property(retain, nonatomic) NSString* replyWid;
@property(retain, nonatomic) NSString* replyText;
@property(retain, nonatomic) NSNumber* replyOrdinal;
@property(retain, nonatomic) UIImage* renderTextImage;
@property(readonly, assign, nonatomic) UIImage* thumbnail;
@property(readonly, assign, nonatomic) BOOL hasThumbnail;
@property(readonly, assign, nonatomic) UIImage* image;
@property(readonly, assign, nonatomic) BOOL hasImage;
@property(retain, nonatomic) NSArray* groups;
@property(readonly, assign, nonatomic) NSString* turboshareButtonText;
@property(readonly, assign, nonatomic) NSString* turboshareTitle;
@property(readonly, assign, nonatomic) BOOL turboshare;
@property(retain, nonatomic) NSData* recentReplies;
@property(retain, nonatomic) NSNumber* gender;
@property(retain, nonatomic) NSString* puid;
@property(retain, nonatomic) NSString* nickname;
@property(retain, nonatomic) NSNumber* distance;
@property(retain, nonatomic) NSNumber* hearted;
@property(retain, nonatomic) NSNumber* replyCount;
@property(retain, nonatomic) NSNumber* heartCount;
@property(retain, nonatomic) NSString* location;
@property(retain, nonatomic) NSNumber* mine;
@property(retain, nonatomic) NSString* parentWid;
@property(readonly, assign, nonatomic) NSString* wid;
+(id)whisperWithWhisper:(id)whisper feed:(id)feed;
+(id)whisperWithProxy:(id)proxy feed:(id)feed context:(id)context;
+(id)whisperWithDictionary:(id)dictionary feed:(id)feed context:(id)context;
-(void)dealloc;
-(void)gotThumbnail:(id)thumbnail;
-(void)gotImage:(id)image;
-(void)checkCache;
-(void)primitiveRefreshFromWhisper:(id)whisper;
-(void)primitiveRefreshFromProxy:(id)proxy;
-(id)lowQualityImageUrl;
-(id)largeThumbnailUrl;
-(id)thumbnailUrl;
-(id)watermarkedImageUrl;
-(void)clearThumbnail;
-(void)clearImage;
-(void)addAdditionalGroups:(id)groups;
-(BOOL)hasReplies;
-(id)signatureNickname;
-(id)placeName;
-(id)readableDistance;
-(id)replyCountString;
-(id)heartCountString;
-(id)timeAgoLong;
-(id)timeAgo;
-(id)displayFeed;
-(void)refreshFromDictionary:(id)dictionary feed:(id)feed;
-(void)primitiveAddToFeed:(id)feed;
-(void)addRecentReply:(id)reply;
-(id)recentRepliesObjs;
-(void)refreshReplyListFromArray:(id)array;
-(void)refreshRecentRepliesCache;
-(void)primitiveRefreshFromDictionary:(id)dictionary;
-(void)didTurnIntoFault;
-(void)awakeFromFetch;
-(void)awakeFromInsert;
-(id)initWithWhisper:(id)whisper feed:(id)feed;
-(id)initWithProxy:(id)proxy feed:(id)feed context:(id)context;
-(id)initWithDictionary:(id)dictionary feed:(id)feed context:(id)context;
-(id)initWithFeed:(id)feed context:(id)context;
@end

@interface WSecurity : NSObject {
}
+(unsigned)zerosInString:(id)string;
+(id)hashBaseString:(id)string counter:(unsigned)counter;
+(void)tryHashCash;
+(id)dataFromImageWithWhisperExif:(id)whisperExif;
+(id)base64EncodedString:(id)string;
+(id)sha1Nonce:(id)nonce secret:(id)secret;
+(id)sharedSecretWithPin:(id)pin uid:(id)uid;
+(id)md5Image:(id)image;
+(id)md5String:(id)string;
+(int)hashStringByMD5:(id)a5;
+(unsigned)hostFromUrl:(id)url;
+(void)erasePersistentDataAndImages;
+(id)messagingSocketAuthenticationData;
+(id)whisperSocketAuthenticationData;
+(id)authenticatedHeadersForPin:(id)pin uid:(id)uid;
+(id)authenticatedHeadersForPin:(id)pin;
+(id)authenticatedHeaders;
+(id)unauthenticatedHeadersWithoutUid;
+(id)unauthenticatedHeaders;
@end

#pragma mark - MTA

/*
@interface MTAEnv : NSObject {
	BOOL _jailbroken;
	NSString* _platform;
	NSString* _os_version;
	NSString* _language;
	NSString* _resolution;
	NSString* _deviceid;
	NSString* _mccmnc;
	NSString* _timezone;
	NSString* _app_version;
	NSString* _sdk_version;
	NSString* _devicename;
	NSString* _modulename;
	NSUUID* _ifa;
	NSUUID* _ifv;
	NSString* _wf;
}
@property(retain, nonatomic) NSString* wf;
@property(assign) BOOL jailbroken;
@property(retain, nonatomic) NSUUID* ifv;
@property(retain, nonatomic) NSUUID* ifa;
@property(retain, nonatomic) NSString* modulename;
@property(retain, nonatomic) NSString* devicename;
@property(retain, nonatomic) NSString* sdk_version;
@property(retain, nonatomic) NSString* app_version;
@property(retain, nonatomic) NSString* timezone;
@property(retain, nonatomic) NSString* mccmnc;
@property(retain, nonatomic) NSString* deviceid;
@property(retain, nonatomic) NSString* resolution;
@property(retain, nonatomic) NSString* language;
@property(retain, nonatomic) NSString* os_version;
@property(retain, nonatomic) NSString* platform;
-(void)dealloc;
@end

@interface MTAUser : NSObject {
	NSString* _uid;
	int _userType;
	NSString* _appVer;
	unsigned _tagTime;
}
@property(assign) unsigned tagTime;
@property(retain, nonatomic) NSString* appVer;
@property(assign) int userType;
@property(retain, nonatomic) NSString* uid;
-(void)dealloc;
@end

@interface MTAHelper : NSObject {
	MTAEnv* env;
	MTAUser* user;
	BOOL _MTAEnableFlag;
}
@property(assign) BOOL MTAEnableFlag;
+(id)getInstance;
+(BOOL)isWiFiAvailable;
+(id)getMacAddress;
+(int)GUnzip:(id)unzip Out:(id*)anOut;
+(int)GZip:(id)zip Out:(id*)anOut;
+(void)ChiperRC4:(id)a4;
-(id)getJson:(id)json;
-(void)saveMid:(id)mid;
-(id)getMid;
-(BOOL)checkMTAEnable;
-(id)fetchSSIDInfo;
-(void)dealloc;
-(id)init;
-(id)getUser;
-(id)getEnv;
@end

@interface MTADispatcher : NSObject {
	dispatch_queue_s* task_queue;
	CFArrayRef streams;
}
+(id)getInstance;
-(void)speedTest:(id)test;
-(id)splitSpeedString:(id)string;
-(id)taSocket:(id)socket;
-(id)GetCurTime;
-(void)send:(id)send callback:(id)callback;
-(BOOL)nsRequest:(id)request responseData:(id*)data;
-(void)sendEvent:(id)event callback:(id)callback;
-(void)close;
-(id)init;
@end
*/

@interface MTAConfig : NSObject {
	BOOL _debugEnable;
	BOOL _smartReporting;
	BOOL _autoExceptionCaught;
	BOOL _accountType;
	BOOL _statEnable;
	unsigned _sessionTimeoutSecs;
	int _reportStrategy;
	NSString* _appkey;
	NSString* _channel;
	unsigned _maxStoreEventCount;
	unsigned _maxLoadEventCount;
	unsigned _minBatchReportCount;
	unsigned _maxSendRetryCount;
	unsigned _sendPeriodMinutes;
	unsigned _maxParallelTimingEvents;
	unsigned _maxReportEventLength;
	NSString* _qq;
	NSString* _account;
	NSString* _accountExt;
	NSString* _customerUserID;
	NSString* _customerAppVersion;
	NSString* _ifa;
	NSString* _pushDeviceToken;
	NSString* _statReportURL;
	int _maxSessionStatReportCount;
	NSString* _op;
	NSString* _cn;
	NSString* _sp;
}
@property(retain, nonatomic) NSString* sp;
@property(retain, nonatomic) NSString* cn;
@property(retain, nonatomic) NSString* op;
@property(assign) int maxSessionStatReportCount;
@property(retain, nonatomic) NSString* statReportURL;
@property(retain, nonatomic) NSString* pushDeviceToken;
@property(retain, nonatomic) NSString* ifa;
@property(retain, nonatomic) NSString* customerAppVersion;
@property(retain, nonatomic) NSString* customerUserID;
@property(assign) BOOL statEnable;
@property(retain, nonatomic) NSString* accountExt;
@property(assign) BOOL accountType;
@property(retain, nonatomic) NSString* account;
@property(retain, nonatomic) NSString* qq;
@property(assign) unsigned maxReportEventLength;
@property(assign) BOOL autoExceptionCaught;
@property(assign) BOOL smartReporting;
@property(assign) unsigned maxParallelTimingEvents;
@property(assign) unsigned sendPeriodMinutes;
@property(assign) unsigned maxSendRetryCount;
@property(assign) unsigned minBatchReportCount;
@property(assign) unsigned maxLoadEventCount;
@property(assign) unsigned maxStoreEventCount;
@property(retain, nonatomic) NSString* channel;
@property(retain, nonatomic) NSString* appkey;
@property(assign) int reportStrategy;
@property(assign) unsigned sessionTimeoutSecs;
@property(assign) BOOL debugEnable;
+(id)getInstance;
-(id)getCustomProperty:(id)property default:(id)aDefault;
-(id)init;
@end

#pragma mark - NetIOHooks
/*
%group NetIOHooks

%hook NSURLConnection

- (id)initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate {
	NSURLConnectionDelegateProxy *delegateProxy = [[NSURLConnectionDelegateProxy alloc] initWithOriginalDelegate:delegate];
	id origResult = %orig(request, delegateProxy);
	return origResult;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately {
	NSURLConnectionDelegateProxy *delegateProxy = [[NSURLConnectionDelegateProxy alloc] initWithOriginalDelegate:delegate];
	id origResult = %orig(request, delegateProxy, startImmediately);
	return origResult;
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
	DUMP_STACK("NSURLConnection sendSynchronousRequest:");

	FLogWarn("NSURLConnection sendSynchronousRequest: %s", TO_CSTR([request URL]));
#if LOG_LEVEL >= LOG_LEVEL_FLOW
	FLogFlow("headers:\n%s", TO_CSTR([request allHTTPHeaderFields]));
	NSString *bodyText = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
	if (bodyText) {
		FLogFlow("body:\n%s", TO_CSTR(bodyText));
	}
#endif

	NSData *responseData = %orig(request, response, error);
#if LOG_LEVEL >= LOG_LEVEL_FLOW
	NSString *payload = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	if (payload) {
		FLogFlow("%s response:\n%s", TO_CSTR([request URL]), TO_CSTR(payload));
	}
#endif
	return responseData;
}

%end

%end	// end of group NetHooks
*/
#pragma mark - Whisper Hooks

%group WhisperHooks

%hook WFeed

+ (id)feedWithDictionary:(id)dictionary endpoint:(id)endpoint fetchKey:(id)key reqType:(id)type
{
	// call stack: +feedWithDictionary: -> -initWithDictionary:
	id ret = %orig(dictionary, endpoint, key, type);

	WFeed *feed = (WFeed *)ret;
	//WFeedSource *source = feed.feedSource;
	if (feed.longitude && feed.latitude)
		FLogFlow("+feedWithDictionary: %s", TO_CSTR(dictionary));
	NSLog(@"[WFeed] name:%@(%@) wid:%@ uuid:%@, loc(%f, %f)", feed.name, feed.reqType, feed.wid, feed.uuid, feed.longitude, feed.latitude);

	return ret;
}
/*
-(id)initWithDictionary:(id)dictionary endpoint:(id)endpoint fetchKey:(id)key reqType:(id)type
{
	id ret = %orig(dictionary, endpoint, key, type);
	NSLog(@"-feedWithDictionary");
	//WFeed_toString(@"-feedWithDictionary", ret);
	return ret;
}

+(id)feedWithSearchQuery:(id)searchQuery
{
	id ret = %orig(searchQuery);
	NSLog(@"+feedWithSearchQuery");
	//WFeed_toString(@"", ret);
	return ret;
}
-(id)initWithSearchQuery:(id)searchQuery
{
	id ret = %orig(searchQuery);
	NSLog(@"-initWithSearchQuery");
	//WFeed_toString(@"", ret);
	return ret;
}

+(id)feedWithRelatedWid:(id)relatedWid
{
	id ret = %orig(relatedWid);
	NSLog(@"+feedWithRelatedWid");
	//WFeed_toString(@"", ret);
	return ret;
}
-(id)initWithRelatedWid:(id)relatedWid
{
	id ret = %orig(relatedWid);
	NSLog(@"-initWithRelatedWid");
	//WFeed_toString(@"", ret);
	return ret;
}
+(id)feedWithParentWid:(id)parentWid
{
	id ret = %orig(parentWid);
	NSLog(@"+feedWithParentWid");
	//WFeed_toString(@"", ret);
	return ret;
}
-(id)initWithParentWid:(id)parentWid
{
	id ret = %orig(parentWid);
	NSLog(@"-initWithParentWid");
	//WFeed_toString(@"", ret);
	return ret;
}

+(id)feedWithNearbyFeedSource:(id)nearbyFeedSource
{
	id ret = %orig(nearbyFeedSource);
	NSLog(@"+feedWithNearbyFeedSource");
	//WFeed_toString(@"", ret);
	return ret;
}

+(id)feedWithFeedSource:(id)feedSource
{
	id ret = %orig(feedSource);
	NSLog(@"+feedWithFeedSource");
	//WFeed_toString(@"", ret);
	return ret;
}
-(id)initWithFeedSource:(id)feedSource nearby:(BOOL)nearby
{
	id ret = %orig(feedSource, nearby);
	NSLog(@"-initWithFeedSource");
	//WFeed_toString(@"", ret);
	return ret;
}

+(id)feedWithDefaultFeedType:(unsigned)defaultFeedType
{
	id ret = %orig(defaultFeedType);
	NSLog(@"+feedWithDefaultFeedType");
	//WFeed_toString(@"", ret);
	return ret;
}
-(id)initWithDefaultFeedType:(unsigned)defaultFeedType
{
	id ret = %orig(defaultFeedType);
	NSLog(@"-initWithDefaultFeedType");
	//WFeed_toString(@"", ret);
	return ret;
}

-(id)initWithUuid:(id)uuid name:(id)name displayName:(id)name3 endpoint:(id)endpoint fetchKey:(id)key
{
	id ret = %orig(uuid, name, name3, endpoint, key);
	NSLog(@"-initWithUuid");
	//WFeed_toString(@"-initWithUuid", ret);
	return ret;
}

-(id)initWithCoder:(id)coder
{
	id ret = %orig(coder);
	NSLog(@"-initWithCoder");
	//WFeed_toString(@"-initWithCoder", ret);
	return ret;
}
*/
%end

%hook WWhisper
/*
+(id)whisperWithWhisper:(id)whisper feed:(id)feed
{
	id ret = %orig(whisper, feed);
	NSLog(@"+whisperWithWhisper");
	return ret;
}

-(id)initWithWhisper:(id)whisper feed:(id)feed
{
	id ret = %orig(whisper, feed);
	NSLog(@"-initWithWhisper");
	return ret;
}

+(id)whisperWithProxy:(id)proxy feed:(id)feed context:(id)context
{
	id ret = %orig(proxy, feed, context);
	NSLog(@"+whisperWithProxy");
	return ret;
}
-(id)initWithProxy:(id)proxy feed:(id)feed context:(id)context
{
	id ret = %orig(proxy, feed, context);
	NSLog(@"-initWithProxy");
	return ret;
}
*/
+(id)whisperWithDictionary:(id)dictionary feed:(id)feed context:(id)context
{
	// call stack: +whisperWithDictionary: -> -initWithDictionary: -> initWithFeed:
	id ret = %orig(dictionary, feed, context);

	WWhisper *whisper = (WWhisper *)ret;
	//FLogFlow("+whisperWithDictionary: %s", TO_CSTR(dictionary));
	NSLog(@"[WWhisper] wid:%@, puid:%@ (loc:%@, dist:%@)\n'%@': '%@'\n%@", whisper.wid, whisper.puid, whisper.location, whisper.distance, whisper.nickname, whisper.text, whisper.imageUrl);
	return ret;
}
/*
-(id)initWithDictionary:(id)dictionary feed:(id)feed context:(id)context
{
	id ret = %orig(dictionary, feed, context);
	NSLog(@"-initWithDictionary");
	return ret;
}

-(id)initWithFeed:(id)feed context:(id)context
{
	id ret = %orig(feed, context);
	NSLog(@"-initWithFeed");
	return ret;
}
*/

%end

%hook WSecurity

+(id)dataFromImageWithWhisperExif:(id)whisperExif
{
	id ret = %orig(whisperExif);
	NSLog(@"[WSecurity] dataFromImageWithWhisperExif(%@) = %@", whisperExif, ret);
	return ret;
}
+(id)base64EncodedString:(id)string
{
	id ret = %orig(string);
	NSLog(@"[WSecurity] base64EncodedString(%@) = %@", string, ret);
	return ret;
}
+(id)sha1Nonce:(id)nonce secret:(id)secret
{
	id ret = %orig(nonce, secret);
	NSLog(@"[WSecurity] sha1Nonce(%@, %@) = %@", nonce, secret, ret);
	return ret;
}
+(id)sharedSecretWithPin:(id)pin uid:(id)uid
{
	id ret = %orig(pin, uid);
	NSLog(@"[WSecurity] sharedSecretWithPin(%@, %@) = %@", pin, uid, ret);
	return ret;
}
+(id)md5String:(id)string
{
	id ret = %orig(string);
	NSLog(@"[WSecurity] md5String(%@) = %@", string, ret);
	return ret;
}
+(id)messagingSocketAuthenticationData
{
	id ret = %orig;
	NSLog(@"[WSecurity] messagingSocketAuthenticationData = %@", ret);
	return ret;
}
+(id)whisperSocketAuthenticationData
{
	id ret = %orig;
	NSLog(@"[WSecurity] whisperSocketAuthenticationData = %@", ret);
	return ret;
}
+(id)authenticatedHeadersForPin:(id)pin uid:(id)uid
{
	id ret = %orig(pin, uid);
	NSLog(@"[WSecurity] authenticatedHeadersForPin(%@, %@) = %@", pin, uid, ret);
	return ret;
}
+(id)authenticatedHeadersForPin:(id)pin
{
	id ret = %orig(pin);
	NSLog(@"[WSecurity] authenticatedHeadersForPin(%@) = %@", pin, ret);
	return ret;
}
+(id)authenticatedHeaders
{
	id ret = %orig;
	NSLog(@"[WSecurity] authenticatedHeaders = %@", ret);
	return ret;
}
+(id)unauthenticatedHeadersWithoutUid
{
	id ret = %orig;
	NSLog(@"[WSecurity] unauthenticatedHeadersWithoutUid = %@", ret);
	return ret;
}
+(id)unauthenticatedHeaders
{
	id ret = %orig;
	NSLog(@"[WSecurity] unauthenticatedHeaders = %@", ret);
	return ret;
}

%end

// MTA start

%hook MTAConfig
- (id)debugEnable {	return (id)YES; }
%end

%end	// end of group WhisperHooks

#pragma mark - C/C++ Hooks

// NSLog to FLogInfo
MSHook(void, NSLogv, NSString *format, va_list args) {
	//DUMP_STACK("NSLog()");

	_NSLogv(format, args);

	NSString *logResult = [[NSString alloc] initWithFormat:format arguments:args];
	FLogInfo("%s", TO_CSTR(logResult));
}

/*
static int (*original_connect)(int sockfd, struct sockaddr * serv_addr, int addrlen);
static int replaced_connect(int sockfd, struct sockaddr * serv_addr, int addrlen) {
	DUMP_STACK("connect()");
	return original_connect(sockfd, serv_addr, addrlen);
}

static int (*original_send)(int sockfd, const void *buf, size_t len, int flags);
static int replaced_send(int sockfd, const void *buf, size_t len, int flags) {
	DUMP_STACK("send()");
	return original_send(sockfd, buf, len, flags);
}

//MSHookFunction((void *)connect, (void *)replaced_connect, (void **) &original_connect);
//MSHookFunction((void *)send, (void *)replaced_send, (void **) &original_send);
*/

#pragma mark - WebSocket

%group InitWebSocket

%hook UIApplication
- (id)init {
	self = %orig;
	if (self) {
		// init server when launched
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			NSLog(@"WebSocket - Server init");
			[[WebSocketServer sharedInstance] initialize];
		}];
		
		// start/stop server for background
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			NSLog(@"WebSocket - Server start");
			[[WebSocketServer sharedInstance] startServer];
		}];
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			NSLog(@"WebSocket - Server stop");
			[[WebSocketServer sharedInstance] stopServer];
		}];
	}

	return self;
}
%end

%end	// end of group InitHTTPServer

#pragma mark - %ctor

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"IOTracker for Whisper Init");

	// Init FileLog
	NSString *filename;
	if ([[NSBundle mainBundle] bundleIdentifier]) {
		filename = [NSString stringWithFormat:@"%@_iotrace.log", [[NSBundle mainBundle] bundleIdentifier]];
	} else {
		filename = @"nobundle_iotrace.log";
	}
	[[FLogObjectiveC sharedInstance] initWithFileName:filename path:@"/var/logs/filelog" maxLine:50000];

	// export NSLog to FLogInfo
	MSHookFunction(NSLogv, MSHake(NSLogv));

	// Hooks
	//%init(NetIOHooks);
	%init(WhisperHooks);

	// WebSocket
	%init(InitWebSocket);

	[pool drain];
}
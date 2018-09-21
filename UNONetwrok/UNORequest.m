//
//  UNORequest.m
//
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UNONetworkConfig.h"
#import "UNORequest.h"
#import "UNONetworkPrivate.h"

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif

NSString *const UNORequestCacheErrorDomain = @"com.unovo.request.caching";

static dispatch_queue_t UNORequest_cache_writing_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.unovo.UNORequest.caching", attr);
    });

    return queue;
}

@interface UNOCacheMetadata : NSObject<NSSecureCoding>

@property (nonatomic, assign) long long version;
@property (nonatomic, strong) NSString *sensitiveDataString;
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *appVersionString;

@end

@implementation UNOCacheMetadata
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.version) forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:self.sensitiveDataString forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    [aCoder encodeObject:@(self.stringEncoding) forKey:NSStringFromSelector(@selector(stringEncoding))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }

    self.version = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(version))] integerValue];
    self.sensitiveDataString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    self.stringEncoding = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(stringEncoding))] integerValue];
    self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
    self.appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];

    return self;
}

@end

#ifdef TARGET_OS_SIMULATOR

@interface UNOTestRequest:UNOBaseRequest

@property (nonatomic, strong) NSString *actionName;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) id argument;
@end

@implementation UNOTestRequest

- (UNORequestMethod)requestMethod{
    return UNORequestMethodPOST;
}

- (id)requestArgument{
    NSMutableDictionary *returnArgument = [NSMutableDictionary dictionary];
    if(self.argument){
        [returnArgument setObject:self.argument forKey:@"responseData"];
    }
    if (self.params){
        [returnArgument setObject:self.params forKey:@"requestParams"];
    }
    return returnArgument.copy;
}

- (NSString *)requestUrl{
    NSMutableString *requestUrl = [[@"http://127.0.0.1:8111/" stringByAppendingString:self.actionName] mutableCopy];
    return requestUrl.copy;
}

- (nullable NSURLRequest *)buildCustomUrlRequest{
    NSURL *url = [NSURL URLWithString:[self requestUrl]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    
    NSData *HTTPBody = [NSJSONSerialization dataWithJSONObject:self.requestArgument
                                    options:NSJSONWritingPrettyPrinted
                                      error:nil];
    urlRequest.HTTPBody = HTTPBody;
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return urlRequest.copy;
}

- (void)start{
    if(self.requestAccessories.count>0){
        [self.requestAccessories removeAllObjects];
    }
    [super start];
}

@end

@interface UNOTestAccessory : NSObject<UNORequestAccessory>
@end
@implementation UNOTestAccessory
- (void)requestDidStop:(UNORequest *)request{
    NSDictionary *jsonObject;
    if(request.error){
        jsonObject = @{@"errorMessage":request.error.localizedDescription};
    }else if (request.responseJSONObject!=nil){
        jsonObject= request.responseJSONObject;
    }else{
        jsonObject = @{@"errorMessage":@"There is no message"};
    }

    UNOTestRequest *testRequest = [[UNOTestRequest alloc] init];
    testRequest.actionName = request.actionUrl;
    testRequest.argument = jsonObject;
    testRequest.params = [request.requestParams copy];
    [testRequest start];
}
@end
#endif

@interface UNORequest()
@end

@interface UNORequest()

@property (nonatomic, strong) NSData *cacheData;
@property (nonatomic, strong) NSString *cacheString;
@property (nonatomic, strong) id cacheJSON;
@property (nonatomic, strong) NSXMLParser *cacheXML;

@property (nonatomic, strong) UNOCacheMetadata *cacheMetadata;
@property (nonatomic, assign) BOOL dataFromCache;

#ifdef TARGET_OS_SIMULATOR
@property (nonatomic, strong) UNOTestAccessory *testAccessory;
#endif
@end

@implementation UNORequest
#pragma mark-
#pragma mark-
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ignoreCache = YES;
#ifdef TARGET_OS_SIMULATOR
        //just for test;
        _testAccessory = [UNOTestAccessory new];
        [self addAccessory:self.testAccessory];
#endif
        
    }
    return self;
}

- (void)start {
    
    if (self.ignoreCache) {
        [self startWithoutCache];
        return;
    }

    // Do not cache download request.
    if (self.resumableDownloadPath) {
        [self startWithoutCache];
        return;
    }

    if (![self loadCacheWithError:nil]) {
        [self startWithoutCache];
        return;
    }

    _dataFromCache = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestCompletePreprocessor];
        [self requestCompleteFilter];
        UNORequest *strongSelf = self;
        [strongSelf.delegate requestFinished:strongSelf];
        if (strongSelf.successCompletionBlock) {
            strongSelf.successCompletionBlock(strongSelf);
        }
        [strongSelf clearCompletionBlock];
    });
}

- (void)startWithoutCache {
    [self clearCacheVariables];
    [super start];
}

#pragma mark - Network Request Delegate

- (void)requestCompletePreprocessor {
    [super requestCompletePreprocessor];

    if (self.writeCacheAsynchronously) {
        dispatch_async(UNORequest_cache_writing_queue(), ^{
            [self saveResponseDataToCacheFile:[super responseData]];
        });
    } else {
        [self saveResponseDataToCacheFile:[super responseData]];
    }
}

#pragma mark - Subclass Override

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (long long)cacheVersion {
    return 0;
}

- (id)cacheSensitiveData {
    return nil;
}

- (BOOL)writeCacheAsynchronously {
    return YES;
}

#pragma mark -

- (BOOL)isDataFromCache {
    return _dataFromCache;
}

- (NSData *)responseData {
    if (_cacheData) {
        return _cacheData;
    }
    return [super responseData];
}

- (NSString *)responseString {
    if (_cacheString) {
        return _cacheString;
    }
    return [super responseString];
}

- (id)responseJSONObject {
    if (_cacheJSON) {
        return _cacheJSON;
    }
    return [super responseJSONObject];
}

- (id)responseObject {
    if (_cacheJSON) {
        return _cacheJSON;
    }
    if (_cacheXML) {
        return _cacheXML;
    }
    if (_cacheData) {
        return _cacheData;
    }
    return [super responseObject];
}

#pragma mark -

- (BOOL)loadCacheWithError:(NSError * _Nullable __autoreleasing *)error {
    // Make sure cache time in valid.
    if ([self cacheTimeInSeconds] < 0) {
        if (error) {
            *error = [NSError errorWithDomain:UNORequestCacheErrorDomain code:UNORequestCacheErrorInvalidCacheTime userInfo:@{ NSLocalizedDescriptionKey:@"Invalid cache time"}];
        }
        return NO;
    }

    // Try load metadata.
    if (![self loadCacheMetadata]) {
        if (error) {
            *error = [NSError errorWithDomain:UNORequestCacheErrorDomain code:UNORequestCacheErrorInvalidMetadata userInfo:@{ NSLocalizedDescriptionKey:@"Invalid metadata. Cache may not exist"}];
        }
        return NO;
    }

    // Check if cache is still valid.
    if (![self validateCacheWithError:error]) {
        return NO;
    }

    // Try load cache.
    if (![self loadCacheData]) {
        if (error) {
            *error = [NSError errorWithDomain:UNORequestCacheErrorDomain code:UNORequestCacheErrorInvalidCacheData userInfo:@{ NSLocalizedDescriptionKey:@"Invalid cache data"}];
        }
        return NO;
    }

    return YES;
}

- (BOOL)validateCacheWithError:(NSError * _Nullable __autoreleasing *)error {
    // Date
    NSDate *creationDate = self.cacheMetadata.creationDate;
    NSTimeInterval duration = -[creationDate timeIntervalSinceNow];
    if (duration < 0 || duration > [self cacheTimeInSeconds]) {
        if (error) {
            *error = [NSError errorWithDomain:UNORequestCacheErrorDomain code:UNORequestCacheErrorExpired userInfo:@{ NSLocalizedDescriptionKey:@"Cache expired"}];
        }
        return NO;
    }
    // Version
    long long cacheVersionFileContent = self.cacheMetadata.version;
    if (cacheVersionFileContent != [self cacheVersion]) {
        if (error) {
            *error = [NSError errorWithDomain:UNORequestCacheErrorDomain code:UNORequestCacheErrorVersionMismatch userInfo:@{ NSLocalizedDescriptionKey:@"Cache version mismatch"}];
        }
        return NO;
    }
    // Sensitive data
    NSString *sensitiveDataString = self.cacheMetadata.sensitiveDataString;
    NSString *currentSensitiveDataString = ((NSObject *)[self cacheSensitiveData]).description;
    if (sensitiveDataString || currentSensitiveDataString) {
        // If one of the strings is nil, short-circuit evaluation will trigger
        if (sensitiveDataString.length != currentSensitiveDataString.length || ![sensitiveDataString isEqualToString:currentSensitiveDataString]) {
            if (error) {
                *error = [NSError errorWithDomain:UNORequestCacheErrorDomain code:UNORequestCacheErrorSensitiveDataMismatch userInfo:@{ NSLocalizedDescriptionKey:@"Cache sensitive data mismatch"}];
            }
            return NO;
        }
    }
    // App version
    NSString *appVersionString = self.cacheMetadata.appVersionString;
    NSString *currentAppVersionString = [UNONetworkUtils appVersionString];
    if (appVersionString || currentAppVersionString) {
        if (appVersionString.length != currentAppVersionString.length || ![appVersionString isEqualToString:currentAppVersionString]) {
            if (error) {
                *error = [NSError errorWithDomain:UNORequestCacheErrorDomain code:UNORequestCacheErrorAppVersionMismatch userInfo:@{ NSLocalizedDescriptionKey:@"App version mismatch"}];
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)loadCacheMetadata {
    NSString *path = [self cacheMetadataFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        @try {
            _cacheMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            return YES;
        } @catch (NSException *exception) {
            UNOLog(@"Load cache metadata failed, reason = %@", exception.reason);
            return NO;
        }
    }
    return NO;
}

- (BOOL)loadCacheData {
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;

    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        _cacheData = data;
        _cacheString = [[NSString alloc] initWithData:_cacheData encoding:self.cacheMetadata.stringEncoding];
        switch (self.responseSerializerType) {
            case UNOResponseSerializerTypeHTTP:
                // Do nothing.
                return YES;
            case UNOResponseSerializerTypeJSON:
                _cacheJSON = [NSJSONSerialization JSONObjectWithData:_cacheData options:(NSJSONReadingOptions)0 error:&error];
                return error == nil;
            case UNOResponseSerializerTypeXMLParser:
                _cacheXML = [[NSXMLParser alloc] initWithData:_cacheData];
                return YES;
        }
    }
    return NO;
}

- (void)saveResponseDataToCacheFile:(NSData *)data {
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        if (data != nil) {
            @try {
                // New data will always overwrite old data.
                [data writeToFile:[self cacheFilePath] atomically:YES];

                UNOCacheMetadata *metadata = [[UNOCacheMetadata alloc] init];
                metadata.version = [self cacheVersion];
                metadata.sensitiveDataString = ((NSObject *)[self cacheSensitiveData]).description;
                metadata.stringEncoding = [UNONetworkUtils stringEncodingWithRequest:self];
                metadata.creationDate = [NSDate date];
                metadata.appVersionString = [UNONetworkUtils appVersionString];
                [NSKeyedArchiver archiveRootObject:metadata toFile:[self cacheMetadataFilePath]];
            } @catch (NSException *exception) {
                UNOLog(@"Save cache failed, reason = %@", exception.reason);
            }
        }
    }
}

- (void)clearCacheVariables {
    _cacheData = nil;
    _cacheXML = nil;
    _cacheJSON = nil;
    _cacheString = nil;
    _cacheMetadata = nil;
    _dataFromCache = NO;
    self.error = nil;
}
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary{
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    if ([UNONetworkConfig sharedConfig].sso_ticket) {
        [header setObject:[UNONetworkConfig sharedConfig].sso_ticket forKey:@"intebox_sso_tkt"];
    }
    if ([UNONetworkConfig sharedConfig].sso_app) {
        [header setObject:[UNONetworkConfig sharedConfig].sso_app forKey:@"intebox_sso_app"];
    }
    return header.copy;
}

#pragma mark -

- (void)createDirectoryIfNeeded:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        UNOLog(@"create cache directory failed, error = %@", error);
    } else {
        [UNONetworkUtils addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];

    // Filter cache base path
    NSArray<id<UNOCacheDirPathFilterProtocol>> *filters = [[UNONetworkConfig sharedConfig] cacheDirPathFilters];
    if (filters.count > 0) {
        for (id<UNOCacheDirPathFilterProtocol> f in filters) {
            path = [f filterCacheDirPath:path withRequest:self];
        }
    }

    [self createDirectoryIfNeeded:path];
    return path;
}

- (NSString *)cacheFileName {
    NSString *requestUrl = [self requestUrl];
    NSString *baseUrl = [UNONetworkConfig sharedConfig].baseUrl;
    id argument = [self cacheFileNameFilterForRequestArgument:[self requestArgument]];
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@",
                             (long)[self requestMethod], baseUrl, requestUrl, argument];
    NSString *cacheFileName = [UNONetworkUtils md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheFilePath {
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (NSString *)cacheMetadataFilePath {
    NSString *cacheMetadataFileName = [NSString stringWithFormat:@"%@.metadata", [self cacheFileName]];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheMetadataFileName];
    return path;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ URL: %@ } { method: %@ } { arguments: %@ }", NSStringFromClass([self class]), self, self.currentRequest.URL, self.currentRequest.HTTPMethod, self.requestParams];
}

- (NSString *)actionUrl{
    if (_actionUrl.length == 0) {
        NSAssert(0, @"actionUrl can not be nil otherwise you show override method \"requestUrl\" in Class <%@>",NSStringFromClass(self.class));
    }
    return _actionUrl;
}

- (Class)uno_objectClass{
    return nil;
}

- (id)uno_toObject{
    return [self uno_toObject:[self uno_objectClass]];
}

- (id)uno_toObject:(Class)aClass{
    if (!aClass) {
        return nil;
    }
    if (![aClass isSubclassOfClass:[UNModel class]]) {
#ifdef DEBUG
        [NSException raise:@"com.unovo.request.modelize"
                    format:@"class <%@> is not a subClass of UNModel ",NSStringFromClass(aClass)];
#endif
        return nil;
    }else{
        id data = self.responseJSONObject[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            return [[aClass alloc] initWithDictionary:data];
        }else if ([data isKindOfClass:[NSArray class]]){
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[(NSArray *)data count]];
            for (NSDictionary *json in data) {
                @autoreleasepool
                {
                    id itemModel = [[aClass alloc] initWithDictionary:json];
                    [temp addObject:itemModel];
                }
            }
            
            return [temp copy];
        }
        
        return nil;
    }
}

@end

@implementation NSMutableDictionary (uno_setObjectButNil)
- (void)uno_setObject:(id)anObject forkey:(id<NSCopying>)aKey{
        if (aKey == nil || anObject == nil)
        {
#ifdef DEBUG
            NSLog(@"key ----> \'%@\'  or value ---> \'%@\' is nil when set value into dictionary",aKey,anObject);
#endif
            return;
        }
        [self setObject:anObject forKey:aKey];
}
@end

NSString *UNOPageOverFlowErrorDomain = @"PageOverFlow";
NSInteger UNOPageOverFlowErrorCode = -2;

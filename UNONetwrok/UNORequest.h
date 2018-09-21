
#import "UNOBaseRequest.h"
#import "UNModel.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const UNORequestCacheErrorDomain;

NS_ENUM(NSInteger) {
    UNORequestCacheErrorExpired = -1,
    UNORequestCacheErrorVersionMismatch = -2,
    UNORequestCacheErrorSensitiveDataMismatch = -3,
    UNORequestCacheErrorAppVersionMismatch = -4,
    UNORequestCacheErrorInvalidCacheTime = -5,
    UNORequestCacheErrorInvalidMetadata = -6,
    UNORequestCacheErrorInvalidCacheData = -7,
};

@interface NSMutableDictionary (uno_setObjectButNil)
- (void)uno_setObject:(id)anObject forkey:(id<NSCopying>)aKey;
@end
    
@interface UNORequest : UNOBaseRequest
@property (nonatomic) BOOL ignoreCache;

@property (nonatomic, copy) NSString *actionUrl;
@property (nonatomic, strong) NSDictionary *requestParams;

- (BOOL)isDataFromCache;

- (BOOL)loadCacheWithError:(NSError * __autoreleasing *)error;

- (void)startWithoutCache;

- (void)saveResponseDataToCacheFile:(NSData *)data;

#pragma mark - Subclass Override
- (NSInteger)cacheTimeInSeconds;

- (long long)cacheVersion;
- (nullable id)cacheSensitiveData;
- (BOOL)writeCacheAsynchronously;

- (Class)uno_objectClass;

//当data的value是一个字典 直接使用该字典初始化Model 返回值是一个UNOModel *类型的对象
//当data的value是一个数组 且数组的元素是字典 则用数组的每一个元素初始化Modle 并返回一个NSArray<UNOModel *>*类型的集合
//如果实际情况在这两种之外 则需要自行重写
- (id)uno_toObject;

@end

NS_ASSUME_NONNULL_END
    
FOUNDATION_EXPORT NSString *UNOPageOverFlowErrorDomain;
FOUNDATION_EXPORT NSInteger UNOPageOverFlowErrorCode;

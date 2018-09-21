
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const UNORequestValidationErrorDomain;
FOUNDATION_EXPORT NSString *const UNORequestTicketErrorDomain;

#define UNOTicketInvalidErrorCode  -9999

NS_ENUM(NSInteger) {
    UNORequestValidationErrorInvalidStatusCode = -8,
    UNORequestValidationErrorInvalidJSONFormat = -9,
};


typedef NS_ENUM(NSInteger, UNORequestMethod) {
    UNORequestMethodGET = 0,
    UNORequestMethodPOST,
    UNORequestMethodHEAD,
    UNORequestMethodPUT,
    UNORequestMethodDELETE,
    UNORequestMethodPATCH,
};

typedef NS_ENUM(NSInteger, UNORequestSerializerType) {
    UNORequestSerializerTypeHTTP = 0,
    UNORequestSerializerTypeJSON,
};



typedef NS_ENUM(NSInteger, UNOResponseSerializerType) {
    
    UNOResponseSerializerTypeHTTP,
    UNOResponseSerializerTypeJSON,
    UNOResponseSerializerTypeXMLParser,
};


typedef NS_ENUM(NSInteger, UNORequestPriority) {
    UNORequestPriorityLow = -4L,
    UNORequestPriorityDefault = 0,
    UNORequestPriorityHigh = 4,
};

@protocol UNOMultipartFormData;

typedef void (^UNOConstructingBlock)(id<UNOMultipartFormData> formData);
typedef void (^UNOURLSessionTaskProgressBlock)(NSProgress *);

@class UNOBaseRequest;

typedef void(^UNORequestCompletionBlock)(__kindof UNOBaseRequest *request);

@protocol UNORequestDelegate <NSObject>

@optional

- (void)requestFinished:(__kindof UNOBaseRequest *)request;
- (void)requestFailed:(__kindof UNOBaseRequest *)request;

@end

@protocol UNORequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

@interface UNOBaseRequest : NSObject

#pragma mark - Request and Response Information

@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readonly) NSURLRequest *currentRequest;
@property (nonatomic, strong, readonly) NSURLRequest *originalRequest;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) NSInteger responseStatusCode;
@property (nonatomic, strong, readonly, nullable) NSDictionary *responseHeaders;
@property (nonatomic, strong, readonly, nullable) NSData *responseData;
@property (nonatomic, strong, readonly, nullable) NSString *responseString;
@property (nonatomic, strong, readonly, nullable) id responseObject;
@property (nonatomic, strong, readonly, nullable) id responseJSONObject;
@property (nonatomic, strong, readonly, nullable) NSError *error;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;


#pragma mark - Request Configuration

@property (nonatomic) NSInteger tag;
@property (nonatomic, strong, nullable) NSDictionary *userInfo;
@property (nonatomic, weak, nullable) id<UNORequestDelegate> delegate;
@property (nonatomic, copy, nullable) UNORequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy, nullable) UNORequestCompletionBlock failureCompletionBlock;
@property (nonatomic, strong, nullable) NSMutableArray<id<UNORequestAccessory>> *requestAccessories;
@property (nonatomic, copy, nullable) UNOConstructingBlock constructingBodyBlock;
@property (nonatomic, strong, nullable) NSString *resumableDownloadPath;
@property (nonatomic, copy, nullable) UNOURLSessionTaskProgressBlock resumableDownloadProgressBlock;
@property (nonatomic) UNORequestPriority requestPriority;

- (void)setCompletionBlockWithSuccess:(nullable UNORequestCompletionBlock)success
                              failure:(nullable UNORequestCompletionBlock)failure;
- (void)clearCompletionBlock;
- (void)addAccessory:(id<UNORequestAccessory>)accessory;


#pragma mark - Request Action
- (void)start;
- (void)stop;
- (void)startWithCompletionBlockWithSuccess:(nullable UNORequestCompletionBlock)success
                                    failure:(nullable UNORequestCompletionBlock)failure;

#pragma mark - Subclass Override
- (void)requestCompletePreprocessor;
- (void)requestCompleteFilter;
- (void)requestFailedPreprocessor;
- (void)requestFailedFilter;
- (NSString *)baseUrl;
- (NSString *)requestUrl;
- (NSString *)cdnUrl;
- (NSTimeInterval)requestTimeoutInterval;
- (nullable id)requestArgument;
- (id)cacheFileNameFilterForRequestArgument:(id)argument;
- (UNORequestMethod)requestMethod;
- (UNORequestSerializerType)requestSerializerType;
- (UNOResponseSerializerType)responseSerializerType;
- (nullable NSArray<NSString *> *)requestAuthorizationHeaderFieldArray;
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;
- (nullable NSURLRequest *)buildCustomUrlRequest;
- (BOOL)useCDN;
- (BOOL)allowsCellularAccess;
- (nullable id)jsonValidator;
- (BOOL)statusCodeValidator;

@end

NS_ASSUME_NONNULL_END

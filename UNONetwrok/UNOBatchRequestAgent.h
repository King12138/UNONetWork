
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UNOBatchRequest;

@interface UNOBatchRequestAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (UNOBatchRequestAgent *)sharedAgent;
- (void)addBatchRequest:(UNOBatchRequest *)request;
- (void)removeBatchRequest:(UNOBatchRequest *)request;

@end

NS_ASSUME_NONNULL_END

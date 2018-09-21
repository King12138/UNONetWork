
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UNOBaseRequest;



@interface UNONetworkAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (UNONetworkAgent *)sharedAgent;
- (void)addRequest:(UNOBaseRequest *)request;
- (void)cancelRequest:(UNOBaseRequest *)request;
- (void)cancelAllRequests;
- (NSString *)buildRequestUrl:(UNOBaseRequest *)request;

@end

NS_ASSUME_NONNULL_END

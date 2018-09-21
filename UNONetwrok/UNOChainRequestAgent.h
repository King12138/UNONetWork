
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UNOChainRequest;

@interface UNOChainRequestAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (UNOChainRequestAgent *)sharedAgent;
- (void)addChainRequest:(UNOChainRequest *)request;
- (void)removeChainRequest:(UNOChainRequest *)request;

@end

NS_ASSUME_NONNULL_END

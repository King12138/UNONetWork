
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UNOChainRequest;
@class UNOBaseRequest;
@protocol UNORequestAccessory;

@protocol UNOChainRequestDelegate <NSObject>

@optional

- (void)chainRequestFinished:(UNOChainRequest *)chainRequest;
- (void)chainRequestFailed:(UNOChainRequest *)chainRequest failedBaseRequest:(UNOBaseRequest*)request;

@end

typedef void (^UNOChainCallback)(UNOChainRequest *chainRequest, UNOBaseRequest *baseRequest);

@interface UNOChainRequest : NSObject

- (NSArray<UNOBaseRequest *> *)requestArray;

@property (nonatomic, weak, nullable) id<UNOChainRequestDelegate> delegate;
@property (nonatomic, strong, nullable) NSMutableArray<id<UNORequestAccessory>> *requestAccessories;

- (void)addAccessory:(id<UNORequestAccessory>)accessory;
- (void)start;
- (void)stop;
- (void)addRequest:(UNOBaseRequest *)request callback:(nullable UNOChainCallback)callback;

@end

NS_ASSUME_NONNULL_END

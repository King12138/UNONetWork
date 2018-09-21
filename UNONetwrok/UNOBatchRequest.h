//
//  UNOBatchRequest.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UNORequest;
@class UNOBatchRequest;
@protocol UNORequestAccessory;

@protocol UNOBatchRequestDelegate <NSObject>

@optional

- (void)batchRequestFinished:(UNOBatchRequest *)batchRequest;
- (void)batchRequestFailed:(UNOBatchRequest *)batchRequest;

@end

@interface UNOBatchRequest : NSObject

@property (nonatomic, strong, readonly) NSArray<UNORequest *> *requestArray;
@property (nonatomic, weak, nullable) id<UNOBatchRequestDelegate> delegate;
@property (nonatomic, copy, nullable) void (^successCompletionBlock)(UNOBatchRequest *);
@property (nonatomic, copy, nullable) void (^failureCompletionBlock)(UNOBatchRequest *);
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong, nullable) NSMutableArray<id<UNORequestAccessory>> *requestAccessories;
@property (nonatomic, strong, readonly, nullable) UNORequest *failedRequest;

- (instancetype)initWithRequestArray:(NSArray<UNORequest *> *)requestArray;
- (void)setCompletionBlockWithSuccess:(nullable void (^)(UNOBatchRequest *batchRequest))success
                              failure:(nullable void (^)(UNOBatchRequest *batchRequest))failure;
- (void)clearCompletionBlock;

- (void)addAccessory:(id<UNORequestAccessory>)accessory;

- (void)start;
- (void)stop;
- (void)startWithCompletionBlockWithSuccess:(nullable void (^)(UNOBatchRequest *batchRequest))success
                                    failure:(nullable void (^)(UNOBatchRequest *batchRequest))failure;

- (BOOL)isDataFromCache;

@end

NS_ASSUME_NONNULL_END

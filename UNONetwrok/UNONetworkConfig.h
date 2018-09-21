//
//  UNONetworkConfig.h
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

@class UNOBaseRequest;
@class UNOSecurityPolicy;

@protocol UNOUrlFilterProtocol <NSObject>

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(UNOBaseRequest *)request;
@end

@protocol UNOCacheDirPathFilterProtocol <NSObject>

- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(UNOBaseRequest *)request;
@end

@interface UNONetworkConfig : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (UNONetworkConfig *)sharedConfig;

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong, readonly) NSString *baseUrl;

@property (nonatomic, strong) NSString *cdnUrl;

@property (nonatomic, strong, readonly) NSArray<id<UNOUrlFilterProtocol>> *urlFilters;

@property (nonatomic, strong, readonly) NSArray<id<UNOCacheDirPathFilterProtocol>> *cacheDirPathFilters;

@property (nonatomic, strong) UNOSecurityPolicy *securityPolicy;

@property (nonatomic) BOOL debugLogEnabled;

@property (nonatomic, strong) NSURLSessionConfiguration* sessionConfiguration;

@property (nonatomic, strong) NSString *sso_ticket;
@property (nonatomic, strong) NSString *sso_app;

@property (nonatomic, strong) NSString *apiVersion;

@property (nonatomic, strong) NSURLRequest *refreshTicketRequest;

- (void)addUrlFilter:(id<UNOUrlFilterProtocol>)filter;

- (void)clearUrlFilter;

- (void)addCacheDirPathFilter:(id<UNOCacheDirPathFilterProtocol>)filter;

- (void)clearCacheDirPathFilter;

@end

NS_ASSUME_NONNULL_END

FOUNDATION_EXTERN NSString *UNONetWorkTicketRefreshFalure;


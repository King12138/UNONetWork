//
//  UNONetworkConfig.m
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
#import "UNOBaseRequest.h"

#if __has_include(<UNONetworking/UNONetworking.h>)
#import <UNONetworking/UNONetworking.h>
#else
#import "UNONetworking.h"
#endif


#define UNONetConfigLock(...) dispatch_semaphore_wait(_innerLock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_innerLock);

@implementation UNONetworkConfig {
    NSMutableArray<id<UNOUrlFilterProtocol>> *_urlFilters;
    NSMutableArray<id<UNOCacheDirPathFilterProtocol>> *_cacheDirPathFilters;
    dispatch_semaphore_t _innerLock;
    NSUserDefaults *_ticketUserDefaults;
    
}

+ (UNONetworkConfig *)sharedConfig {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseUrl = @"";
        _cdnUrl = @"";
        _urlFilters = [NSMutableArray array];
        _cacheDirPathFilters = [NSMutableArray array];
        _securityPolicy = [UNOSecurityPolicy defaultPolicy];
        
#ifdef DEBUG
        _debugLogEnabled = YES;
#else
        _debugLogEnabled = NO;
#endif
        
        _domain = @"https://saas.lianyuplus.com/";
        _apiVersion = @"saas20/api/201410011/";
        _sso_app = @"AptOwner";
        
        self->_baseUrl =  [self.domain stringByAppendingFormat:@"%@%@/",self.apiVersion,self.sso_app];
        
        _refreshTicketRequest = nil;
        
        _innerLock = dispatch_semaphore_create(1);
        
        _ticketUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"GroupIdentifier"];
        
        _sso_ticket = [_ticketUserDefaults stringForKey:@"sharedTicket"];
    }
    return self;
}

- (void)addUrlFilter:(id<UNOUrlFilterProtocol>)filter {
    [_urlFilters addObject:filter];
}

- (void)clearUrlFilter {
    [_urlFilters removeAllObjects];
}

- (void)addCacheDirPathFilter:(id<UNOCacheDirPathFilterProtocol>)filter {
    [_cacheDirPathFilters addObject:filter];
}

- (void)clearCacheDirPathFilter {
    [_cacheDirPathFilters removeAllObjects];
}

- (NSArray<id<UNOUrlFilterProtocol>> *)urlFilters {
    return [_urlFilters copy];
}

- (NSArray<id<UNOCacheDirPathFilterProtocol>> *)cacheDirPathFilters {
    return [_cacheDirPathFilters copy];
}

#pragma mark-
#pragma mark- ticket

- (void)setSso_ticket:(NSString *)sso_ticket{
    if (sso_ticket == nil) {
        _sso_ticket = nil;
        [_ticketUserDefaults removeObjectForKey:@"sharedTicket"];
        return;
    }
    
    UNONetConfigLock(_sso_ticket = sso_ticket)
    [_ticketUserDefaults setObject:_sso_ticket forKey:@"sharedTicket"];
    [_ticketUserDefaults synchronize];
}

- (void)setDomain:(NSString *)domain{
    UNONetConfigLock(_domain = domain)
    self->_baseUrl =  [self.domain stringByAppendingFormat:@"%@%@/",self.apiVersion,self.sso_app];
}

- (void)setSso_app:(NSString *)sso_app{
    UNONetConfigLock(_sso_app = sso_app)
    self->_baseUrl =  [self.domain stringByAppendingFormat:@"%@%@/",self.apiVersion,self.sso_app];
}

- (void)setApiVersion:(NSString *)apiVersion{
    UNONetConfigLock(_apiVersion = apiVersion)
    self->_baseUrl =  [self.domain stringByAppendingFormat:@"%@%@/",self.apiVersion,self.sso_app];
}


#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ baseURL: %@ } { cdnURL: %@ }", NSStringFromClass([self class]), self, self.baseUrl, self.cdnUrl];
}

@end

FOUNDATION_EXTERN NSString *UNONetWorkTicketRefreshFalure = @"UNONetWorkTicketRefreshFalure";


//
//  UNOPagedGetRequest.m
//  inteboxSDK
//
//  Created by intebox on 2018/8/27.
//

#import "UNOPagedGetRequest.h"

@implementation UNOPagedGetRequest

//分页接口总是忽略缓存
- (BOOL)ignoreCache{
    return YES;
}

- (void)start{
    if (self.isPage && [self.isPage isEqualToString:@"1"]) {
        if (![self pageValid]) return;
    } else {
        if (!_isPage) _isPage = @"1";
        if (!_page) _page = @"1";
        if (!_pageSize) _pageSize = @"15";
    }
        
    [super start];
}

- (void)requestCompletePreprocessor{
    [super requestCompletePreprocessor];
    
    id totalPage = self.responseJSONObject[@"data"][@"totalPage"];
    if (totalPage == nil) {
        self.totalPage = @"-1"; return;
    }
    
    if ([totalPage isKindOfClass:[NSNumber class]]) {
        self.totalPage = [(NSNumber *)totalPage stringValue];
    } else {
        self.totalPage = totalPage;
    }
}

- (void)requestFailedPreprocessor{
    [super requestFailedPreprocessor];
    if([self resetPageOnRequestError]){
        [self resetPage];
    }
}

#pragma mark-
#pragma mark- private

- (BOOL)pageValid{
    if(![self.totalPage isEqualToString:@"-1"]){
        NSError *pageError;
        [self pagedWithError:&pageError];
        
        if(pageError){
            [self setValue:pageError forKeyPath:@"error"];
            !self.failureCompletionBlock?:self.failureCompletionBlock(self);
        }
        
        return pageError == nil;
    }else{
        if (!_isPage) _isPage = @"1";
        if (!_page) _page = @"1";
        if (!_pageSize) _pageSize = @"15";
        
        return YES;
    }
}

#pragma mark-
#pragma mark- UNOPagedRequestProtocol
- (NSString *)totalPage{
    if(_totalPage == nil){
        _totalPage = @"-1";
    }
    return _totalPage;
}

- (NSString *)isPage{
    if(_isPage == nil){
        _isPage = @"1";
    }
    return _isPage;
}

- (void)resetPage{
    self.page = @"1";
    self.totalPage = @"-1";
    self.pageSize = @"15";
}

- (void)pagedWithError:(NSError **)error{
    NSInteger page = [self.page integerValue]+1;
    if (page > self.totalPage.integerValue){
        if(error == NULL){
            return;
        }
        *error = [NSError errorWithDomain:UNOPageOverFlowErrorDomain
                                     code:UNOPageOverFlowErrorCode
                                 userInfo:@{
                                            NSLocalizedDescriptionKey: @"当前已经是所有的消息"
                                            }];
    }else{
        self.page = @(page).stringValue;
    }    
}

- (BOOL)resetPageOnRequestError{
    return NO;
}

#pragma mark-
#pragma mark- toObejct
-(id)uno_toObject{
    Class aClass = [self uno_toObject];
    if (aClass == nil || ![aClass isSubclassOfClass:[UNModel class]]) {
#ifdef DEBUG
        [NSException raise:@"com.unovo.request.modelize"
                    format:@"class <%@> is not a subClass of UNModel ",NSStringFromClass(aClass)];
#endif
        return nil;
    }
    NSDictionary *json = [self responseJSONObject];
    if (!json ||
        ![json isKindOfClass:[NSDictionary class]] ||
        ![[json allKeys] containsObject:@"data"]){
        return @[];
    }
    
    NSDictionary *data = json[@"data"];
    if (!data ||
        ![[data allKeys] containsObject:@"list"] ||
        ![data[@"list"] isKindOfClass:[NSArray class]]) {
        return @[];
    }
    
    NSArray *jsonArray = data[@"list"];
    NSMutableArray *tempItemArrays = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    for (NSDictionary *tempItemJson in jsonArray){
        id item = [[aClass alloc] initWithDictionary:tempItemJson];
        [tempItemArrays addObject:item];
    }
    
    return [tempItemArrays copy];
}

@end



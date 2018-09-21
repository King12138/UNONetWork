//
//  UNOGetRequest.m
//  Steward_Dev_refactor
//
//  Created by intebox on 2017/11/14.
//  Copyright © 2017年 KevinZhang. All rights reserved.
//

#import "UNOGetRequest.h"
#import "UNONetworkConfig.h"

@implementation UNOGetRequest
- (UNORequestMethod)requestMethod{
    return UNORequestMethodGET;
}

- (NSString *)requestUrl{
    NSString *url = [[UNONetworkConfig sharedConfig].baseUrl stringByAppendingString:[self actionUrl]];
    if (!self.requestParams || self.requestParams.count<=0) {
        return url;
    }

    for (NSString *key in self.keysWithOrder) {
        if (self.requestParams[key]) {
            url = [url stringByAppendingPathComponent:key];
            url = [url stringByAppendingPathComponent:self.requestParams[key]];
        }
    }
    
    return url;
}

@end

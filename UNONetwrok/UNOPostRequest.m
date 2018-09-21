//
//  UNOPostRequest.m
//  Steward_Dev_refactor
//
//  Created by intebox on 2017/11/14.
//  Copyright © 2017年 KevinZhang. All rights reserved.
//

#import "UNOPostRequest.h"
#import "UNONetworkConfig.h"

@implementation UNOPostRequest

- (id)requestArgument{
    return self.requestParams;
}

- (UNORequestMethod)requestMethod{
    return UNORequestMethodPOST;
}


- (NSString *)requestUrl{
    return [[UNONetworkConfig sharedConfig].baseUrl stringByAppendingString:[self actionUrl]];
}

@end

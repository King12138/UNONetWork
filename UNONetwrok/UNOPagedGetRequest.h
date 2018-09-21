//
//  UNOPagedGetRequest.h
//  inteboxSDK
//
//  Created by intebox on 2018/8/27.
//

#import "UNOGetRequest.h"
#import "UNOPagedRequestProtocol.h"
@interface UNOPagedGetRequest : UNOGetRequest
<UNOPagedRequestProtocol>

@property (nonatomic, strong) NSString *pageSize;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *totalPage;
@property (nonatomic, strong) NSString *isPage;

@end

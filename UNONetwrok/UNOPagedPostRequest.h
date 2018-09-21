//
//  UNOPagedPostRequest.h
//  inteboxSDK
//
//  Created by intebox on 2018/8/27.
//

#import "UNOPostRequest.h"
#import "UNOPagedRequestProtocol.h"

@interface UNOPagedPostRequest : UNOPostRequest
<UNOPagedRequestProtocol>

@property (nonatomic, strong) NSString *pageSize;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *totalPage;
@property (nonatomic, strong) NSString *isPage;

@end

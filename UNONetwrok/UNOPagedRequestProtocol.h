//
//  UNOPagedRequestProtocol.h
//  inteboxSDK
//
//  Created by intebox on 2018/8/27.
//

#import <Foundation/Foundation.h>

@protocol UNOPagedRequestProtocol <NSObject>

@required
@property (nonatomic, strong) NSString *pageSize;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *totalPage;

- (void)resetPage;
- (void)pagedWithError:(NSError **)error;

@optional
- (BOOL)resetPageOnRequestError;

@end

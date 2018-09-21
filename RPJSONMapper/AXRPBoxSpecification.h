// Created by reynaldo on 12/30/13.


#import <Foundation/Foundation.h>

typedef id (^PropertyMapperBlock)(id jsonValue);

@interface AXRPBoxSpecification : NSObject
@property (nonatomic, copy) PropertyMapperBlock block;
@property (nonatomic, copy) NSString *propertyName;

+ (AXRPBoxSpecification *)boxValueIntoPropertyWithName:(NSString *)propertyName
                                          usingBlock:(PropertyMapperBlock)block;
@end
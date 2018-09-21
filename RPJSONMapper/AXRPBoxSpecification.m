// Created by reynaldo on 12/30/13.


#import "AXRPBoxSpecification.h"

@implementation AXRPBoxSpecification
+ (AXRPBoxSpecification *)boxValueIntoPropertyWithName:(NSString *)propertyName
                                          usingBlock:(PropertyMapperBlock)block {
    AXRPBoxSpecification *blockWrapper = [AXRPBoxSpecification new];
    blockWrapper.propertyName = propertyName;
    blockWrapper.block = block;
    return blockWrapper;
}

@end
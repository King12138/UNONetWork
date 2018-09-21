// Created by reynaldo on 12/30/13.


#import <Foundation/Foundation.h>

@class AXRPBoxSpecification;

typedef id (^InstantiationBlock)();

@interface AXRPJSONMapper : NSObject

@property (nonatomic) BOOL shouldSuppressWarnings;

+ (instancetype)sharedInstance;

- (void)mapJSONValuesFrom:(id)json
               toInstance:(id)instance
             usingMapping:(NSDictionary *)mapping;

- (NSArray *)objectsFromJSONArray:(id)json
           withInstantiationBlock:(InstantiationBlock)instantiationBlock
                     usingMapping:(NSDictionary *)mapping;

- (id)childJSONInJSON:(id)json
            usingPath:(NSArray *)path;

#pragma mark mark - Boxing

- (AXRPBoxSpecification *)boxValueAsNSStringIntoPropertyWithName:(NSString *)propertyName;

- (AXRPBoxSpecification *)boxValueAsNSNumberIntoPropertyWithName:(NSString *)propertyName;

- (AXRPBoxSpecification *)boxValueAsNSDateIntoPropertyWithName:(NSString *)propertyName usingDateFormat:(NSString *)dateFormat;

- (AXRPBoxSpecification *)boxValueAsNSURLIntoPropertyWithName:(NSString *)propertyName;

@end
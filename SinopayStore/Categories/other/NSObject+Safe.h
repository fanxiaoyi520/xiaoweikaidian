//
//  NSObject+Safe.h
//  XzfPos
//
//  Created by wd on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Safe)

- (NSString *)safeStringValue;
- (NSNumber *)safeNumberValue;
- (NSArray *)safeArrayValue;
- (NSDictionary *)safeDictioaryValue;

@end

@interface NSURL (Safe)

+ (NSURL *)safe_URLWithString:(NSString *)URLString;

@end

@interface NSArray (Safe)

- (id)safe_objectAtIndex:(NSInteger)index;

@end


@interface NSMutableArray (Safe)

- (void)safe_addObject:(id)obj;

- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index;

- (void)safe_addObjectsFromArray:(NSArray *)array;

- (void)safe_removeObjectAtIndex:(NSUInteger)index;

- (void)safe_removeObjectsInArray:(NSArray *)otherArray;

- (void)safe_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end


@interface NSMutableSet (Safe)

- (void)safe_addObject:(id)object;

- (void)safe_addObjectsFromArray:(NSArray *)array;

@end

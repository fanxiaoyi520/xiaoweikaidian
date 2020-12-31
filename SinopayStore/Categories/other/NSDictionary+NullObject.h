//
//  NSDictionary+NullObject.h
//  XzfPos
//
//  Created by wd on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDictionary (NullObject)

//当key对应的value为NULL时，返回nil,否则返回相应对象
-(id)notNullObjectForKey:(NSString *)key;

// 返回判空后的字符串
- (NSString *)stringWithKey:(NSString *)key;

// 返回判空后的整形
- (NSInteger)integerWithKey:(NSString *)key;

// 返回判空后的浮点型
- (CGFloat)floatWithKey:(NSString *)key;

// 返回判空后的BOOL
- (BOOL)boolWithKey:(NSString *)key;

- (CGFloat)doubleWithKey:(NSString *)key;

@end

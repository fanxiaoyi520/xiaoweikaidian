//
//  KDAgentModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDAgentModel : NSObject

@property (nonatomic, strong)NSString *agentName;
@property (nonatomic, strong)NSString *agentAuditStatus;
@property (nonatomic, strong)NSString *agentContact;
@property (nonatomic, strong)NSString *agentAccount;
@property (nonatomic, strong)NSString *createTime;

@end

NS_ASSUME_NONNULL_END

//
//  KDAwardRecordCell.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDAwardRecord.h"

@interface KDAwardRecordCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/** 奖励记录模型 */
@property(nonatomic, strong) KDAwardRecord *record;

@end

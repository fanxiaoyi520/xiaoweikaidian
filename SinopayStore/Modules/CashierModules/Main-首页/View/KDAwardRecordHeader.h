//
//  KDAwardRecordHeader.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeSectionModel.h"

@interface KDAwardRecordHeader : UITableViewHeaderFooterView

+ (instancetype)headerViewWithTableView:(UITableView *)tableView;

/** 头部模型 */
@property(nonatomic, strong) TradeSectionModel *sectionModel;

@end

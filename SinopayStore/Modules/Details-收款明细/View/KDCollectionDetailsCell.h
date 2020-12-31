//
//  KDCollectionDetailsCell.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDCollectionDeatilsModel.h"


@interface KDCollectionDetailsCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/** 详情模型 */
@property (nonatomic, strong) KDCollectionDeatilsModel *cellModel;

@end

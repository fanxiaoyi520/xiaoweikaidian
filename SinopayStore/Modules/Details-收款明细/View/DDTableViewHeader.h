//
//  DDTableViewHeader.h
//  UItableview Cell的点击
//
//  Created by apple on 28/2/17.
//  Copyright © 2017年 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDCollectionDateModel.h"

typedef void(^HeaderViewClickedBack)(BOOL);

@interface DDTableViewHeader : UITableViewHeaderFooterView


@property (nonatomic, copy) HeaderViewClickedBack HeaderClickedBack;


@property (nonatomic, strong) KDCollectionDateModel *sectionModel;




@end

//
//  SpeechUtils.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <iflyMSC/iflyMSC.h>

#define speechID @"5a654cfb"

@interface SpeechUtils : NSObject<IFlySpeechSynthesizerDelegate>

@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;//语音合成对象

+ (instancetype)shareSpeece;

//讯飞语音播报
- (void)speechIt:(NSString *)speechStr;

//系统语音播报
- (void)systemSpeechIt:(NSString *)speechStr;

@end

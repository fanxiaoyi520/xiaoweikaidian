//
//  SpeechUtils.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "SpeechUtils.h"

@implementation SpeechUtils

+ (instancetype)shareSpeece{
    static dispatch_once_t onceToken;
    static SpeechUtils *speech = nil;
    dispatch_once(&onceToken, ^{
        speech = [[SpeechUtils alloc] init];
        [speech setup];
    });
    return speech;
}

- (void)setup{
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",speechID];
    [IFlySpeechUtility createUtility:initString];
    
    //合成服务单例
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    
    _iFlySpeechSynthesizer.delegate = self;
    //设置语速1-100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    //设置音量1-100
    [_iFlySpeechSynthesizer setParameter:@"70" forKey:[IFlySpeechConstant VOLUME]];
    //设置音调1-100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant PITCH]];
}

- (void)speechIt:(NSString *)speechStr{
    if ([speechStr isKindOfClass:[NSNull class]] || !speechStr || ![speechStr isKindOfClass:[NSString class]]) {
        return;
    }
    
    //发音人 catherine说英语 默认
    NSString *voiceName = @"catherine";

    NSString *languageName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    if ([languageName hasPrefix:@"zh-Hant"] || [languageName containsString:@"zh-HK"]) {
        //xiaomei说粤语
        voiceName = @"xiaomei";
    }
    if ([languageName hasPrefix:@"zh-Hans"]) {
        //xiaoyan说国语
        voiceName = @"xiaoyan";
    }
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:voiceName forKey:[IFlySpeechConstant VOICE_NAME]];

    [_iFlySpeechSynthesizer startSpeaking:speechStr];
}

- (void)systemSpeechIt:(NSString *)speechStr{
    if ([speechStr isKindOfClass:[NSNull class]] || !speechStr || ![speechStr isKindOfClass:[NSString class]]) {
        return;
    }
    //默认英文
    NSString *language = @"en";
    NSString *languageName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    if ([languageName hasPrefix:@"zh-Hant"] || [languageName containsString:@"zh-HK"]) {
        //说粤语
        language = @"zh-HK";
    }
    if ([languageName hasPrefix:@"zh-Hans"]) {
        //说国语
        language = @"zh_Hans";
    }

    // 实例化说话的语言，说中文
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:language];
    // 要朗诵，需要一个语音合成器
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];

    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speechStr];
    utterance.voice = voice;
    utterance.rate = 0.4;
    
    if ([speechStr isEqualToString:@"1"]) {//1的时候不发音
        utterance.volume = 0;
    }

    [synthesizer speakUtterance:utterance];
}

- (void)onCompleted:(IFlySpeechError *)error{
    NSLog(@"IFlySpeechError--%@", error.errorDesc);
}


@end

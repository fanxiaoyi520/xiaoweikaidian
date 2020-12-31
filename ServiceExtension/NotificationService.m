//
//  NotificationService.m
//  ServiceExtension
//
//  Created by 中付支付 on 2018/4/8.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>
#import "SpeechUtils.h"

API_AVAILABLE(ios(10.0))
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
//    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    NSDictionary *userInfo = self.bestAttemptContent.userInfo;
    NSString *orderID = [userInfo objectForKey:@"orderID"];
    if (orderID.length > 0 && systemVersion < 12.1) {
        NSDictionary *dict = [userInfo objectForKey:@"aps"];
        [[SpeechUtils shareSpeece] speechIt:[dict objectForKey:@"alert"]];
    }

    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end

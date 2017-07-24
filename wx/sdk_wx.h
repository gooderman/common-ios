//
//  sdk.h
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sdk.h"
@interface sdk (wx)
+ (void) wx_init;
//+ (void) wx_login:(int) type;
//+ (void) wx_share:(int) type Title:(NSString*)title Text:(NSString*)text Img:(NSString*)img Url:(NSString*)url;
//+ (void) wx_login_notify:(NSError*) error Data:(id)data;
//+ (void) wx_share_nofity:(NSError*) error Data:(id)data;

+ (void) wx_pay:(NSString*) pid;
+ (void) wx_pay_notify:(BOOL) result price:(int) p;

+ (BOOL) wx_handle_url:(NSURL*)url;


@end

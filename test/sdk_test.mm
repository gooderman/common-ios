//
//  sdk.m
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//
#import "sdk_test.h"
#import "sdk_um.h"
#import "sdk_wx.h"
#import "sdk_net.h"
@implementation sdktest
+ (void) test_share
{
     NSMutableDictionary* dic = [[NSMutableDictionary alloc ] initWithCapacity:10];
     [dic setValue:@"5a30c804f29d987b98000526" forKey:TOKEN_UM_APPKEY];
     [dic setValue:@"wxf702762dd0bd6112" forKey:TOKEN_WX_APPKEY];
     [dic setValue:@"47b8c909f0f88fbc4d13c0f7f6c1fbe1" forKey:TOKEN_WX_APPSECRET];
     [sdk um_init: dic];
    
     [dic removeAllObjects];
     [dic setValue:[NSNumber numberWithInt:1] forKey:SDK_SHARE_TYPE];
     [dic setValue:@"testtesttest" forKey:SDK_SHARE_TEXT];
     [dic setValue:@"http://bing.cn" forKey:SDK_SHARE_URL];

     [sdk share: dic];
}

+ (void) test
{
    //    [sdk http_get:@"http://www.apple.com" params:nil callback:^(int error,id data){
    //            NSLog(@"tst http_get %d",error);
    //            if(data){
    //                NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    //                NSLog(@"succ1 = %@",string);
    //
    //                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //                NSLog(@"succ2 = %@",dict);
    //
    //            }
    //        }
    //    ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [sdktest test_share];
    });
    
}

@end

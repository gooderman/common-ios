//
//  sdk.m
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//
#import "sdk_wx.h"
#import "WXApiManager.h"

@implementation sdk (wx)

+ (void) wx_init
{
    //向微信注册
    [WXApi registerApp:WX_APPKEY withDescription:WX_REGNAME];
    //向微信注册支持的文件类型
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    
    [WXApi registerAppSupportContentFlag:typeFlag];
    
}
//
//+ (void) wx_login:(int) p
//{
//
//}
//
//+(void) wx_login_notify:(NSError*) error Data:(id) data
//{
// 
//}
//
//+ (void) wx_share:(int) type Title:(NSString*)title Text:(NSString*)text Img:(NSString*)img Url:(NSString*)url
//{
//    
//}
//
//+(void) wx_share_nofity:(BOOL) result
//{
//    
//}

+ (void) wx_pay:(NSString*) pid
{
    PayReq *request = [[[PayReq alloc] init] autorelease];
    request.partnerId = @"10000100";
    request.prepayId= @"1101000000140415649af9fc314aa427";
    request.package = @"Sign=WXPay";
    request.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
    request.timeStamp= @"1397527777".intValue;
    request.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
    [WXApi sendReq:request];
}

+ (void) wx_pay_notify:(BOOL) result price:(int) p
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    [dic setValue:SDK_EVT_WXPAY forKey:SDK_EVT];
    if(result){
        [dic setValue:[NSNumber numberWithInt:0] forKey:SDK_ERROR];
        [dic setValue:[NSNumber numberWithInt:p] forKey:SDK_PRICE];
    }
    else{
        [dic setValue:[NSNumber numberWithInt:1] forKey:SDK_ERROR];
        [dic setValue:[NSNumber numberWithInt:p] forKey:SDK_PRICE];
    }
    [sdk notifyEventByObject: dic];
}

+ (BOOL) wx_handle_url:(NSURL*)url
{
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

@end

//
//  sdk.m
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//
#import "sdk_um.h"
#import <UMSocialNetwork/UMSocialNetwork.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UMSocialUIManager.h>
#import <UShareUI/UShareUI.h>

@implementation sdk (um)

+ (void) um_init : (NSDictionary*)dic
{
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:[dic valueForKey:TOKEN_UM_APPKEY]];
    
    // 获取友盟social版本号
    NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:[dic valueForKey:TOKEN_WX_APPKEY] appSecret:[dic valueForKey:TOKEN_WX_APPSECRET] redirectURL:nil];

    
    // 如果不想显示平台下的某些类型，可用以下接口设置
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[
                                                                                
                                                                                @(UMSocialPlatformType_QQ),
                                                                                @(UMSocialPlatformType_Qzone),             @(UMSocialPlatformType_TencentWb),
                                                                                @(UMSocialPlatformType_Facebook),@(UMSocialPlatformType_WechatFavorite),
                                                                                
                                                                                @(UMSocialPlatformType_Sms),
                                                                                @(UMSocialPlatformType_Email),
                                                                                @(UMSocialPlatformType_Renren),
                                                                                @(UMSocialPlatformType_Douban),
                                                                                @(UMSocialPlatformType_Flickr),                                                                                @(UMSocialPlatformType_Twitter),
                                                                                @(UMSocialPlatformType_YixinTimeLine),@(UMSocialPlatformType_LaiWangTimeLine),
                                                                                @(UMSocialPlatformType_Linkedin),
                                                                                @(UMSocialPlatformType_AlipaySession)]
                                                                                ];
}

+ (void) um_login:(int) p
{
    UMSocialPlatformType platformType = (UMSocialPlatformType)p;
    UIViewController* vc = [sdk uivc];
    [[UMSocialManager defaultManager]  getUserInfoWithPlatform:platformType currentViewController:vc completion:^(id result, NSError *error) {
        [sdk um_login_notify: error Data:result];
    }];

}

+(void) um_login_notify:(NSError*) error Data:(id) data
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    [dic setValue:SDK_EVT_LOGIN forKey:SDK_EVT];
    if(nil==error){
        UMSocialUserInfoResponse *usinfo = data;
        [dic setValue:usinfo.openid forKey:SDK_OPENID];
        [dic setValue:usinfo.name forKey:SDK_NAME];
        [dic setValue:usinfo.iconurl forKey:SDK_ICONURL];
        [dic setValue:usinfo.gender forKey:SDK_GENDER];
        [dic setValue:usinfo.accessToken forKey:SDK_ACCESS_TOKEN];
        
        [dic setValue:[NSNumber numberWithInt:0] forKey:SDK_ERROR];
    }
    else{
        [dic setValue:[NSNumber numberWithInt:1] forKey:SDK_ERROR];
        NSLog(@"um_login_notify error：%@",error);
    }
    [sdk notifyEventByObject: dic];
}

typedef void(^UM_SHARE)(UMSocialPlatformType platformType, NSDictionary *userInfo);
+ (void) um_share:(int) type Title:(NSString*)title Text:(NSString*)text Img:(NSString*)img Url:(NSString*)url
{
    NSLog(@"分享地址为：%@",url);
//    if(!url || [url length] == 0)
//    {
//        url = APPSTORE_URL;
//    }
    
    UM_SHARE toshare = ^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        
        //设置文本
        messageObject.text = text;
        
        if([url length]>0)
        {
            UMShareWebpageObject* shareUrlobj =[[UMShareWebpageObject alloc] init];
            shareUrlobj.webpageUrl = url;
            shareUrlobj.title = title;
            shareUrlobj.descr = text;
            shareUrlobj.thumbImage = [UIImage imageNamed:@"Icon.png"];
            messageObject.shareObject = shareUrlobj;
        }
        else if([img length]>0)
        {   //创建图片内容对象
            UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
            shareObject.shareImage = [UIImage imageWithContentsOfFile:img];
            //如果有缩略图，则设置缩略图
            shareObject.thumbImage = [UIImage imageNamed:@"Icon.png"];
            shareObject.title = title;
            shareObject.descr = text;
            
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
        }
        else
        {
            UMShareObject *shareObject = [[UMShareObject alloc] init];
            shareObject.thumbImage = [UIImage imageNamed:@"Icon.png"];
            shareObject.title = title;
            shareObject.descr = text;
            messageObject.shareObject = shareObject;
        }
        //调用分享接口
        auto vc= [sdk uivc];
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:vc completion:^(id data, NSError *error) {
            [sdk um_share_nofity:error Data:data];
        }];
    };

    if(type<0)
    {
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:toshare];
    }
    else
    {
        UMSocialPlatformType pp = (UMSocialPlatformType)type;
        toshare(pp,nil);
    }
}

+(void) um_share_nofity:(NSError*) error Data:(id)data
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    [dic setValue:SDK_EVT_SHARE forKey:SDK_EVT];
    if(nil==error){
        [dic setValue:[NSNumber numberWithInt:0] forKey:SDK_ERROR];
    }
    else{
        [dic setValue:[NSNumber numberWithInt:1] forKey:SDK_ERROR];
    }
    [sdk notifyEventByObject: dic];
}


+ (BOOL) um_handle_url:(NSURL*)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

+ (BOOL) um_handle_url:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

// 支持所有iOS系统
+ (BOOL) um_handle_url:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation

{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

@end

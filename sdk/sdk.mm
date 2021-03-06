//
//  sdk.m
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//
#import "sdk.h"
#import "sdk_audio.h"
#include "sdk_baiduloc.h"
#include "sdk_iospay.h"
#include "CCLuaBridge.h"
#import "sdk_um.h"
#import "sdk_album.h"
//#import <sdk_wx.h>
#import <UIkit/UIWebView.h>
#import <UIKit/UIButton.h>
#import <WebKit/WKWebView.h>
#ifdef __IPHONE_9_0
#import <SafariServices/SFSafariViewController.h>
#endif
#import <AudioToolbox/AudioToolbox.h>
#import "WbViewController.h"

static int evthandler;

static NSMutableDictionary* gDic = nil;

@interface sdk ()
+ (void) notifyEventByObject: (id) object;
+ (void) notifyEvent: (NSString*) str;
+ (NSString*) toJsonStr:(id) object;
@end

@implementation sdk

+ (UIViewController*) uivc;
{
//    key window 不可靠并不一定是gamewindow，alert关闭以后在0.3-0.4秒内会清除keywindow
//    在alert回调中立即添加view到keywindow，都会被清除
//    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
//    ----------------------------------------------------------------------------
//    return [[[UIApplication sharedApplication].delegate window] rootViewController];
    return [[UIApplication sharedApplication].windows[0] rootViewController];
}
+ (NSString*) toJsonStr:(id) object
{
    NSString* jsonStr =nil;
    NSError * error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if(!jsonData)
    {
        NSLog(@"toJsonStr error: %@", error);
    }
    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}


+ (void) notifyEvent: (NSString*) str
{
    if(!evthandler)
    {
        return;
    }
    cocos2d::CCLuaEngine *engine = dynamic_cast<cocos2d::CCLuaEngine *>(cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine());
    cocos2d::CCLuaStack *stack = engine->getLuaStack();
    cocos2d::CCLuaBridge::pushLuaFunctionById(evthandler);
    stack->pushString([str UTF8String]);
    stack->executeFunction(1);
}

+ (void) notifyEventByObject: (id) object
{
    NSString* str  = [sdk toJsonStr:object];
    if(!str)
    {
        str = @"";
    }
    [sdk notifyEvent:str];
    
}


///------------------------------------------------------------------

+ (void) setEventHandler:(int) handle
{
    evthandler = handle;
    cocos2d::CCLuaBridge::retainLuaFunctionById(evthandler);
}


+ (void) init:(int) handle
{
    [sdk setEventHandler:handle];
    if(gDic)
    {
        [sdk um_init:gDic];
//        [sdk loc_init:gDic];
        [sdk init_record:gDic];
    }
    else
    {
        NSLog(@"sdk init error, no config");
    }
}

+ (void) config:(id) data
{
    if(nil==gDic)
    {
        gDic = [[NSMutableDictionary alloc ] initWithCapacity:10];
    }
    [gDic removeAllObjects];
    NSDictionary* dic = (NSDictionary*)data;
    for (NSString *key in dic) {
        [gDic setValue:dic[key] forKey:key];
    }
}

+ (void) login:(double) type
{
    int tp = (int)type;
    [sdk um_login:tp];
}

+ (void) share:(id) data
{
    if(![data isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    NSDictionary* dic = (NSDictionary*)data;
    NSNumber* type = [dic valueForKey:SDK_SHARE_TYPE];
    NSString* title = [dic valueForKey:SDK_SHARE_TITLE];
    NSString* text = [dic valueForKey:SDK_SHARE_TEXT];
    NSString* image = [dic valueForKey:SDK_SHARE_IMAGE];
    NSString* url = [dic valueForKey:SDK_SHARE_URL];
    NSNumber* alert = [dic valueForKey:SDK_SHARE_RESULT_ALERT];

    
    if(!type)   type = [NSNumber numberWithInt:-1];
    if(!title)  title=@"";
    if(!text)   text=@"";
    if(!image)  image=@"";
    if(!url)    url=@"";
    if(!alert)  alert = [NSNumber numberWithInt:0];
    
    [sdk um_set_sharealert:[alert intValue]];
    [sdk um_share:[type intValue] Title:title Text:text Img:image Url:url];
}

+ (void) pay:(id) data
{
    
}

+ (void) openBrowser:(NSString*)urlstr
{
    
    float sysver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(sysver>=9.0)
    {
        NSURL* url = [NSURL URLWithString:urlstr];//创建URL
        SFSafariViewController* sfvc = [[SFSafariViewController alloc] initWithURL:url];
        if (@available(iOS 11.0, *)) {
//            [sdk uivc] 使用window[0] 即gamewindow，alert是新的window，从alert返回后立即调用因w0还不是keywindow导致空白
            UIWindow * w0 = [UIApplication sharedApplication].windows[0];
            UIWindow * wk = [UIApplication sharedApplication].keyWindow;
            if(w0!=wk){
                dispatch_async(dispatch_get_main_queue(),^{
                    [w0 makeKeyWindow];
                });
            }
        }
        [[sdk uivc] presentViewController:sfvc animated:YES completion:nil];
    }
    else
    {
        WbViewController* wbvc =  [WbViewController create:urlstr];
        [[sdk uivc] presentViewController:wbvc animated:YES completion:nil];
    }

}

+ (void) openBrowserByWebview:(NSString*)urlstr
{
    WbViewController* wbvc =  [WbViewController create:urlstr];
    [[sdk uivc] presentViewController:wbvc animated:YES completion:nil];
}

+ (BOOL) init_record:(id) dic
{
    [[sdk_audio sharedSdkAudio] init_record:dic];
    return YES;
}
+ (BOOL) start_record:(id) data
{
    NSDictionary* dic = (NSDictionary*)data;
    NSString* filename = [dic valueForKey:SDK_RECORD_FILENAME];
    return [[sdk_audio sharedSdkAudio] start_record: filename];
}

+ (void) stop_record
{
    [[sdk_audio sharedSdkAudio] stop_record];
}

+ (int) record_getVolume
{
   return [[sdk_audio sharedSdkAudio] record_getVolume];
}

+ (void) init_locate
{
    if(gDic)
    {
       [sdk loc_init:gDic];
    }
}

+ (void) start_locate;
{
    [sdk loc_start];
}
+ (void) stop_locate;
{
    [sdk loc_stop];
}
+ (double) get_distance:(double)alongitude :(double)alatitude :(double)blongitude :(double)blatitude
{
    return [sdk loc_get_distance:alongitude :alatitude :blongitude :blatitude];
}

//+ (double) get_distance:(id)data
//{
//    NSMutableArray *array = (NSMutableArray *)data;
//    if([array count]<4)
//    {
//        NSLog(@"sdk get_distance param numb less");
//        return 0;
//    }
//    BOOL valid = YES;
//    for(int i=0;i<4;i++)
//    {
//        if( [array[0] isKindOfClass:[NSNumber class]])
//        {
//            valid = NO;
//        }
//    }
//    if(!valid)
//    {
//        return 0;
//    }
//    NSNumber* a1 = (NSNumber*)array[0];
//    NSNumber* a2 = (NSNumber*)array[1];
//    NSNumber* b1 = (NSNumber*)array[2];
//    NSNumber* b2 = (NSNumber*)array[3];
//    
//    return [sdk loc_get_distance:[a1 doubleValue] :[a2 doubleValue] :[b1 doubleValue] :[b2 doubleValue]];
//}

//-------------------------
+ (NSString*) get_pasteboard
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    NSString* ss = [pasteboard string];
    if(ss==nil)
    {
        return @"";
    }
    return ss;
}

+ (void) set_pasteboard:(NSString*) str
{
    if(str)
    {
        UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:str];
    }
}
//
+ (void) start_vibrator:(long)milliseconds
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
+ (void) stop_vibrator
{
}
//
+ (void) save_image_album:(NSString*) str
{
    [sdk ab_save_image:str Name:NULL];
}

+ (void) iospay_init:(id)data
{
    [sdk iap_init:data];
}
+ (void) iospay_req:(NSString*)pid :(double)numb :(BOOL)force
{
    int nm = (int)numb;
    [sdk iap_req:pid :nm :force];
}
+ (void) iospay_stop
{
     [sdk iap_stop];
}

//-------------------------
+ (BOOL) handle_url:(NSURL*)url
{
    return [sdk um_handle_url:url];
}

+ (BOOL) handle_url:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
//    if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.xin"] && [url.absoluteString containsString:@"pay"]) {
//        return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
//    }
//    else
    {
        return [sdk um_handle_url:url options:options];
    }
    
}

+ (BOOL) handle_url:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [sdk um_handle_url:url sourceApplication:sourceApplication annotation:annotation];
}

@end

//
//  sdk.m
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//
#import "sdk.h"
#import "sdk_audio.h"
#include "CCLuaBridge.h"
#import "sdk_um.h"
//#import <sdk_wx.h>
#import <UIkit/UIWebView.h>
#import <UIKit/UIButton.h>
#import <WebKit/WKWebView.h>
#ifdef __IPHONE_9_0
#import <SafariServices/SFSafariViewController.h>
#endif
#import "WbViewController.h"

static int evthandler;

static NSMutableDictionary* gDic;

@interface sdk ()
+ (void) notifyEventByObject: (id) object;
+ (void) notifyEvent: (NSString*) str;
+ (NSString*) toJsonStr:(id) object;
@end

@implementation sdk

+ (UIViewController*) uivc;
{
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
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

+ (void) login:(int) type
{
    [sdk um_login:type];
}

+ (void) share:(id) data
{
    NSDictionary* dic = (NSDictionary*)data;
    NSNumber* type = [dic valueForKey:SDK_SHARE_TYPE];
    NSString* title = [dic valueForKey:SDK_SHARE_TITLE];
    NSString* text = [dic valueForKey:SDK_SHARE_TEXT];
    NSString* image = [dic valueForKey:SDK_SHARE_IMAGE];
    NSString* url = [dic valueForKey:SDK_SHARE_URL];
    
    if(!type)   type = [NSNumber numberWithInt:-1];
    if(!title)  title=@"";
    if(!text)   text=@"";
    if(!image)  image=@"";
    if(!url)    url=@"";

    [sdk um_share:[type intValue] Title:title Text:text Img:image Url:url];
}

+ (void) pay:(id) data
{
    
}

+ (void) openBrowser:(NSString*)urlstr
{
    
    WbViewController* wbvc =  [WbViewController create:urlstr];
    [[sdk uivc] presentViewController:wbvc animated:YES completion:nil];
    
//    float sysver = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(sysver>9.0)
//    {
//
//        NSURL* url = [NSURL URLWithString:urlstr];//创建URL
//        SFSafariViewController* sfvc = [[SFSafariViewController alloc] initWithURL:url];
//        [[sdk uivc] presentViewController:sfvc animated:YES completion:nil];
//    }
    
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

//-------------------------
+ (BOOL) handle_url:(NSURL*)url
{
    return [sdk um_handle_url:url];
}

+ (BOOL) handle_url:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    return [sdk um_handle_url:url options:options];
}

+ (BOOL) handle_url:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [sdk um_handle_url:url sourceApplication:sourceApplication annotation:annotation];
}

@end

//
//  sdk.h
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "sdkdef.h"
@interface sdk : NSObject
+ (UIViewController*) uivc;
+ (void) notifyEventByObject: (id) object;
+ (void) setEventHandler:(int) handle;

+ (void) config:(id) data;
+ (void) init:(int) handle;
+ (void) login:(double) type;
+ (void) share:(id) data;
+ (void) pay:(id) data;
+ (void) openBrowser:(NSString*)url;
+ (void) openBrowserByWebview:(NSString*)url;

+ (BOOL) init_record:(id) data;
+ (BOOL) start_record:(id) data;
+ (void) stop_record;
+ (int) record_getVolume;

+ (void) init_locate;
+ (void) start_locate;
+ (void) stop_locate;
+ (double) get_distance:(double)alongitude :(double)alatitude :(double)blongitude :(double) blatitude;
//+ (double) get_distance:(id)array;
+ (NSString*) get_pasteboard;
+ (void) set_pasteboard:(NSString*) str;
//
+ (void) start_vibrator:(long)milliseconds;
+ (void) stop_vibrator;

//save image
+ (void) save_image_album:(NSString*) str;


//pay init
+ (void) iospay_init:(id)data;
+ (void) iospay_req:(NSString*)pid :(double)numb :(BOOL)force;
+ (void) iospay_stop;
//-------------------------
+ (BOOL) handle_url:(NSURL*)url;
+ (BOOL) handle_url:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;
+ (BOOL) handle_url:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end

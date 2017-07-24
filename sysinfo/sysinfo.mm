//
//  sdk.m
//  sdk
//
//  Created by Jeep on 16/11/17.
//  Copyright © 2016年 Jeep. All rights reserved.
//
#import "sysinfo.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#include <memory>
#include <mutex>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "Reachability.h"
#import "getipaddr.h"

#import "SimulateIDFA.h"

@interface sysinfo ()
+ (NSString*) getbundle: (NSString*) key;
@end

@implementation sysinfo


+ (NSString*) getbundle: (NSString*) key
{
    NSString* value = [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
    if(value){
        return value;
    }else{
        return @"";
    }
}


//0 no
//1 4g
//2 wifi
+ (int) netstate
{
    int state = 0;
    Reachability * r = [Reachability reachabilityWithHostName : @"www.apple.com"];
    switch ([r currentReachabilityStatus])
    {
        case NotReachable:
            state = 0;
            break;
        case ReachableViaWWAN:
            state = 1;
            break;
        case ReachableViaWiFi:
            state = 2;
            break;
    }
    return state;
}

+ (int) batteryinfo
{
    return 90;
}

+ (NSString*) imsi
{
    return @"0000";
}

+ (NSString*) imei
{
    NSString *simulateIDFA = [SimulateIDFA createSimulateIDFA];
    return simulateIDFA;
}

+ (NSString*) ipaddress
{
    return [getipaddr ip];
}

+ (NSString*) macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = (char*)malloc(len)) == NULL)
    {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    char tmp[64] = { 0 };
    sprintf(tmp, "%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5));
    
    free(buf);
    
    return [NSString stringWithUTF8String:tmp];
    
}

+ (NSString*) mobilemodel
{
    return [[UIDevice currentDevice] model];
}

+ (NSString*) systemversion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*) packagename
{
    return [sysinfo getbundle:@"CFBundleIdentifier"];
}


+ (NSString*) appname
{
    return [sysinfo getbundle:@"CFBundleDisplayName"];
}

+ (NSString*) appversion
{
    return [sysinfo getbundle:@"CFBundleVersion"];
}

+ (NSString*) country
{
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    return countryCode;
}

+ (NSString*) downloadurl
{
    return @"http://www.apple.com";
}

+ (BOOL) isinstall:(NSString*) name
{
    NSURL* url = [NSURL URLWithString:name];//@"weixin://"
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (void) openapp:(NSString*) name
{
    NSURL* url = [NSURL URLWithString:name];//@"weixin://"
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


static unsigned long long  us_since_boot() {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    int rc = sysctl(mib, 2, &boottime, &size, NULL, 0);
    if (rc != 0) {
        return 0;
    }
    return boottime.tv_sec;
}

static unsigned long long us_uptime()
{
    unsigned long long before_now;
    unsigned long long after_now;
    struct timeval now;
    
    after_now = us_since_boot();
    do {
        before_now = after_now;
        gettimeofday(&now, NULL);
        after_now = us_since_boot();
    } while (after_now != before_now);
    
    return (now.tv_sec - before_now);
}

+ (unsigned long) elapsedtime
{
    return us_uptime();
}

@end

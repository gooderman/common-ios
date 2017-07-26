//
//  bdlocate.m
//  bdlocate
//
//  Created by Jeep on 2017/5/13.
//  Copyright © 2017年 Jeep. All rights reserved.
//
//MARK::Location
#include "sdk.h"
#include "sdk_baiduloc.h"
#import "bdlocate.h"
@implementation sdk (um)
+ (void) loc_init: (NSDictionary*)dic
{
    NSString* key = [dic valueForKey:TOKEN_BD_LOCKEY];
    if(key==nil)
    {
        key = [[[NSBundle mainBundle] infoDictionary] objectForKey:TOKEN_BD_LOCKEY];
        NSLog(@"sdk loc_init %@ empty",TOKEN_BD_LOCKEY);
    }
    if(key==nil)
    {
        key = BMK_KEY;
        NSLog(@"sdk loc_init bundle:%@ empty",TOKEN_BD_LOCKEY);
    }
    [[bdlocate sharedBdLocate] init:key];
}

+ (void) loc_start
{
    [[bdlocate sharedBdLocate] stop];
    [[bdlocate sharedBdLocate] start];
}
+ (void) loc_stop
{
    [[bdlocate sharedBdLocate] stop];
}
+ (double) loc_get_distance:(double)ajd : (double)awd : (double)bjd :(double)bwd
{
    return [bdlocate getDistance:ajd :awd :bjd :bwd];
}
+ (void) loc_notify:(int)error : (double)ajd : (double)awd : (NSString*)address
{
    [[bdlocate sharedBdLocate] stop];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    [dic setValue:SDK_EVT_LOCATION forKey:SDK_EVT];
    [dic setValue:[NSNumber numberWithInt:error] forKey:SDK_ERROR];
    [dic setValue:[NSNumber numberWithDouble:ajd] forKey:SDK_LOCATION_LONGITUDE];
    [dic setValue:[NSNumber numberWithDouble:awd] forKey:SDK_LOCATION_LATITUDE];
    if(address){
        [dic setValue:address forKey:SDK_LOCATION_ADDRESS];
    }
    else{
        [dic setValue:@"" forKey:SDK_LOCATION_ADDRESS];
    }
    [dic setValue:@"" forKey:SDK_LOCATION_ADDRESS_DESCRIBE];
    [sdk notifyEventByObject:dic];
}

@end



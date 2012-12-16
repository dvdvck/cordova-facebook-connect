//
//  FBDialogDelegate.m
//
// Created by David Retana on 2012-12-15
//
// Copyright 2012 Olivier Louvignes. All rights reserved.
// MIT Licensed

#import "FBDialogDelegate.h"
#import <Cordova/CDVPlugin.h>

@interface FBDialogDelegate() {}

@property (readwrite, assign)CDVPlugin *plugin;
@property (readwrite, assign)NSString *callbackId;

@end

@implementation FBDialogDelegate

@synthesize plugin = _plugin, callbackId = _callbackId;

- (id)initWithCDVPlugin:(CDVPlugin *)plugin andCallbackId:(NSString *)callbackId;
{
    self = [super init];
    if (self) {
        _plugin = plugin;
        _callbackId = [callbackId copy];
    }
    return self;
}

/**
    Called when there is not internet access
*/
- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError:%@", [error localizedDescription]);

    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[error code]], @"code", [error domain], @"domain", [error localizedDescription], @"description",nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:info];
    [self.plugin error:pluginResult callbackId:self.callbackId];
}

/**
 * Called when a UIServer Dialog is closed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog {
    NSLog(@"dialogDidNotComplete");
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"-10", @"code", @"cancelled", @"domain", @"User dissmissed the dialog", @"description", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:info];
    [self.plugin error:pluginResult callbackId:self.callbackId];
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url
{
    NSLog(@"dialogDidNotCompleteWithUrl");
}


- (void)dialogDidComplete:(FBDialog *)dialog
{
    NSLog(@"dialogDidComplete");
}

/**
 * Called when a UIServer Dialog successfully returns. Use this callback
 * instead of dialogDidComplete: to properly handle successful shares/sends
 * that return ID data back.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url
{
    if (![url query]) {
        NSLog(@"User canceled dialog or there was an error");
       [self dialogDidNotComplete:nil];
        
    } else {
        CDVPluginResult* pluginResult;
        NSDictionary *result = nil;
        @try {
            result = [self parseURLParams:[url query]]; 

        } @catch (NSException *exception) {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys: [exception name], @"code", @"exception", @"domain", [exception reason], @"description", nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsDictionary:info];
            [self.plugin error:pluginResult callbackId:self.callbackId];
            return;
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [self.plugin success:pluginResult callbackId:self.callbackId];
    }
}

/**
 * Helper method to parse URL query parameters. The original definition is from the Hackbook example.
 */
- (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *key = [[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:key];
    }
    return params;
}

@end
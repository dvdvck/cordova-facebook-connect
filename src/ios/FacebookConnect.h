//
//  FacebookConnect.h
//
// Created by Olivier Louvignes on 2012-06-25.
// Modified by David Retana on 2012-12-15
//
// Copyright 2012 Olivier Louvignes. All rights reserved.
// MIT Licensed

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface FacebookConnect : CDVPlugin {}

#pragma mark - Properties

/* Since sessionHandler are executed for all changes on state session property
we need to differenciate those executions which are thrown by 
openSession and reauthorizeSession methods
*/
@property BOOL openSessionCallback;
@property BOOL reauthorizeSessionCallback;

#pragma mark - Instance methods

- (void)openSession:(CDVInvokedUrlCommand *)command;
- (void)reauthorizeSession:(CDVInvokedUrlCommand *)command;
- (void)requestWithGraphPath:(CDVInvokedUrlCommand *)command;
- (void)closeSession:(CDVInvokedUrlCommand *)command;
- (void)dialog:(CDVInvokedUrlCommand *)command;

@end

#pragma mark - Logging tools
#define DEBUG
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

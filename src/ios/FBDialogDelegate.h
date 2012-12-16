//
//  FBDialogDelegate.h
//
// Created by David Retana on 2012-12-15
//
// Copyright 2012 Olivier Louvignes. All rights reserved.
// MIT Licensed

#import <Foundation/Foundation.h>
#import "FBDialog.h"

@class CDVPlugin;

@interface FBDialogDelegate : NSObject <FBDialogDelegate> {}

- (id)initWithCDVPlugin:(CDVPlugin *)plugin andCallbackId:(NSString *)callbackId;

@end

//
//  FacebookConnect.m
//
// Created by Olivier Louvignes on 2012-06-25.
// Modified by David Retana on 2012-12-15
//
// Copyright 2012 Olivier Louvignes. All rights reserved.
// MIT Licensed

#import "FacebookConnect.h"
// #import <FacebookSDK/FacebookSDK.h>

//Until dialog component gets updated
#import "Facebook.h"
#import "FBDialogDelegate.h"

@implementation FacebookConnect

@synthesize openSessionCallback, reauthorizeSessionCallback;

#pragma mark - Cordova plugin interface

/**
Perform a request to a graph path with params and http method specified
*/
- (void)requestWithGraphPath:(CDVInvokedUrlCommand *)command
{
	DLog(@"requestWithGraphPath:%@", command.arguments);

	if( ![FBSession openActiveSessionWithAllowLoginUI:NO] ){
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"code", @"error", @"domain", @"There is not an active session. Open it with openSession method.", @"description",nil];
	    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsDictionary:info];
        [self error:pluginResult callbackId:command.callbackId];
		return;
	}

	NSString *path = [command.arguments objectAtIndex:0];
	NSMutableDictionary *params = [command.arguments objectAtIndex:1];
	NSString *httpMethod = [command.arguments objectAtIndex:2];

	[FBRequestConnection startWithGraphPath:path parameters:params HTTPMethod:httpMethod
        completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
		    DLog(@"%@", [result description]);
		    CDVPluginResult *pluginResult;

    		if(error){
        		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[error code]], @"code", [error domain], @"domain", [error localizedDescription], @"description",nil];
	    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:info];
		        [self error:pluginResult callbackId:command.callbackId];

		    }else{
				NSMutableDictionary *mutableResult = [result mutableCopy];
				pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:mutableResult];
				[self success:pluginResult callbackId:command.callbackId];
		    }
        }
    ];
}

/**
Show a web dialog. This dialog uses legacy Facebook SDK
*/
- (void)dialog:(CDVInvokedUrlCommand *)command
{
	DLog(@"%@", command.arguments);
	NSLog(@"%@", command.callbackId);

	if( ![FBSession openActiveSessionWithAllowLoginUI:NO] ){
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"code", @"error", @"domain", @"There is not an active session. Open it with openSession method.", @"description",nil];
	    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsDictionary:info];
        [self error:pluginResult callbackId:command.callbackId];
		return;
	}

	NSString *method = [command.arguments objectAtIndex:0];
	NSMutableDictionary *params = [command.arguments objectAtIndex:1];

	Facebook *facebook = [[Facebook alloc] initWithAppId:FBSession.activeSession.appID andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;

    FBDialogDelegate *dialogDelegate = [[FBDialogDelegate alloc] initWithCDVPlugin: self andCallbackId:command.callbackId];
	[facebook dialog:method andParams:params andDelegate:dialogDelegate];    
}

- (void) handleOpenURL:(NSNotification *)notification
{
	NSURL* url = [notification object];
	if (![url isKindOfClass:[NSURL class]]) {
		return;
	}
	[FBSession.activeSession handleOpenURL:url];
}

/**
Close the active session if the his state is FBSessionStateCreatedOpening
*/
- (void) onResume
{
	[FBSession.activeSession handleDidBecomeActive];
}

/**
Close active session
*/
- (void) onAppTerminate
{
	[FBSession.activeSession close];
}

/**
Takes the permissions array and if it should shows UILogin
*/
- (void) openSession:(CDVInvokedUrlCommand *)command
{
	CDVPluginResult *pluginResult;
	FBSession *activeSession = FBSession.activeSession;
	if( [activeSession isOpen] ){
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
            messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithInt:activeSession.state], @"state", activeSession.permissions, @"permissions", nil]];
		[self success:pluginResult callbackId:command.callbackId];
		return;
	}
	
	NSArray *permissions = [command.arguments objectAtIndex:0];
	BOOL allowLoginUI = [[command.arguments objectAtIndex:1] boolValue];
	self.openSessionCallback = YES;

	NSLog(@"arguments: %@, %i", permissions, allowLoginUI);

    @try {
	    [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:allowLoginUI
	        completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
			    DLog(@"%@", [session description]);
	         	if(self.openSessionCallback == NO){
	        		return;
	        	}
                CDVPluginResult *pluginResult;
	        	if(error){
	        		NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[error code]], @"code", [error domain], @"domain", [error localizedDescription], @"description",nil];
	        		[info setObject:[NSNumber numberWithInt:state] forKey:@"sessionState"];
		    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:info];
			        [self error:pluginResult callbackId:command.callbackId];

	            }else{
					pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
	                    messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
	                        [NSNumber numberWithInt:state], @"state", session.permissions, @"permissions", nil]];
					[self success:pluginResult callbackId:command.callbackId];
	            }

	            self.openSessionCallback=NO;

	        }
	    ];
    } @catch (NSException *exception) {
    	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys: [exception name], @"code", @"exception", @"domain", [exception reason], @"description", nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsDictionary:info];
        [self error:pluginResult callbackId:command.callbackId];
    }

}

/**
	Close FB session and clean credentials tokens
*/
- (void) closeSession:(CDVInvokedUrlCommand *)command
{
	[FBSession.activeSession closeAndClearTokenInformation];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self success:pluginResult callbackId:command.callbackId];
}

/**
Only reauthorize if there is an active session or at least there were access tokens cached
*/
- (void) reauthorizeSession:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult;
	NSArray *permissions = [command.arguments objectAtIndex:0];
	FBSessionDefaultAudience audience = [[command.arguments objectAtIndex:1] intValue];
	self.reauthorizeSessionCallback=YES;

	NSLog(@"Reauthorize: %@,%i", permissions, audience);

	void (^reauthorizeHandler)(FBSession *, NSError *) = ^(FBSession *session, NSError *error) {
	    DLog(@"%@", [session description]);
		if( self.reauthorizeSessionCallback == NO ){
			return;
		}
        CDVPluginResult *pluginResult;
    	if(error){
    		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[error code]], @"code", [error domain], @"domain", [error localizedDescription], @"description", nil];
    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:info];
	        [self error:pluginResult callbackId:command.callbackId];

        }else{
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                    session.permissions, @"permissions", nil]];
			[self success:pluginResult callbackId:command.callbackId];
        }
	    
	  	self.reauthorizeSessionCallback = NO;
	};

    @try {
    	[FBSession openActiveSessionWithAllowLoginUI:NO];
		if(audience == FBSessionDefaultAudienceNone){
			[FBSession.activeSession reauthorizeWithReadPermissions:permissions completionHandler: reauthorizeHandler];

		}else{
			[FBSession.activeSession reauthorizeWithPublishPermissions:permissions defaultAudience:audience completionHandler: reauthorizeHandler];
		}
    } @catch (NSException *exception) {
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys: [exception name], @"code", @"exception", @"domain", [exception reason], @"description", nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsDictionary:info];
        [self error:pluginResult callbackId:command.callbackId];
    }

}

@end

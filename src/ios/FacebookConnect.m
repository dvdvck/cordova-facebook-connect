//
//  FacebookConnect.m
//
// Created by Olivier Louvignes on 2012-06-25.
//
// Copyright 2012 Olivier Louvignes. All rights reserved.
// MIT Licensed

#import "FacebookConnect.h"
#import <Cordova/JSONKit.h>

NSString *const kFunctionDialog = @"dialog";
NSString *const kFunctionOpen = @"openSession";
NSString *const kFunctionClose = @"closeSession";
NSString *const kFunctionReauthorize = @"reauthorizeSession";

@implementation FacebookConnect

@synthesize callbackIds = _callbackIds;
@synthesize facebookRequests = _facebookRequests;
@synthesize dateFormatter = _dateFormatter;
@synthesize openSessionCallback, reauthorizeSessionCallback;

#pragma mark - Custom getters & setters

- (NSMutableDictionary *)callbackIds {
	if(_callbackIds == nil) {
		_callbackIds = [[NSMutableDictionary alloc] init];
	}
	return _callbackIds;
}
- (NSMutableDictionary *)facebookRequests {
	if(_facebookRequests == nil) {
		_facebookRequests = [[NSMutableDictionary alloc] init];
	}
	return _facebookRequests;
}
- (NSDateFormatter *)dateFormatter {
	if(_dateFormatter == nil) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	}
	return _dateFormatter;
}

#pragma mark - Cordova plugin interface
/*
- (void)logins:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
	ALog(@"login:%@\n withDict:%@", arguments, options);

	// The first argument in the arguments parameter is the callbackId.
	[self.callbackIds setValue:[arguments pop] forKey:@"login"];
	NSMutableArray *permissions = [options objectForKey:@"permissions"] ?: [[NSMutableArray alloc] init];

//	if([options objectForKey:@"appId"]) {
//		self.appId = [options objectForKey:@"appId"];
		// Check for any stored session update Facebook session information
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
			self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
			self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
		}
//	}

	if (![self.facebook isSessionValid]) {
		[self.facebook authorize:permissions];
	} else {
		[self.facebookRequests setValue:[self.facebook requestWithGraphPath:@"me" andDelegate:self]
								 forKey:[self.callbackIds valueForKey:@"login"]];
	}

}

- (void)requestWithGraphPath:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
	DLog(@"requestWithGraphPath:%@\n withDict:%@", arguments, options);

	// The first argument in the arguments parameter is the callbackId.
	[self.callbackIds setValue:[arguments pop] forKey:@"requestWithGraphPath"];
	NSString *path = [options objectForKey:@"path"] ?: @"me";
	NSMutableDictionary *params = [options objectForKey:@"options"] ?: [[NSMutableDictionary alloc] init];
	NSString *httpMethod = [options objectForKey:@"httpMethod"] ?: @"GET";

	// Make sure we pass a string for a limit key
	if([params valueForKey:@"limit"]) [params setValue:[NSString stringWithFormat:@"%d", [[params valueForKey:@"limit"] integerValue]] forKey:@"limit"];

	FBRequest *request = [self.facebook requestWithGraphPath:path andParams:params andHttpMethod:httpMethod andDelegate:self];

	[self.facebookRequests setValue:request
							 forKey:[self.callbackIds valueForKey:@"requestWithGraphPath"]];

}

- (void)dialog:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
	DLog(@"%@:%@\n withDict:%@", kFunctionDialog, arguments, options);

	// The first argument in the arguments parameter is the callbackId.
	[self.callbackIds setValue:[arguments pop] forKey:kFunctionDialog];
	NSString *method = [options objectForKey:@"method"] ?: @"apprequests";
	NSMutableDictionary* params = [options objectForKey:@"params"] ?: [[NSMutableDictionary alloc] init];

	[self.facebook dialog:method andParams:params andDelegate:self];
}


- (void)logouts:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
	DLog(@"logout:%@\n withDict:%@", arguments, options);

	// The first argument in the arguments parameter is the callbackId.
	[self.callbackIds setValue:[arguments pop] forKey:@"logout"];
	[self.facebook logout];

}
*/

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
  	state:(FBSessionState) state
  	error:(NSError *)error
{
    DLog(@"session: %@", [session description]);
    NSLog(@"error code: %d", error.code);
    NSLog(@"error: %@", [error localizedDescription]);

    /*
	Cada vez que se hace login() se emiten dos eventos. el primero es un FBSessionStateClosed y 
	el segundo un FBSessionStateOpen. Ambos sin error.

	Cuando la app:
	esta desactivada en los settings de iphone
	state:FBSessionStateClosedLoginFailed
	error.code: 2

	no ha sido autorizada en fb y no estan los setting  en el iphone
	lanza el mensaje de autenticacion


    */

    return;
	CDVPluginResult* pluginResult = nil;
    NSString* callbackId = [self.callbackIds valueForKey:@"login"];

    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
		
				pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
				[self success:pluginResult callbackId:callbackId];
                NSLog(@"User session found");
            }else{

	    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
		        [self error:pluginResult callbackId:callbackId];

            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
    	
    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT messageAsString:[error localizedDescription]];
	        [self error:pluginResult callbackId:callbackId];
        
            break;
        default:
    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsString:[error localizedDescription]];
	        [self error:pluginResult callbackId:callbackId];
            break;
    }
/*
FBSessionStateCreated = 0,
FBSessionStateCreatedTokenLoaded = 1,
FBSessionStateCreatedOpening = 2,
 FBSessionStateOpen = 1 | FB_SESSIONSTATEOPENBIT,
FBSessionStateOpenTokenExtended = 2 | FB_SESSIONSTATEOPENBIT,
 FBSessionStateClosedLoginFailed = 1 | FB_SESSIONSTATETERMINALBIT,
 FBSessionStateClosed = 2 | FB_SESSIONSTATETERMINALBIT,
*/
    // [[NSNotificationCenter defaultCenter]
    //  postNotificationName:FBSessionStateChangedNotification
    //  object:session];
    
    // if (error) {
    //     UIAlertView *alertView = [[UIAlertView alloc]
    //                               initWithTitle:@"Error"
    //                               message:error.localizedDescription
    //                               delegate:nil
    //                               cancelButtonTitle:@"OK"
    //                               otherButtonTitles:nil];
    //     [alertView show];
    // }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI withPermissions:(NSArray *)permissions
{
    return [FBSession openActiveSessionWithPublishPermissions:permissions
    			defaultAudience: 30
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             [self sessionStateChanged:session state:state error:error];
                                         }
            ];
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
		    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
		    	    	messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
	    					[NSNumber numberWithInt:state], @"state", [error localizedDescription], @"error", nil]];
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
    } @catch (id exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsString:[exception reason]];
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
    	    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
    	    	messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys: [error localizedDescription], @"error", nil]];
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
		if(audience == FBSessionDefaultAudienceNone){
			[FBSession.activeSession reauthorizeWithReadPermissions:permissions completionHandler: reauthorizeHandler];

		}else{
			[FBSession.activeSession reauthorizeWithPublishPermissions:permissions defaultAudience:audience completionHandler: reauthorizeHandler];
		}
    } @catch (id exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsString:[exception reason]];
        [self error:pluginResult callbackId:command.callbackId];
    }

}

/*
#pragma mark - < FBSessionDelegate >

- (void)fbDidLogin {
	DLog(@"fbDidLogin");

	// Update session information in NSUserDefaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
	[defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
	[defaults synchronize];

	// Perform initial graph request
	[self.facebookRequests setValue:[self.facebook requestWithGraphPath:@"me" andDelegate:self]
							 forKey:[self.callbackIds valueForKey:@"login"]];

}

- (void)fbDidNotLogin:(BOOL)cancelled {
	DLog(@"fbDidNotLogin:%@", cancelled ? @"YES" : @"NO");

	NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"cancelled", @"User dissmissed the login", @"message", nil];
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
	[self writeJavascript:[pluginResult toErrorCallbackString:[self.callbackIds valueForKey:@"login"]]];
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
	DLog(@"fbDidExtendToken:%@\n expiresAt:%@", accessToken, expiresAt);

	// Update session information in NSUserDefaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
	[defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
	[defaults synchronize];

}

- (void)fbDidLogout {

	// Cleared stored session information
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"FBAccessTokenKey"];
	[defaults removeObjectForKey:@"FBExpirationDateKey"];
	[defaults synchronize];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self writeJavascript:[pluginResult toSuccessCallbackString:[self.callbackIds valueForKey:@"logout"]]];

}

- (void)fbSessionInvalidated {}
*/
#pragma mark - < FBRequestDelegate >

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	//DLog(@"request:%@\n didReceiveResponse:%@", request, response);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
/*
- (void)request:(FBRequest *)request didLoad:(id)result {
	DLog(@"request:%@\n didLoad:%@", request, result);

	// Loop through facebookRequests to find matching one
	NSString *matchingCallbackId = nil;
	for (id key in self.facebookRequests) {
		id value = [self.facebookRequests objectForKey:key];
		if(request == value) matchingCallbackId = key;
	}

	if ([result isKindOfClass:[NSDictionary class]]) {

		NSMutableDictionary *mutableResult = [result mutableCopy];
		[mutableResult setObject:self.facebook.accessToken forKey:@"accessToken"];
		[mutableResult setObject:[self.dateFormatter stringFromDate:self.facebook.expirationDate] forKey:@"expirationDate"];

		CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:mutableResult];
		[self writeJavascript:[pluginResult toSuccessCallbackString:matchingCallbackId]];

	} else if ([result isKindOfClass:[NSData class]]) {
		DLog(@"Unsupported result... todo! %@", result);
		//[profilePicture release];
		//profilePicture = [[UIImage alloc] initWithData: result];
	} else {
		DLog(@"Unsupported result... todo! %@", result);
	}

};
*/
/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
/*
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	DLog(@"request:%@\n didFailWithError:%@", request, error);

	// Loop through facebookRequests to find matching one
	NSString *matchingCallbackId = nil;
	for (id key in self.facebookRequests) {
		id value = [self.facebookRequests objectForKey:key];
		if(request == value) matchingCallbackId = key;
	}

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
	[self writeJavascript:[pluginResult toErrorCallbackString:matchingCallbackId]];
};
*/
#pragma mark - < FBDialogDelegate >

/**
 * Called when a UIServer Dialog is closed.
 */
/*- (void)dialogDidNotComplete:(FBDialog *)dialog {
	DLog(@"dialogDidNotComplete:%@", dialog);

	NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"cancelled", @"User dissmissed the dialog", @"message", nil];
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
	[self writeJavascript:[pluginResult toErrorCallbackString:[self.callbackIds valueForKey:kFunctionDialog]]];
}
*/
/**
 * Called when a UIServer Dialog successfully returns. Use this callback
 * instead of dialogDidComplete: to properly handle successful shares/sends
 * that return ID data back.
 */
/*- (void)dialogCompleteWithUrl:(NSURL *)url {
	if (![url query]) {
		DLog(@"User canceled dialog or there was an error");
		[self dialogDidNotComplete:nil];
	}
	else {
		NSDictionary *result = [self parseURLParams:[url query]];
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
		[self writeJavascript:[pluginResult toSuccessCallbackString:[self.callbackIds valueForKey:kFunctionDialog]]];
	}
}
*/
/**
 * Helper method to parse URL query parameters. The original definition is from the Hackbook example.
 */
/*- (NSDictionary *)parseURLParams:(NSString *)query {
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
*/
@end

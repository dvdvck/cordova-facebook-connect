//
//  FacebookConnect.js
//
// Created by Olivier Louvignes on 2012-06-25.
//
// Copyright 2012 Olivier Louvignes. All rights reserved.
// MIT Licensed

(function(cordova) {

	function FacebookConnect() {}
	var service = 'FacebookConnect',
	openSession = false,

    FBSessionDefaultAudienceNone                = 0,
	FBSessionDefaultAudienceOnlyMe              = 10,
    FBSessionDefaultAudienceFriends             = 20,
    FBSessionDefaultAudienceEveryone            = 30;

    /*! No audience needed; this value is useful for cases where data will only be read from Facebook */
    FacebookConnect.prototype.FBSessionDefaultAudienceNone                = FBSessionDefaultAudienceNone;
    /*! Indicates that only the user is able to see posts made by the application */
	FacebookConnect.prototype.FBSessionDefaultAudienceOnlyMe              = FBSessionDefaultAudienceOnlyMe;
    /*! Indicates that the user's friends are able to see posts made by the application */
    FacebookConnect.prototype.FBSessionDefaultAudienceFriends             = FBSessionDefaultAudienceFriends;
    /*! Indicates that all Facebook users are able to see posts made by the application */
    FacebookConnect.prototype.FBSessionDefaultAudienceEveryone            = FBSessionDefaultAudienceEveryone;

	/**
	From active session, reauthorize it addding this permissions
	This actions depends on type of read or publish permissions

	@throws Error if there isnt an active session
	@throws Error if there isnt at least one permission
	@param permissions array list of permissions. Default: []
	@param audience int set the audience for those permissions, when is FBSessionDefaultAudienceNone
		all the permissions need to be for read. Default: FBSessionDefaultAudienceNone
	*/
	FacebookConnect.prototype.reauthorizeSession = function(options, callback) {
		// if(!openSession){
		// 	throw Error('There is not an active Session :(');
		// }
		var config = [];

		//permissions
		config.push(options && options.permissions instanceof Array?options.permissions:[]);
		//audience?
		config.push((function(audience){
			if( options && typeof options.audience ==='number' ){
				switch(options.audience){
					case FBSessionDefaultAudienceEveryone:
					case FBSessionDefaultAudienceFriends:
					case FBSessionDefaultAudienceOnlyMe:
						audience = options.audience;
				}
			}
			return audience;
		}(FBSessionDefaultAudienceNone)));

		var _callback = function() {
			//console.log('FacebookConnect.initWithAppId: %o', arguments);
			if(typeof callback == 'function') callback.apply(null, arguments);
		};

		var _errCallback = function(){
			//some internal handlers here!
			if(typeof callback == 'function') callback.apply(null, arguments);
		};
		console.log('FacebookConnect.reauthorize: %o', config);
		return cordova.exec(_callback, _errCallback, service, 'reauthorizeSession', config);
	};

	/**
	Open a FBSession with read permissions only
	@param permissions array list of permissions. Default: []
	@param showUI array if it should shows UIlogin to open a session. Default: true
	*/
	FacebookConnect.prototype.openSession = function(options, callback) {
		var config = [];

		//permissions
		config.push(options && options.permissions instanceof Array?options.permissions:[]);
		//showUI
		config.push(function(valueSet){
			return valueSet?options.showUI:true;
		}(options && typeof options.showUI === 'boolean'));
		
		callback = options && typeof options === "function"? options:callback; 

		var _callback = function() {
			openSession = true;
			//console.log('FacebookConnect.login: %o', arguments);
			if(typeof callback == 'function') callback.apply(null, arguments);
		};

		var _errCallback = function(){
			//some internal handlers here!
			openSession = false;
			if(typeof callback == 'function') callback.apply(null, arguments);
		};

		console.log('FacebookConnect.openSession: %o', config);
		return cordova.exec(_callback, _errCallback, service, 'openSession', config);

	};

	FacebookConnect.prototype.closeSession = function(callback) {

		var _callback = function() {
			openSession = false;
			//console.log('FacebookConnect.logout: %o', arguments);
			if(typeof callback == 'function') callback.apply(null, arguments);
		};

		return cordova.exec(_callback, _callback, service, 'closeSession', []);

	};

	/**
	 * Make an asynchrous Facebook Graph API request.
	 *
	 * @param {String} path Is the path to the Graph API endpoint.
	 * @param {Object} [options] Are optional key-value string pairs representing the API call parameters.
	 * @param {String} [httpMethod] Is an optional HTTP method that defaults to GET.
	 * @param {Function} [callback] Is an optional callback method that receives the results of the API call.
	 */
	FacebookConnect.prototype.requestWithGraphPath = function(path, options, httpMethod, callback) {
		var method;

		if(!path) path = "me";
		if(typeof options === 'function') {
			callback = options;
			options = {};
			httpMethod = undefined;
		}
		if (typeof httpMethod === 'function') {
			callback = httpMethod;
			httpMethod = undefined;
		}
		httpMethod = httpMethod || 'GET';

		var _callback = function() {
			//console.log('FacebookConnect.requestWithGraphPath: %o', arguments);
			if(typeof callback == 'function') callback.apply(null, arguments);
		};

		return cordova.exec(_callback, _callback, service, 'requestWithGraphPath', [{path: path, options: options, httpMethod: httpMethod}]);

	};

	FacebookConnect.prototype.dialog = function(method, params, callback) {
		var config = [];
		if(typeof method === 'function'){
			callback = method;
			method = "apprequests";
			params = {};
		}
		if(typeof method === 'object'){
			callback = params;
			params = method;
			method = "apprequests";
		}

		//method
		config.push(method);
		//params
		config.push(params);

		var _callback = function() {
			//console.log('FacebookConnect.dialog: %o', arguments);
			if(typeof callback == 'function') callback.apply(null, arguments);
		};
		//sueño ataca de nuevo ...
		return cordova.exec(_callback, _callback, service, 'dialog', config);
	};

	cordova.addConstructor(function() {
		if(!window.plugins) window.plugins = {};
		window.plugins.facebookConnect = new FacebookConnect();
	});

})(window.cordova || window.Cordova);

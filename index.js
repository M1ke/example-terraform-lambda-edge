'use strict';

const AWS = require('aws-sdk');

const PASSWORD = '${password}'

function responseUnauthorized(body){
	return {
		status: '401',
		statusDescription: 'Unauthorized',
		body: body,
		headers: {
			'www-authenticate': [{key: 'WWW-Authenticate', value:'Basic'}]
		},
	};
}

function callbackResponseUnauthorized(callback, body){
	const response = responseUnauthorized(body);
	callback(null, response);
}

function doAuth(callback, request, userAuth, bucket, file ){
	if (PASSWORD!==userAuth) {
		return callbackResponseUnauthorized(callback, "You got the password wrong");
	}

	// Continue request processing if authentication passed
	callback(null, request);
}

exports.handler = (event, context, callback) => {
	// Get request and request headers
	const request = event.Records[0].cf.request;
	const headers = request.headers;

	if (typeof headers.authorization == 'undefined'){
		return callbackResponseUnauthorized(callback, 'Your request must include an "authorization" header');
	}

	const userAuth = headers.authorization[0].value;

	if (!userAuth) {
		return callbackResponseUnauthorized(callback, 'Your "authorization" header must not be blank');
	}

	doAuth(callback, request, userAuth);
};

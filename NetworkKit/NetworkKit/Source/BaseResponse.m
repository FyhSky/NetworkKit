//
//  BaseResponse.m
//  
//
//  Created by FengYinghao on 11/16/15.
//
//

#import "BaseResponse.h"

@interface BaseResponse()

@property (nonatomic, copy, readwrite) NSString *requestURL;
@property (nonatomic, strong, readwrite) NSURLRequest *readonlyRequest;
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *readonlyResponse;
@property (nonatomic, copy, readwrite) NSDictionary *requestParams;
@property (nonatomic, copy, readwrite) NSString *HTTPMethod;
@property (nonatomic, assign, readwrite) NSInteger HTTPStatusCode;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, copy, readwrite) NSString *responseString;
@property (nonatomic, strong, readwrite) id responseJSONObject;
@property (nonatomic, strong, readwrite) id responseImageObject;
@property (nonatomic, strong, readwrite) id responseXMLObject;
@property (nonatomic, strong, readwrite) id responseData;

@end

@implementation BaseResponse


- (id)initWithURLString:(NSString *)aURLString
                 params:(NSDictionary *)params
             httpMethod:(NSString *)method {
    self = [super init];
    if (self) {
        _requestURL = aURLString;
        _requestParams = [params copy];
        _HTTPMethod = [method copy];
    }
    return self;
}

- (NSString*)requestURL {
    return _requestURL;
}

- (NSString*)HTTPMethod {
    return _HTTPMethod;
}

- (NSDictionary*)requestParams {
    return _requestParams;
}

- (NSError*)responseError {
    return _error;
}


- (void)setResponseString:(NSString *)responseString {
     _responseString = responseString;
}

- (void)setResponseJSONObject:(id)responseJSONObject {
     _responseJSONObject = responseJSONObject;
}

- (void)setResponseImageObject:(id)responseImageObject {
    _responseImageObject = responseImageObject;
}

- (void)setResponseXMLObject:(id)responseXMLObject {
    _responseXMLObject = responseXMLObject;
}

- (void)setHTTPStatusCode:(NSInteger)HTTPStatusCode {
    _HTTPStatusCode = HTTPStatusCode;
}

- (void)setReadonlyRequest:(NSURLRequest *)readonlyRequest {
    _readonlyRequest = readonlyRequest;
}

- (void)setReadonlyResponse:(NSHTTPURLResponse *)readonlyResponse {
    _readonlyResponse = readonlyResponse;
}

- (void)setResponseError:(NSError *)responseError {
    _error = responseError;
}

@end

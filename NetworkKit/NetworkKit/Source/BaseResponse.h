//
//  BaseResponse.h
//  
//
//  Created by FengYinghao on 11/16/15.
//
//

#import <Foundation/Foundation.h>
/**
 @brief 请求返回结果类，返回的字段基本满足开发需求
 */
@interface BaseResponse : NSObject

@property (nonatomic, copy, readonly) NSString *requestURL; //请求的网址
@property (nonatomic, strong, readonly) NSURLRequest *readonlyRequest;//请求的NSURLRequest型对象
@property (nonatomic, strong, readonly) NSHTTPURLResponse *readonlyResponse;//返回的NSHTTPURLResponse型对象
@property (nonatomic, copy, readonly) NSDictionary *requestParams;//请求参数
@property (nonatomic, copy, readonly) NSString *HTTPMethod;//请求的方式
@property (nonatomic, assign, readonly) NSInteger HTTPStatusCode;//返回码
@property (nonatomic, strong, readonly) NSError *responseError;//返回错误，如果为正确返回,则为nil
@property (nonatomic, copy, readonly) NSString *responseString;//返回字符串表达形式（不可表达时为nil）
@property (nonatomic, strong, readonly) id responseJSONObject;//返回JSON对象表达形式（不可表达时为nil）
@property (nonatomic, strong, readonly) id responseImageObject;//返回Image对象表达形式（不可表达时为nil）
@property (nonatomic, strong, readonly) id responseXMLObject;//返回XML对象表达形式（不可表达时为nil）
@property (nonatomic, strong, readonly) id responseData;//返回的NSData对象表达形式（不可表达时为nil）

/**
 @brief 如下方法都为组装返回结果，对使用者透明，一般使用者不需要调用如下方法
 */
- (id)initWithURLString:(NSString *)aURLString
                 params:(NSDictionary *)params
             httpMethod:(NSString *)method;

- (void)setResponseString:(NSString *)responseString;
- (void)setResponseJSONObject:(id)responseJSONObject;
- (void)setResponseImageObject:(id)responseImageObject;
- (void)setResponseXMLObject:(id)responseXMLObject;
- (void)setResponseData:(id)responseData;
- (void)setHTTPStatusCode:(NSInteger)HTTPStatusCode;
- (void)setReadonlyRequest:(NSURLRequest *)readonlyRequest;
- (void)setReadonlyResponse:(NSHTTPURLResponse *)readonlyResponse;
- (void)setResponseError:(NSError *)responseError;

@end

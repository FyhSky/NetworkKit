//
//  BaseRequest.h
//  
//
//  Created by FengYinghao on 11/16/15.
//
//

#import <Foundation/Foundation.h>

@class BaseRequest;

/**
  @brief 网络请求类的协议
 */
@protocol BaseRequestDelegate <NSObject>

- (void)baseRequestComplete:(BaseRequest*)request;

@end



/**
 @brief 网络请求类
 */
@class BaseResponse;
@class AFHTTPRequestOperation;

/**
 @brief 正常返回回调

 @param BaseResponse 网络请求响应结果
 */
typedef void (^ResponseBlock)(BaseResponse *);

/**
 @brief 错误返回回调

 @param BaseResponse 网络请求响应结果
 @param NSError      错误对象
 */
typedef void (^ResponseErrorBlock)(BaseResponse * , NSError*);
@interface BaseRequest : NSObject

@property (nonatomic,assign) id<BaseRequestDelegate>delegate;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t completionQueue;
#else
@property (nonatomic, assign) dispatch_queue_t completionQueue;
#endif

@property (nonatomic,copy,readonly) NSString *urlString;

/**
 @brief 网络请求响应初始化方法

 @param aURLString 请求的网址
 @param params     请求的参数
 @param method     请求方式

 @return 网络请求的实例对象
 */
- (id)initWithURLString:(NSString *)aURLString
                 params:(NSDictionary *)params
             httpMethod:(NSString *)method;

/**
 @brief 添加网络请求的头字段

 @param headersDictionary 头字段字典
 */
- (void)addHeaders:(NSDictionary*)headersDictionary;

/**
 @brief 设置网络请求超时时间，不设置时默认为60妙

 @param timeoutInterval 超时时间
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 @brief 设置请求结果回调

 @param response 正常返回回调
 @param error    错误返回回调
 */
- (void)addCompletionHandler:(ResponseBlock)response
                errorHandler:(ResponseErrorBlock)error;


/**
 @brief 异步请求
 */
- (void)startAsync;

/**
 @brief 同步请求

 @param response 返回结果
 @param error    错误对象

 @return 网络请求的实例对象
 */
- (id)startSync:(BaseResponse **)response
          error:(NSError**)error;

/**
 @brief 取消该次网络请求（当且仅当该请求在未执行队列中时才有效）
 */
- (void)cancel;



@end

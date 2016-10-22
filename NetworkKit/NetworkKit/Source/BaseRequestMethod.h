//
//  BaseRequestMethod.h
//  
//
//  Created by FengYinghao on 11/18/15.
//
//

#import <Foundation/Foundation.h>
@class BaseResponse;


/**
 @brief 网络请求的协议，该协议基本包含了常用的请求，如果实现不同的调用方式，需要实现该方法，具有如下功能：
 1、支持同步与异步请求
 2、支持GET、POST方式请求
 3、支持设置超时时间，头字段等额外的请求参数
 4、支持设置请求的线程以及返回结果的线程
 5、支持取消操作
 
 */
@protocol BaseRequestMethod <NSObject>

/*
 async method:
 return url request task key, use this key to cancel task
 */

- (NSString *)asyncPost:(NSString *)URLString
             parameters:(id)parameters
                  queue:(dispatch_queue_t)queue
                success:(void (^)(BaseResponse *response))success
                failure:(void (^)(BaseResponse *response, NSError *error))failure;

- (NSString *)asyncGet:(NSString *)URLString
            parameters:(id)parameters
                 queue:(dispatch_queue_t)queue
               success:(void (^)(BaseResponse *response))success
               failure:(void (^)(BaseResponse *response, NSError *error))failure;


- (NSString *)asyncPost:(NSString *)URLString
             parameters:(id)parameters
                headers:(id)heards
                  queue:(dispatch_queue_t)queue
                success:(void (^)(BaseResponse *response))success
                failure:(void (^)(BaseResponse *response, NSError *error))failure;

- (NSString *)asyncGet:(NSString *)URLString
            parameters:(id)parameters
               headers:(id)heards
                 queue:(dispatch_queue_t)queue
               success:(void (^)(BaseResponse *response))success
               failure:(void (^)(BaseResponse *response, NSError *error))failure;

- (NSString *)asyncPost:(NSString *)URLString
             parameters:(id)parameters
                headers:(id)heards
                timeout:(NSTimeInterval)timeoutInterval
                  queue:(dispatch_queue_t)queue
                success:(void (^)(BaseResponse *response))success
                failure:(void (^)(BaseResponse *response, NSError *error))failure;

- (NSString *)asyncGet:(NSString *)URLString
            parameters:(id)parameters
               headers:(id)heards
               timeout:(NSTimeInterval)timeoutInterval
                 queue:(dispatch_queue_t)queue
               success:(void (^)(BaseResponse *response))success
               failure:(void (^)(BaseResponse *response, NSError *error))failure;



/**
 @brief 按创建的任务ID来取消请求
 
 @param taskKey 任务ID
 */
- (void)cancelRequest:(NSString*)taskKey;
/**
 @brief 按网址来取消请求
 
 @param urlString 网址
 */
- (void)cancelRequestUsingURL:(NSString*)urlString;
/**
 @brief 取消全部请求
 */
- (void)cancelAllRequests;


/*
 sync method
 
 */

- (id)syncPost:(NSString *)URLString
    parameters:(id)parameters
     response:(BaseResponse **)response
        error:(NSError **)error;

- (id)syncGet:(NSString *)URLString
   parameters:(id)parameters
     response:(BaseResponse **)response
        error:(NSError **)error;

- (id)syncPost:(NSString *)URLString
    parameters:(id)parameters
       timeout:(NSTimeInterval)timeoutInterval
      response:(BaseResponse **)response
         error:(NSError **)error;

- (id)syncGet:(NSString *)URLString
   parameters:(id)parameters
      timeout:(NSTimeInterval)timeoutInterval
     response:(BaseResponse **)response
        error:(NSError **)error;

@end

//
//  BaseRequestManager.m
//  
//
//  Created by FengYinghao on 11/18/15.
//
//

#import "BaseRequestManager.h"
#import "BaseRequest.h"
#import "BaseResponse.h"

@interface BaseRequestManager()<BaseRequestDelegate>

@property (nonatomic,strong,readwrite) NSMutableDictionary *requestRecords;
@property (nonatomic,retain) dispatch_queue_t queue;

@end

@implementation BaseRequestManager

- (id)init {
    self = [super init];
    if (self) {
        _requestRecords = [[NSMutableDictionary alloc]init];
        _queue = dispatch_queue_create("com.iqiyi.BaseRequestManager.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSString *)addRequest:(BaseRequest *)request {
    request.delegate = self;
    NSString *key =[self addOperation:request];
    [request startAsync];
    return key;
}

- (NSString *)requestHashKey:(BaseRequest *)request {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[request hash]];
    return key;
}

- (NSString *)addOperation:(BaseRequest *)request {
    if (request != nil) {
        NSString *key = [self requestHashKey:request];
        dispatch_async(_queue, ^{
            _requestRecords[key] = request;
        });
        return key;
    }
    
    return nil;
}

- (void)removeOperation:(BaseRequest *)request {
    NSString *key = [self requestHashKey:request];
    dispatch_async(_queue, ^{
         [_requestRecords removeObjectForKey:key];
    });
}

- (void)cancelRequest:(NSString*)taskKey {
     dispatch_async(_queue, ^{
         if ( taskKey && _requestRecords && _requestRecords[taskKey]) {
             BaseRequest *request = (BaseRequest *)_requestRecords[taskKey];
             [request cancel];
             [_requestRecords removeObjectForKey:taskKey];
         }
          });
    
}

- (void)cancelRequestUsingURL:(NSString*)urlString {
     dispatch_async(_queue, ^{
         if (urlString) {
             [_requestRecords enumerateKeysAndObjectsUsingBlock:^(id   key, id   obj, BOOL *stop) {
                 BaseRequest *request = (BaseRequest*)obj;
                 if ([request.urlString rangeOfString:urlString].location != NSNotFound) {
                     [request cancel];
                     [_requestRecords removeObjectForKey:key];
                 }
             }];
         }
     });
}

- (void)cancelAllRequests {
    dispatch_async(_queue, ^{
        [_requestRecords enumerateKeysAndObjectsUsingBlock:^(id   key, id   obj, BOOL *stop) {
            BaseRequest *request = (BaseRequest *)obj;
            if (request) {
                [request cancel];
            }
        }];
        
        [_requestRecords removeAllObjects];
    });

}

#pragma mark - async request method

- (NSString *)asyncPost:(NSString *)URLString
            parameters:(id)parameters
                queue:(dispatch_queue_t)queue
            success:(void (^)(BaseResponse *response))success
            failure:(void (^)(BaseResponse *response, NSError *error))failure {
    return [self asyncPost:URLString
                parameters:parameters
                   headers:nil
                     queue:queue
                   success:success
                   failure:failure];
}

- (NSString *)asyncGet:(NSString *)URLString
            parameters:(id)parameters
                 queue:(dispatch_queue_t)queue
               success:(void (^)(BaseResponse *response))success
               failure:(void (^)(BaseResponse *response, NSError *error))failure {
    return [self asyncGet:URLString
               parameters:parameters
                  headers:nil
                    queue:queue
                  success:success
                  failure:failure];
}

- (NSString *)asyncPost:(NSString *)URLString
             parameters:(id)parameters
                headers:(id)heards
                  queue:(dispatch_queue_t)queue
                success:(void (^)(BaseResponse *response))success
                failure:(void (^)(BaseResponse *response, NSError *error))failure {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"POST"];
    [request addCompletionHandler:success
                     errorHandler:failure];
    [request addHeaders:heards];
    [request setCompletionQueue:queue];
    NSString *key = [self addRequest:request];
    return key;
}

- (NSString *)asyncGet:(NSString *)URLString
            parameters:(id)parameters
               headers:(id)heards
                 queue:(dispatch_queue_t)queue
               success:(void (^)(BaseResponse *response))success
               failure:(void (^)(BaseResponse *response, NSError *error))failure {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"GET"];
    [request addCompletionHandler:success
                     errorHandler:failure];
    [request addHeaders:heards];
    [request setCompletionQueue:queue];
    NSString *key = [self addRequest:request];
    return key;
}

- (NSString *)asyncPost:(NSString *)URLString
             parameters:(id)parameters
                headers:(id)heards
                timeout:(NSTimeInterval)timeoutInterval
                  queue:(dispatch_queue_t)queue
                success:(void (^)(BaseResponse *response))success
                failure:(void (^)(BaseResponse *response, NSError *error))failure {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"POST"];
    [request addCompletionHandler:success
                     errorHandler:failure];
    [request addHeaders:heards];
    [request setTimeoutInterval:timeoutInterval];
    [request setCompletionQueue:queue];
    
    NSString *key = [self addRequest:request];
    return key;
}

- (NSString *)asyncGet:(NSString *)URLString
            parameters:(id)parameters
               headers:(id)heards
               timeout:(NSTimeInterval)timeoutInterval
                 queue:(dispatch_queue_t)queue
               success:(void (^)(BaseResponse *response))success
               failure:(void (^)(BaseResponse *response, NSError *error))failure {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"GET"];
    [request addCompletionHandler:success
                     errorHandler:failure];
    [request addHeaders:heards];
    [request setTimeoutInterval:timeoutInterval];
    [request setCompletionQueue:queue];
    
    NSString *key = [self addRequest:request];
    return key;
}

#pragma mark - sync request method
- (id)syncPost:(NSString *)URLString
    parameters:(id)parameters
      response:(BaseResponse **)response
         error:(NSError **)error {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"POST"];
    
    return [request startSync:response
                        error:error];
    
    
    
}

- (id)syncGet:(NSString *)URLString
   parameters:(id)parameters
     response:(BaseResponse **)response
        error:(NSError **)error {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"GET"];
    return [request startSync:response
                        error:error];
    
}

- (id)syncPost:(NSString *)URLString
    parameters:(id)parameters
       timeout:(NSTimeInterval)timeoutInterval
      response:(BaseResponse **)response
         error:(NSError **)error {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"POST"];
    [request setTimeoutInterval:timeoutInterval];
    return [request startSync:response
                        error:error];
}

- (id)syncGet:(NSString *)URLString
   parameters:(id)parameters
      timeout:(NSTimeInterval)timeoutInterval
     response:(BaseResponse **)response
        error:(NSError **)error {
    BaseRequest *request = [[BaseRequest alloc]initWithURLString:URLString
                                                          params:parameters
                                                      httpMethod:@"GET"];
    [request setTimeoutInterval:timeoutInterval];
    return [request startSync:response
                        error:error];
}

#pragma mark - BaseRequestDelegate
- (void)baseRequestComplete:(BaseRequest*)request {
    [self removeOperation:request];
}

@end

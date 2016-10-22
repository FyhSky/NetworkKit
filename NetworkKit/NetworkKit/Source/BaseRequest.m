//
//  BaseRequest.m
//  
//
//  Created by FengYinghao on 11/16/15.
//
//

#import "BaseRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHTTPRequestOperationManager+Synchronous.h"
#import "BaseResponse.h"
#import <objc/runtime.h>


static dispatch_queue_t http_request_operation_processing_queue() {
    static dispatch_queue_t af_http_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_http_request_operation_processing_queue = dispatch_queue_create("com.baserequest.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return af_http_request_operation_processing_queue;
}

@interface HTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (instancetype)sharedInstance;

@end

@implementation HTTPRequestOperationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HTTPRequestOperationManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [HTTPRequestOperationManager manager];
        [sharedInstance.operationQueue setMaxConcurrentOperationCount:6];
        [sharedInstance setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        
        /*!
         *  @brief 允许无效的https证书，虽然这样不太安全，解决用户登录失败问题。
         */
        sharedInstance.securityPolicy.allowInvalidCertificates = YES;
        sharedInstance.securityPolicy.validatesDomainName = NO;
    });
    return sharedInstance;
}

@end

static NSLock* staticLock() {
    static NSLock *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[NSLock alloc] init];
    });
    
    return lock;
}

@interface BaseRequest()

@property (nonatomic,strong) HTTPRequestOperationManager *operationManager;
@property (nonatomic,strong) AFHTTPRequestOperation *requestOperation;

@property (nonatomic,strong) NSMutableArray *responseBlocks;
@property (nonatomic,strong) NSMutableArray *errorBlocks;


@property (nonatomic,copy,readwrite) NSString *urlString;
@property (nonatomic,copy) NSString *httpMethod;
@property (nonatomic,retain) NSDictionary *parameters;
@property (nonatomic,retain) NSDictionary *headersDictionary;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;

@property (nonatomic,retain) Class originalClass;//存储代理的类，用于处理返回结果时，因为代理被释放而崩溃

@end

@implementation BaseRequest

- (id)initWithURLString:(NSString *)aURLString
                 params:(NSDictionary *)parameters
             httpMethod:(NSString *)method {
    if((self = [super init])) {
        _responseBlocks = [NSMutableArray array];
        _errorBlocks = [NSMutableArray array];
        _httpMethod = method;
        _parameters = [parameters copy];
        _urlString = aURLString;
        _operationManager = [HTTPRequestOperationManager sharedInstance];
        _timeoutInterval = 60;
    }
    return self;
}

- (void)setDelegate:(id<BaseRequestDelegate>)delegate {
    _delegate = delegate;
    _originalClass = object_getClass(_delegate);
}

- (void)addHeaders:(NSDictionary*)headersDictionary {
    _headersDictionary = [headersDictionary copy];
}
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    _timeoutInterval = timeoutInterval;
}

- (void)addCompletionHandler:(ResponseBlock)response
                errorHandler:(ResponseErrorBlock)error {
    if(response)
        [_responseBlocks addObject:[response copy]];
    if(error)
        [_errorBlocks addObject:[error copy]];
}

/**
 @brief 组装请求
 */
- (void)prepareExtendValue {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    if (_headersDictionary && _headersDictionary.count) {
        [_headersDictionary enumerateKeysAndObjectsUsingBlock:^(id   key, id   obj, BOOL *stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    [requestSerializer setTimeoutInterval:_timeoutInterval];

    [_operationManager setRequestSerializer:requestSerializer];
}

/**
 @brief 开始请求
 */
- (void)requestAction {
    if ([_httpMethod isEqualToString:@"GET"]) {
        self.requestOperation = [_operationManager GET:self.urlString
                                            parameters:self.parameters
                                               success:^(AFHTTPRequestOperation *operation, id  responseObject) {
                                                   [self handleRequestResult:operation
                                                              responseObject:responseObject];
                                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (operation.responseData) {
                                                       [self handleRequestResult:operation
                                                                  responseObject:operation.responseObject];
                                                   } else {
                                                       [self handleRequestResult:operation
                                                                           error:error];
                                                   }
                                                   
                                               }];
        
    } else if ([_httpMethod isEqualToString:@"POST"]) {
        self.requestOperation = [_operationManager POST:self.urlString
                                             parameters:self.parameters
                                                success:^(AFHTTPRequestOperation *operation, id  responseObject) {
                                                    [self handleRequestResult:operation
                                                               responseObject:responseObject];
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    if (operation.responseData) {
                                                        [self handleRequestResult:operation
                                                                   responseObject:operation.responseObject];
                                                    } else {
                                                        [self handleRequestResult:operation
                                                                            error:error];
                                                    }
                                                }];
        
    }
}

- (void)startAsync {
    //sync to fix  _requestSerializer = requestSerializer crash in multiple thread
    [staticLock() lock];
    [self prepareExtendValue];
    [self requestAction];
    [staticLock() unlock];
}

- (id)startSync:(BaseResponse **)response
          error:(NSError**)error {
    
    AFHTTPRequestOperation *operation;
    if ([_httpMethod isEqualToString:@"GET"]) {
       
     [_operationManager syncGET:self.urlString
                     parameters:self.parameters
                        timeout:_timeoutInterval
                      operation:&operation
                          error:error];
        
    } else if ([_httpMethod isEqualToString:@"POST"]) {
       [_operationManager syncPOST:self.urlString
                        parameters:self.parameters
                           timeout:_timeoutInterval
                         operation:&operation
                             error:error];
        
    }
    
    if (operation.responseData && error != nil) {
        *error = nil;
    }
    
    if (response != nil) {
        *response = [self assembleResponse:operation
                                     error:*error];
    }
   
    
    return [operation.responseData copy];
}

- (void)cancel {
    if (self.requestOperation) {
        [self.requestOperation cancel];
    }
    
}

/**
@brief 处理请求错误返回结果
 */
- (void)handleRequestResult:(AFHTTPRequestOperation *)operation
                      error:(NSError*)error {
    AFHTTPRequestOperation *op = operation;
    dispatch_async(http_request_operation_processing_queue(), ^{
        BaseResponse *response = [self assembleResponse:op error:error];
        __weak BaseRequest *weakSelf = self;
        dispatch_async(weakSelf.completionQueue ? weakSelf.completionQueue : dispatch_get_main_queue(), ^{
            if (weakSelf.errorBlocks) {
                for(ResponseErrorBlock errorBlock in weakSelf.errorBlocks) {
                    errorBlock(response, error);
                }
            }
            Class currentClass = object_getClass(weakSelf.delegate);
            if (currentClass == weakSelf.originalClass && [weakSelf.delegate respondsToSelector:@selector(baseRequestComplete:)]) {
                [weakSelf.delegate baseRequestComplete:weakSelf];
            }
        });
    });
}

/**
 @brief 处理请求正确返回结果
 */
- (void)handleRequestResult:(AFHTTPRequestOperation *)operation
             responseObject:(id)responseObject {
    AFHTTPRequestOperation *op = operation;
    dispatch_async(http_request_operation_processing_queue(), ^{
        BaseResponse *response = [self assembleResponse:op error:nil];
        __weak BaseRequest *weakSelf = self;
        dispatch_async(weakSelf.completionQueue ? weakSelf.completionQueue :dispatch_get_main_queue(),
                       ^{
            if (weakSelf.responseBlocks) {
                for(ResponseBlock responseBlock in weakSelf.responseBlocks) {
                    responseBlock(response);
                }
                Class currentClass = object_getClass(weakSelf.delegate);
                if (currentClass == weakSelf.originalClass && [weakSelf.delegate respondsToSelector:@selector(baseRequestComplete:)]) {
                    [weakSelf.delegate baseRequestComplete:weakSelf];
                }
            }
        });
    });
}
/**
 @brief 组装返回结果
 */
- (BaseResponse *)assembleResponse:(AFHTTPRequestOperation *)operation
                             error:(NSError*)error {
    BaseResponse *response = [[BaseResponse alloc]initWithURLString:self.urlString
                                                             params:self.parameters
                                                         httpMethod:self.httpMethod];
    
    if (error == nil) {
        AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;
        id responseJSONObject;
        id responseImageObject;
        id responseXMLObject;
        if (operation && operation.responseData) {
            responseJSONObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                 options:NSJSONReadingMutableLeaves
                                                                   error:nil];
        }
        
        responseSerializer = [AFXMLParserResponseSerializer serializer];
        responseXMLObject = [responseSerializer responseObjectForResponse:operation.response
                                                                     data:operation.responseData
                                                                    error:nil];
        responseSerializer = [AFImageResponseSerializer serializer];
        responseImageObject = [responseSerializer responseObjectForResponse:operation.response
                                                                       data:operation.responseData
                                                                      error:nil];

        [response setResponseJSONObject:responseJSONObject];
        [response setResponseXMLObject:responseXMLObject];
        [response setResponseImageObject:responseImageObject];
        
    }
    
    
    [response setHTTPStatusCode:operation.response.statusCode];
    [response setResponseData:[operation.responseData copy]];
    [response setResponseString:[operation.responseString copy]];
    [response setReadonlyRequest:[operation.request copy]];
    [response setReadonlyResponse:[operation.response copy]];
    
    return response;
}

@end

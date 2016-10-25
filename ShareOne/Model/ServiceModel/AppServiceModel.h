
#import <Foundation/Foundation.h>
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "AFNetworkReachabilityManager.h"
#import "Services.h"

@interface AppServiceModel : AFHTTPSessionManager <MBProgressHUDDelegate>{

    MBProgressHUD *progressHud;
}

+ (AppServiceModel *)sharedClient;

- (void) showProgressWithMessage:(NSString *)message;

- (void) hideProgressAlert;

-(id)getParseData:(NSDictionary*)responseObject delegate:(id)delegate;

-(id)getParseDataForUserModule:(NSDictionary*)responseObject;

- (void) postRequestWithParameters:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock;

- (void)postImageRequestWithParameters:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock;


-(void)postRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock;

-(void)putRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock;

-(void)getMethod:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock;

-(void)deleteRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock;


-(void)createBatchOfRequestsWithObject:(NSArray *)reqObjects requestCompletionBlock:(void(^)(NSObject *response,NSURLResponse *responseObj))reqBlock requestFailureBlock:(void(^)(NSError* error))failReqBlock queueCompletionBlock:(void(^)(BOOL sucess))queueBlock queueFailureBlock:(void(^)(NSError* error))failQueueBlock;

-(void)concurrentBatchOfRequestOperations:(NSArray *)operations progressBlock:(void (^)(NSUInteger, NSUInteger))progressBlock completionBlock:(void (^)(NSArray *))completionBlock;

@end


#import "AppServiceModel.h"
#import "SignInModel.h"
#import "Services.h"
#import "UtilitiesHelper.h"
#import "Constants.h"

@implementation AppServiceModel

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (AppServiceModel *)sharedClient {
    static AppServiceModel *_serviceClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClient = [[AppServiceModel alloc] initWithBaseURL:[NSURL URLWithString:KWEB_SERVICE_BASE_URL]];
        [[AFNetworkReachabilityManager sharedManager]startMonitoring];

    });
    
    return _serviceClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
//    self.responseSerializer=[AFJSONResponseSerializer serializer];
    
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"application/x-www-form-urlencoded", nil];

    

    
//    NSOperationQueue *operationQueue = self.operationQueue;
    
//    __block UIImageView*  noInternetImageView=[[UIImageView alloc] init];

    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSLog(@"Internet Working");
//            [noInternetImageView removeFromSuperview];
        }else{
//            UIWindow* window=[[[UIApplication sharedApplication]delegate]window];
//            [noInternetImageView setFrame:window.frame];
//            [noInternetImageView setImage:[UIImage imageNamed:@"internet_connection_error_screen"]];
//            [window addSubview:noInternetImageView];
//            [[UtilitiesHelper shareUtitlities]showAlertWithMessage:@"You are connected to internet!" title:@"" delegate:window.rootViewController.childViewControllers.lastObject];
            NSLog(@"Internet Not Working");

            }

//                switch (status) {
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//                NSLog(@"The internet is working via WWAN.");
//                break;
//                
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//                [operationQueue setSuspended:NO];
//                NSLog(@"The internet is working via WIFI.");
//                break;
//                
//            case AFNetworkReachabilityStatusNotReachable:
//                NSLog(@"No Network Connection! Please enable your internet");
//                break;
//                
//            default:
//                [operationQueue setSuspended:YES];
//                break;
//        }
    }];
    
    return self;
    
}

# pragma mark - Show Progress

-(void) showProgressWithMessage:(NSString *)message
{
    if(progressHud)
    {
        // only show hud
    }
    else{
        //progressHud=nil;
        
        UIWindow *window=[[[UIApplication sharedApplication]delegate]window];
        progressHud=[[MBProgressHUD alloc]initWithView:[window.subviews lastObject]];
//        progressHud.mode=MBProgressHUDModeAnnularDeterminate;
        [window addSubview:progressHud];
    }
    [progressHud show:NO];
    [progressHud setLabelText:message];
}


-(void) hideProgressAlert{
    [progressHud hide:NO];
    progressHud=nil;
}



-(id)getParseData:(NSDictionary*)responseObject delegate:(id)delegate{
    
    NSNumber *responseTYpe=[NSNumber numberWithBool:[[responseObject objectForKey:@"status"]boolValue]];
    if(responseTYpe)
    {
        NSDictionary *resultDictionary=[responseObject objectForKey:@"data"];
        if([responseTYpe boolValue])
        {
            NSLog(@"%@",resultDictionary);
            return  resultDictionary;
        }
        else {
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:[responseObject objectForKey:@"message"] title:@"" delegate:delegate];

//            [[[UIAlertView alloc]initWithTitle:@"Error" message:[responseObject objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            
            [self hideProgressAlert];
        }
    }
    return nil;
}

-(id)getParseDataForUserModule:(NSDictionary*)responseObject{
    NSNumber *responseTYpe=[NSNumber numberWithBool:[[responseObject objectForKey:@"status"]boolValue]];
    if(responseTYpe)
    {
        NSArray *resultArr=[responseObject objectForKey:@"data"];
        if([responseTYpe boolValue])
        {
            return  resultArr;
        }
        else {
            return nil;
        }
    }
    return nil;
}

- (void)postRequestWithParameters:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    [self POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self hideProgressAlert];
        block(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self hideProgressAlert];
//#ifdef DEBUG
//        
//        [[UtilitiesHelper shareUtitlities]showAlertWithMessage:error.description title:@"" delegate:delegate];
//        
//#else
//        
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Server Not Responding, please try again later!" title:@"" delegate:delegate];
        
//#endif
        
    }];
    
}

-(void)postRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_POST URLString:urlString parameters:params error:nil];
    
    if(auth_header)
        [self setHeaderOnRequest:req withAuth:auth_header];
    
    
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                block(responseObject);
                
            }
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];
            
        }
    }] resume];

    
    
    
}


-(void)putRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];

    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_PUT URLString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,KWEB_SERVICE_MEMBER_VALIDATE] parameters:nil error:nil];
    
    [self setHeaderOnRequest:req withAuth:auth_header];
    
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                block(responseObject);

            }
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];

        }
    }] resume];
}




-(void)getMethod:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;

    if(progressMessage)
        [self showProgressWithMessage:progressMessage];

    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_GET URLString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,urlString,[params valueForKey:@"ContextID"]] parameters:nil error:nil];
    
    [self setHeaderOnRequest:req withAuth:auth_header];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                block(responseObject);

            }
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];

        }
    }] resume];
    
}

- (void)postImageRequestWithParameters:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    NSData* imageData = [[NSData alloc]init];
    NSString* imageName =@"image";
    imageData = [params objectForKey:@"image"];
    if([imageData length]==0){
        imageData = [params objectForKey:@"image_share"];
        imageName = @"image_share";
    }
    NSMutableDictionary* tmpDict = [NSMutableDictionary dictionaryWithDictionary:params];
    [tmpDict removeObjectForKey:@"image"];
    [tmpDict removeObjectForKey:@"image_share"];

    [self POST:urlString parameters:tmpDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if ([imageData length]>0)
            [formData appendPartWithFileData:imageData name:imageName fileName:@"image.png" mimeType:@"image/png"];

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progressHud.progress = uploadProgress.fractionCompleted;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self hideProgressAlert];
        block(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       [self hideProgressAlert];
//#ifdef DEBUG
//        
//        [[UtilitiesHelper shareUtitlities]showAlertWithMessage:error.description title:@"" delegate:delegate];
//        
//#else
        if(progressMessage)
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Server Not Responding, please try again later!" title:@"" delegate:delegate];
        
//#endif
      
        failBlock(error);
    }];
//    
//    [self POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        if ([imageData length]>0)
//            [formData appendPartWithFileData:imageData name:@"picture" fileName:@"picture.png" mimeType:@"image/png"];
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//         
//         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//         [self hideProgressAlert];
//         block(responseObject);
//         
//         
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//         NSLog(@"Error: %@", error.localizedDescription);
//         NSLog(@"Service:%@ & Error: %@",operation.request, operation.responseString);
//         
//         [self hideProgressAlert];
//         [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Server Not Responding, please try again later!" title:@"" delegate:delegate];
//         
//         //         failBlock(error);
//     }];
    
}


-(void)setHeaderOnRequest:(NSMutableURLRequest *)request withAuth:(NSString *)auth{
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"en,en-gb;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"UTF-8;q=0.7,*;q=0.7" forHTTPHeaderField:@"Accept-Charset"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [request setValue:@"no-store, no-cache, must-revalidate, pre-check=0, post-check=0, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"Sat, 1 Jan 2020 00:00:00 GMT" forHTTPHeaderField:@"Expires"];
    [request setValue:H_MAC_TYPE forHTTPHeaderField:@"HmacType"];
    [request setValue:SECURITY_VERSION forHTTPHeaderField:@"SecurityVersion"];
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
}


-(NSMutableSet *)getAcceptableContentTypesWithSerializer:(AFJSONResponseSerializer *)jsonResponseSerializer{
    
    NSMutableSet *acceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
    [acceptableContentTypes addObject:@"text/html"];
    [acceptableContentTypes addObject:@"text/xml"];
    [acceptableContentTypes addObject:@"application/json"];
    return acceptableContentTypes;

}
-(void)oldCodeTologin{
    /*
     
     [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
     [self.requestSerializer setValue:@"en,en-gb;q=0.5" forHTTPHeaderField:@"Accept-Language"];
     [self.requestSerializer setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
     [self.requestSerializer setValue:@"UTF-8;q=0.7,*;q=0.7" forHTTPHeaderField:@"Accept-Charset"];
     [self.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
     [self.requestSerializer setValue:@"no-store, no-cache, must-revalidate, pre-check=0, post-check=0, max-age=0" forHTTPHeaderField:@"Cache-Control"];
     [self.requestSerializer setValue:@"Sat, 1 Jan 2020 00:00:00 GMT" forHTTPHeaderField:@"Expires"];
     [self.requestSerializer setValue:H_MAC_TYPE forHTTPHeaderField:@"HmacType"];
     [self.requestSerializer setValue:SECURITY_VERSION forHTTPHeaderField:@"SecurityVersion"];
     [self.requestSerializer setValue:auth_header forHTTPHeaderField:@"Authorization"];
     
     // Customizing serialization. Be careful, not work without parametersDictionary
     [self.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *params, NSError *__autoreleasing *error) {
     
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
     NSString *paremJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     return paremJsonString;
     }];
     
     
     if(progressMessage)
     [self showProgressWithMessage:progressMessage];
     
     
     [self PUT:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     
     NSLog(@"success : %@",responseObject);
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     [self hideProgressAlert];
     block(responseObject);
     
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     
     NSLog(@"error : %@ code: %d",[error localizedDescription],[error code]);
     
     //        NSMutableDictionary *userInfo = [(error).userInfo mutableCopy];
     //        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
     //            NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
     //            NSLog(@"%@" ,[r allHeaderFields]);
     //        }
     
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     
     
     NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
     NSLog(@"%@",ErrorResponse);
     
     [self hideProgressAlert];
     [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];
     
     }];
     */

}
@end

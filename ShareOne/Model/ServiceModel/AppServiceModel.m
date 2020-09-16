
#import "AppServiceModel.h"
#import "Services.h"
#import "UtilitiesHelper.h"
#import "ConstantsShareOne.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "HTTPRequestOperation.h"



@implementation AppServiceModel

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (AppServiceModel *)sharedClient {
    static AppServiceModel *_serviceClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _serviceClient = [[AppServiceModel alloc] initWithBaseURL:[NSURL URLWithString:[ShareOneUtility getBaseUrl]]];
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
//            NSLog(@"Internet Working");
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
    [progressHud showAnimated:NO];
//    [progressHud setLabelText:message];
    
    
    progressHud.label.text=message;
}


-(void) hideProgressAlert{
    [progressHud hideAnimated:NO];
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
    
    [self POST:urlString parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
               [self hideProgressAlert];
               block(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [self hideProgressAlert];
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Server Not Responding, please try again later!" title:@"" delegate:delegate];
    }];
    
//    [self POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [self hideProgressAlert];
//        block(responseObject);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [self hideProgressAlert];
////#ifdef DEBUG
////
////        [[UtilitiesHelper shareUtitlities]showAlertWithMessage:error.description title:@"" delegate:delegate];
////
////#else
////
//        [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Server Not Responding, please try again later!" title:@"" delegate:delegate];
//
////#endif
//
//    }];
    
}

-(void)postRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_POST URLString:urlString parameters:nil error:nil];
    [self setTimeOutIntervalOnRequest:req];

    if(params){
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
        jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
        manager.responseSerializer = jsonResponseSerializer;
    
    
    // if it is own server call than header must be in the request
    if(auth_header){
        [self setHeaderOnRequest:req withAuth:auth_header];
        
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
    }
    else{
        // Third party server call by handling xml request
        
        NSString *boundary = [ShareOneUtility generateBoundaryString];
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [req setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        
        // create body
        NSData *httpBody = [ShareOneUtility createBodyWithBoundary:boundary parameters:params];
        [req setHTTPBody:httpBody];
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer = responseSerializer;
        
    }
    
    [[manager dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                [self endSession:manager.session];
                block(responseObject);
                
            }
            
        } else {
            
            NSLog(@"Error : %@",[error localizedDescription]);
            NSLog(@"Error : %@",error );
            
            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
            //NSLog(@"Headers : %@",headers);
            
            NSString *errorString = [headers valueForKey:@"ApiResponse"];
            
            NSString *customError = [self parseErrorObject:errorString];
            
            if(!customError)
                customError = [self getLocalizeErrorMessageForInternetConnection:error];
            
            [self hideProgressAlert];
            
            if(![req.URL.absoluteString containsString:KWEB_SERVICE_LOGIN]){
                [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
            }
            
            if([req.URL.absoluteString containsString:KMEMBER_DEVICES]){
                [self endSession:manager.session];
                failBlock(error);
            }
            
            if([req.URL.absoluteString containsString:KWEB_SERVICE_LOGIN]){
                [self endSession:manager.session];
                block(errorString);
            }
        }
    }]resume];
    
    
//    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//
//        if (!error) {
//            NSLog(@"Reply JSON: %@", responseObject);
//
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                [self hideProgressAlert];
//                [self endSession:manager.session];
//                block(responseObject);
//
//            }
//
//        } else {
//
//            NSLog(@"Error : %@",[error localizedDescription]);
//            NSLog(@"Error : %@",error );
//
//            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
//            //NSLog(@"Headers : %@",headers);
//
//            NSString *errorString = [headers valueForKey:@"ApiResponse"];
//
//            NSString *customError = [self parseErrorObject:errorString];
//
//            if(!customError)
//                customError = [self getLocalizeErrorMessageForInternetConnection:error];
//
//            [self hideProgressAlert];
//
//            if(![req.URL.absoluteString containsString:KWEB_SERVICE_LOGIN]){
//                [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
//            }
//
//            if([req.URL.absoluteString containsString:KMEMBER_DEVICES]){
//                [self endSession:manager.session];
//                failBlock(error);
//            }
//
//            if([req.URL.absoluteString containsString:KWEB_SERVICE_LOGIN]){
//                [self endSession:manager.session];
//                block(errorString);
//            }
//        }
//    }] resume];
    
}
-(void)postRequestForConfigAPIWithParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:urlString parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self endSession:manager.session];
        block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self hideProgressAlert];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self endSession:manager.session];
        block(nil);
        
        NSLog(@"%@",error);
    }];
    
//    [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"%@",responseObject);
//
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [self endSession:manager.session];
//        block(responseObject);
//    } failure:^(NSURLSessionDataTask  *task, NSError   *error) {
//        [self hideProgressAlert];
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [self endSession:manager.session];
//        block(nil);
//
//        NSLog(@"%@",error);
//    }];
}

-(void)getRequestForConfigAPIWithAuthHeader:(NSString *)header andProgressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];

    [manager.requestSerializer setValue:header forHTTPHeaderField:@"Authorization"];
    
    [manager GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        
        if([urlString containsString:CONFIG_CLIENT_APP]){
            [ShareOneUtility writeDataToPlistFileWithJSON:(NSDictionary *)responseObject AndFileName:[NSString stringWithFormat:@"%@.plist",CONFIG_CLIENT_APP]];
        }
        [self endSession:manager.session];
        
        block(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [self endSession:manager.session];
        
        failBlock(error);
    }];
    
//    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@",responseObject);
//
//        if([urlString containsString:CONFIG_CLIENT_APP]){
//            [ShareOneUtility writeDataToPlistFileWithJSON:(NSDictionary *)responseObject AndFileName:[NSString stringWithFormat:@"%@.plist",CONFIG_CLIENT_APP]];
//        }
//        [self endSession:manager.session];
//
//        block(responseObject);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//        [self endSession:manager.session];
//
//        failBlock(error);
//    }];
}

-(void)postRequestForSSOWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
        AFHTTPResponseSerializer *jsonResponseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_POST URLString:urlString parameters:nil error:nil];

    manager.responseSerializer = jsonResponseSerializer;
    
    if(params){
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    

    // if it is own server call than header must be in the request
    if(auth_header){
        [self setHeaderOnRequest:req withAuth:auth_header];
        
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
    }
    
    
    [manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
        
        NSLog(@"Redirect Response : %@", response);
        
        return request ;
    }];
    
    NSURLSessionDataTask *managerHttpRequest = [manager dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"Response: %@", responseObject);
        
        
        if(error){
            
            //            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            //            NSLog(@"SSO URL : %@",[error.userInfo valueForKey:@"NSErrorFailingURLKey"]);
            //            NSString *url =[error.userInfo valueForKey:@"NSErrorFailingURLKey"];
            
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            
            //            url = response.URL.absoluteString;
            
            //            block(url);
            block(req);
            
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        else {
            NSLog(@"error : %@", error.localizedDescription);
            NSLog(@"Response : %@", response);
        }
    }];
    
//    NSURLSessionDataTask *managerHttpRequest =  [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"Response: %@", responseObject);
//
//
//        if(error){
//
////            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
//
//            //            NSLog(@"SSO URL : %@",[error.userInfo valueForKey:@"NSErrorFailingURLKey"]);
////            NSString *url =[error.userInfo valueForKey:@"NSErrorFailingURLKey"];
//
//            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
//
////            url = response.URL.absoluteString;
//
////            block(url);
//            block(req);
//
//
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        }
//        else {
//            NSLog(@"error : %@", error.localizedDescription);
//            NSLog(@"Response : %@", response);
//        }
//    }];
    
    [managerHttpRequest resume];
    
}

-(NSMutableURLRequest *)getRequestForSSOWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFHTTPResponseSerializer *jsonResponseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_GET URLString:urlString parameters:params error:nil];
    [self setTimeOutIntervalOnRequest:req];

    
    // Setting Headers for Own servers
    if(auth_header){
        [self setHeaderOnRequest:req withAuth:auth_header];
    }
    
    return req;

}


-(void)postRequestForVertifiWithParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response,BOOL succes))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_POST URLString:[ShareOneUtility checkHTTPComponentInURL: urlString] parameters:nil error:nil];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    NSString *boundary = [ShareOneUtility generateBoundaryString];
        
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField: @"Content-Type"];
    //[req setValue:@"1.2" forHTTPHeaderField:@"SecurityVersion"];
    
    // create body
    NSData *httpBody = [ShareOneUtility createBodyWithBoundary:boundary parameters:params];
    [req setHTTPBody:httpBody];
    
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    manager.responseSerializer = responseSerializer;
    
    [[manager dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            [self endSession:manager.session];
            block(responseObject,TRUE);
            //            NSLog(@"Reply JSON: %@", responseObject);
            
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [self endSession:manager.session];
            block([self getLocalizeErrorMessageForInternetConnection:error],FALSE);
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            //[[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];
            
        }
    }]resume];
        
//    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//
//        if (!error) {
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            [self hideProgressAlert];
//            [self endSession:manager.session];
//            block(responseObject,TRUE);
////            NSLog(@"Reply JSON: %@", responseObject);
//
//        } else {
//            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
//            [self endSession:manager.session];
//            block([self getLocalizeErrorMessageForInternetConnection:error],FALSE);
//
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            [self hideProgressAlert];
//            //[[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];
//
//        }
//    }] resume];
}




-(void)putRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    
    NSLog(@"putRequestWithAuthHeader");
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    
   AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    
     manager.responseSerializer = jsonResponseSerializer;
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_PUT URLString:urlString parameters:nil error:nil];
    
    [req setTimeoutInterval:RESPONSE_TIME_OUT];

    if(auth_header)
        [self setHeaderOnRequest:req withAuth:auth_header];
    
    if(params){
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [[manager dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                [self endSession:manager.session];
                block(responseObject);
            }
        } else {
            
            //NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
            //NSLog(@"Headers : %@",headers);
            
            NSString *errorString = [headers valueForKey:@"ApiResponse"];
            
            NSString *customError = [self parseErrorObject:errorString];
            
            if(!customError)
                customError = [self getLocalizeErrorMessageForInternetConnection:error];
            
            if([req.URL.absoluteString containsString:KWEB_SERVICE_MEMBER_VALIDATE]){
                [self endSession:manager.session];
                block(nil);
            }
            
            [self hideProgressAlert];
            
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
        }
    }]resume];
    
//    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//
//        if (!error) {
//            NSLog(@"Reply JSON: %@", responseObject);
//
//
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                [self hideProgressAlert];
//                [self endSession:manager.session];
//                block(responseObject);
//            }
//        } else {
//
//            //NSLog(@"Error: %@, %@, %@", error, response, responseObject);
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
//            //NSLog(@"Headers : %@",headers);
//
//            NSString *errorString = [headers valueForKey:@"ApiResponse"];
//
//            NSString *customError = [self parseErrorObject:errorString];
//
//            if(!customError)
//                customError = [self getLocalizeErrorMessageForInternetConnection:error];
//
//            if([req.URL.absoluteString containsString:KWEB_SERVICE_MEMBER_VALIDATE]){
//                [self endSession:manager.session];
//                block(nil);
//            }
//
//            [self hideProgressAlert];
//
//            [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
//        }
//    }] resume];
    
    
}


-(void)getMethod:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_GET URLString:urlString parameters:params error:nil];
    [self setTimeOutIntervalOnRequest:req];
    
    
    // Setting Headers for Own servers
    if(auth_header){
        [self setHeaderOnRequest:req withAuth:auth_header];
    }
    else{
        NSLog(@"**************************************************");
        NSLog(@"|        It Is calling for location API           ");
        NSLog(@"**************************************************");
        [self setHeaderForLocationApiOnRequest:req];
    }
    NSLog(@"%@",req.URL.absoluteString);
    [[manager dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            
            if(auth_header)
                NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if(![req.URL.absoluteString containsString:KWEB_SERVICE_SIGN_OUT])
                    [self hideProgressAlert];
                [self endSession:manager.session];
                block(responseObject);
            }
            
            
        } else {
            
            
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            
            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
            //NSLog(@"Headers : %@",headers);
            
            NSString *errorString = [headers valueForKey:@"ApiResponse"];
            
            NSString *customError = [self parseErrorObject:errorString];
            
            if(!customError)
                customError = [self getLocalizeErrorMessageForInternetConnection:error];
            
            [self hideProgressAlert];
            
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
            
            
            if([req.URL.absoluteString containsString:kKEEP_ALIVE]){
                [self endSession:manager.session];
                block(responseObject);
            }
            
            
            if([req.URL.absoluteString containsString:KQUICK_BALANCES]){
                [self endSession:manager.session];
                failBlock(error);
            }
            
            if([req.URL.absoluteString containsString:KQUICK_TRANSACTION]){
                [self endSession:manager.session];
                failBlock(error);
            }
            
            if([req.URL.absoluteString containsString:KWEB_SERVICE_SIGN_OUT]){
                [self endSession:manager.session];
                block(responseObject);
            }
            
            
        }
    }]resume];
    
//    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * response, id   responseObject, NSError * _Nullable error) {
//
//        if (!error) {
//
//            if(auth_header)
//                NSLog(@"Reply JSON: %@", responseObject);
//
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                if(![req.URL.absoluteString containsString:KWEB_SERVICE_SIGN_OUT])
//                    [self hideProgressAlert];
//                [self endSession:manager.session];
//                block(responseObject);
//            }
//
//
//        } else {
//
//
//            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//
//
//            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
//            //NSLog(@"Headers : %@",headers);
//
//            NSString *errorString = [headers valueForKey:@"ApiResponse"];
//
//            NSString *customError = [self parseErrorObject:errorString];
//
//            if(!customError)
//                customError = [self getLocalizeErrorMessageForInternetConnection:error];
//
//            [self hideProgressAlert];
//
//            [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
//
//
//            if([req.URL.absoluteString containsString:kKEEP_ALIVE]){
//                [self endSession:manager.session];
//                block(responseObject);
//            }
//
//
//            if([req.URL.absoluteString containsString:KQUICK_BALANCES]){
//                [self endSession:manager.session];
//                failBlock(error);
//            }
//
//            if([req.URL.absoluteString containsString:KQUICK_TRANSACTION]){
//                [self endSession:manager.session];
//                failBlock(error);
//            }
//
//            if([req.URL.absoluteString containsString:KWEB_SERVICE_SIGN_OUT]){
//                [self endSession:manager.session];
//                block(responseObject);
//            }
//
//
//        }
//    }] resume];
    
    
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%lld",[response expectedContentLength]);
    dataToDownload=[[NSMutableData alloc]init];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [dataToDownload appendData:data];
    
}
-(void)deleteRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_DELETE URLString:urlString parameters:nil error:nil];
    [self setTimeOutIntervalOnRequest:req];

    if(auth_header)
        [self setHeaderOnRequest:req withAuth:auth_header];
    
    
    if(params){
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [[manager dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
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
            
            
            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
            //NSLog(@"Headers : %@",headers);
            
            NSString *errorString = [headers valueForKey:@"ApiResponse"];
            
            NSString *customError = [self parseErrorObject:errorString];
            
            if(!customError)
                customError = [self getLocalizeErrorMessageForInternetConnection:error];
            
            [self hideProgressAlert];
            
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
            failBlock(error);
            
        }
    }]resume];
//    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//
//        if (!error) {
//            NSLog(@"Reply JSON: %@", responseObject);
//
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                [self hideProgressAlert];
//                block(responseObject);
//
//            }
//        } else {
//            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//
//
//            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
//            //NSLog(@"Headers : %@",headers);
//
//            NSString *errorString = [headers valueForKey:@"ApiResponse"];
//
//            NSString *customError = [self parseErrorObject:errorString];
//
//            if(!customError)
//                customError = [self getLocalizeErrorMessageForInternetConnection:error];
//
//            [self hideProgressAlert];
//
//            [[UtilitiesHelper shareUtitlities]showToastWithMessage:customError title:@"" delegate:delegate];
//            failBlock(error);
//
//        }
//    }] resume];

}


- (void)postImageRequestWithParameters:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    NSData* imageData = nil;
    NSString* imageName =@"image";
    imageData = [params objectForKey:@"image"];
    if([imageData length]==0){
        imageData = [params objectForKey:@"image_share"];
        imageName = @"image_share";
    }
    NSMutableDictionary* tmpDict = [NSMutableDictionary dictionaryWithDictionary:params];
    [tmpDict removeObjectForKey:@"image"];
    [tmpDict removeObjectForKey:@"image_share"];

    
    [self POST:urlString parameters:tmpDict headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if ([imageData length]>0)
                [formData appendPartWithFileData:imageData name:imageName fileName:@"image.png" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
          self->progressHud.progress = uploadProgress.fractionCompleted;
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
        

//    [self POST:urlString parameters:tmpDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//
//        if ([imageData length]>0)
//            [formData appendPartWithFileData:imageData name:imageName fileName:@"image.png" mimeType:@"image/png"];
//
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//        self->progressHud.progress = uploadProgress.fractionCompleted;
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [self hideProgressAlert];
//        block(responseObject);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//       [self hideProgressAlert];
////#ifdef DEBUG
////
////        [[UtilitiesHelper shareUtitlities]showAlertWithMessage:error.description title:@"" delegate:delegate];
////
////#else
//        if(progressMessage)
//            [[UtilitiesHelper shareUtitlities]showToastWithMessage:@"Server Not Responding, please try again later!" title:@"" delegate:delegate];
//
////#endif
//
//        failBlock(error);
//    }];

    
    
    
}


-(void)setHeaderOnRequest:(NSMutableURLRequest *)request withAuth:(NSString *)auth{
    
    
    NSString *securityVersion = [Configuration getSecurityVersion];
    NSString *hmacType = [Configuration getHmacType];
    NSString *systemLanguage = [UtilitiesHelper getSystemLanguageCode];
    NSLog(@"Current System Language:: %@",systemLanguage);
    
    if([request isKindOfClass:[NSMutableURLRequest class]]){
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:systemLanguage forHTTPHeaderField:@"Accept-Language"];
//        [request setValue:@"en,en-gb;q=0.5" forHTTPHeaderField:@"Accept-Language"];
        [request setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
        [request setValue:@"UTF-8;q=0.7,*;q=0.7" forHTTPHeaderField:@"Accept-Charset"];
        [request setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
        [request setValue:@"no-store, no-cache, must-revalidate, pre-check=0, post-check=0, max-age=0" forHTTPHeaderField:@"Cache-Control"];
        [request setValue:@"Sat, 1 Jan 2020 00:00:00 GMT" forHTTPHeaderField:@"Expires"];
        [request setValue:hmacType forHTTPHeaderField:@"HmacType"];
        [request setValue:securityVersion forHTTPHeaderField:@"SecurityVersion"];
        [request setValue:auth forHTTPHeaderField:@"Authorization"];
    }
    else{
    }
}

-(void)setHeaderForLocationApiOnRequest:(NSMutableURLRequest *)request {
    
    if([request isKindOfClass:[NSMutableURLRequest class]]){
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"1" forHTTPHeaderField:@"Version"];
        [request setValue:[Configuration getCoOpID] forHTTPHeaderField:@"Authorization"];

    }
    else{

    }

}


-(NSMutableSet *)getAcceptableContentTypesWithSerializer:(AFJSONResponseSerializer *)jsonResponseSerializer{
    
    NSMutableSet *acceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
    [acceptableContentTypes addObject:@"text/html"];
    [acceptableContentTypes addObject:@"application/json"];
    return acceptableContentTypes;

}

-(void)createBatchOfRequestsWithObject:(NSArray *)reqObjects requestCompletionBlock:(void(^)(NSObject *response,id responseObj))reqBlock requestFailureBlock:(void(^)(NSError* error))failReqBlock queueCompletionBlock:(void(^)(BOOL sucess,NSString *errorString ))queueBlock queueFailureBlock:(void(^)(NSError* error))failQueueBlock{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    
    __block NSString *queueCustomError = nil;
    NSMutableArray *customReqArr= [[NSMutableArray alloc] init];
    __block NSError *reqError = nil;
    
    [reqObjects enumerateObjectsUsingBlock:^(NSDictionary  *dict, NSUInteger idx, BOOL *stop) {
        
        NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:dict[REQ_TYPE] URLString:dict[REQ_URL] parameters:dict[REQ_PARAM] error:nil];
        [self setTimeOutIntervalOnRequest:req];

        // Setting Headers for Own servers
        if(dict[REQ_HEADER]){
            [self setHeaderOnRequest:req withAuth:dict[REQ_HEADER]];
        }
        


        if(dict[REQ_HEADER_CONFIGURATION]){
            [req setValue:dict[REQ_HEADER_CONFIGURATION] forHTTPHeaderField:@"Authorization"];
        }


        HTTPRequestOperation *operation = [[HTTPRequestOperation alloc] initWithRequest:req];
        [operation setCompletionBlock:^(NSURLResponse *response, id responseObject, NSError *error) {
//            [self hideProgressAlert];

            if (!error) {
                NSLog(@"%@",responseObject);
                reqBlock(responseObject,response);
                
            } else {
                
                reqError=error;
                
                NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
                NSLog(@"Headers : %@",headers);
                

                    
                NSString *errorString = [headers valueForKey:@"ApiResponse"];
                    
                NSString *customError = [self parseErrorObject:errorString];
                    
                if(!customError)
                    customError = [self getLocalizeErrorMessageForInternetConnection:error];
                
                
                queueCustomError= customError;
                [self hideProgressAlert];
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//                NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                if([httpResponse statusCode]!=304)
                    failReqBlock(error);
                NSLog(@"operation setCompletionBlock %@",[error localizedDescription]);
            }
        }];
        [customReqArr addObject:operation];
        
    }];
    
    
    [self concurrentBatchOfRequestOperations:customReqArr progressBlock:^(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks) {
        
        NSLog(@"%lu of %lu process complete",(unsigned long)numberOfFinishedTasks,(unsigned long)totalNumberOfTasks);
    } completionBlock:^(NSArray *dataTasks) {
        NSLog(@"ALL TASK DONE WITH REQ COUNT : %lu ",(unsigned long)[dataTasks count]);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        [self hideProgressAlert];

        if(reqError){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            NSLog(@"%ld",(long)[reqError code]);
            if(![reqError.localizedDescription containsString:@"304"])
                queueBlock(FALSE,queueCustomError);
            else
                queueBlock(TRUE,queueCustomError);

        }
        else{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            queueBlock(TRUE,queueCustomError);
        }
    }];
    
}




- (void)concurrentBatchOfRequestOperations:(NSArray *)operations progressBlock:(void (^)(NSUInteger, NSUInteger))progressBlock completionBlock:(void (^)(NSArray *))completionBlock {
    

    
    if (!operations || operations.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(@[]);
            }
        });
        return;
    }
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:responseSerializer];
    manager.responseSerializer = responseSerializer;
    
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *tasks = @[].mutableCopy;
    
    __block  NSError *reqError;
    
    for (HTTPRequestOperation *operation in operations) {
        dispatch_group_enter(group);
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:operation.request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            reqError= error;
            
            if(reqError){
                NSLog(@"Error On URL : %@",response.URL.absoluteString);
            }
            if (operation.completionBlock) {
                operation.completionBlock(response, responseObject, error);
            }
            
            NSUInteger numberOfFinishedTasks = [[tasks indexesOfObjectsPassingTest:^BOOL(NSURLSessionDataTask * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                return (obj.state == NSURLSessionTaskStateCompleted);
                
            }] count];
            
            if (progressBlock && !error) {
                progressBlock(numberOfFinishedTasks, [tasks count]);
            }
            
            dispatch_group_leave(group);
            
        }];
        
        [tasks addObject:task];
        
    }
    
    for (NSURLSessionDataTask *task in tasks) {
        [task resume];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completionBlock) {
            [self endSession:manager.session];
            completionBlock(tasks);
        }
    });
}

-(NSDictionary *)getErrorObjectWithStatusMessage:(NSString *)statusDescription andStatusCode:(int)statusCode{
    
    NSDictionary *json = nil;
    NSArray *responseSeperaterArr = [statusDescription componentsSeparatedByString:[NSString stringWithFormat:@"%d",statusCode]];
    
    NSString *responseStatusMessage = nil;
    if([responseSeperaterArr count]>0)
        responseStatusMessage =[responseSeperaterArr lastObject];
    if(responseStatusMessage){
        NSData *data = [responseStatusMessage dataUsingEncoding:NSUTF8StringEncoding];
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return json;
}


-(NSString *)parseErrorObject:(NSString *)customError{
    
    NSString *localizeMessage = nil;
    NSDictionary *json = nil;
    if(customError){
            NSData *data = [customError dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if(json)
            localizeMessage = [json valueForKey:@"text"];
    }
    
    return localizeMessage;
}


-(NSString *)getErrorMessageWithObject:(NSDictionary *)errorDict{
    
    
    NSString *errorMessageNew=nil;
    if(errorDict)
        errorMessageNew = errorDict[@"text"];
    else
        errorMessageNew = @"Unknown error";

    return errorMessageNew;
}

-(NSDictionary *)parseResponseToJsonWithData:(NSData *)data{
    
    NSError *error;
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
    if(!error){
        return jsonDict;
    }
    else
        return nil;

}

-(NSString *)getLocalizeErrorMessageForInternetConnection:(NSError *)error{
    
    NSString *localizeErrorMessage = nil;
    
    localizeErrorMessage=[Configuration getMaintenanceVerbiage];
    
    return localizeErrorMessage;
}

-(void)setTimeOutIntervalOnRequest:(NSMutableURLRequest *)request{
    [request setTimeoutInterval:RESPONSE_TIME_OUT];
}


- (void)postRequestForConfigurationWithParameters:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *url = [NSString stringWithFormat:@"https://nsauth-extdev.ns3web.com/core/connect/token/"];
    
    NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"client_credentials",@"grant_type",
                                          @"content_file.read content_text_group.read content_text.read style_value.read client_setting.read menu_item.read", @"scope",@"nsmobile_nsconfig_read_client",@"client_id",@"202E8187-94DE-4CDA-8908-7A9436B21292",@"client_secret",
                                          nil
                                          ];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:url parameters:parametersDictionary headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
    }];
   
}

-(void)endSession:(NSURLSession*)aSession {
    [aSession finishTasksAndInvalidate];
    [aSession invalidateAndCancel];
}

@end

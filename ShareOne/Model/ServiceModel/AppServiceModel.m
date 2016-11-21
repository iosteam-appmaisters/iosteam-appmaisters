
#import "AppServiceModel.h"
#import "SignInModel.h"
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
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_POST URLString:urlString parameters:nil error:nil];
    
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


        AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
        manager.responseSerializer = responseSerializer;

    }
    

    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                block(responseObject);
                
            }else{
                NSData * data = (NSData *)responseObject;
                
                
                NSLog(@"Response string: %@", [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding]);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                block(responseObject);

            }
        } else {
            
            
            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);



            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];
            
        }
    }] resume];

    
    
    
}

-(void)postRequestForSSOWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
        AFHTTPResponseSerializer *jsonResponseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_POST URLString:urlString parameters:nil error:nil];
    
    
//    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
//    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
//    
//    
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
    
    NSURLSessionDataTask *managerHttpRequest =  [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"Response: %@", responseObject);
        
        
        if(error==nil){
        
            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            //            NSLog(@"SSO URL : %@",[error.userInfo valueForKey:@"NSErrorFailingURLKey"]);
            NSString *url =[error.userInfo valueForKey:@"NSErrorFailingURLKey"];
            
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            
            url = response.URL.absoluteString;
            
//            block(url);
            block(req);

            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        else {
            NSLog(@"error : %@", error.localizedDescription);
            NSLog(@"Response : %@", response);
        }
    }];
    
    [managerHttpRequest resume];
    
    
    
    
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
//            }else{
//                NSData * data = (NSData *)responseObject;
//                
//                
//                NSLog(@"Response string: %@", [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding]);
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                [self hideProgressAlert];
//                block(responseObject);
//                
//            }
//        } else {
//            
//            
//            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
//            
////            NSLog(@"SSO URL : %@",[error.userInfo valueForKey:@"NSErrorFailingURLKey"]);
//            NSString *url =[error.userInfo valueForKey:@"NSErrorFailingURLKey"];
//            
//            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
//            
//            block(url);
//            
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            [self hideProgressAlert];
//            //[[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];
//            
//        }
//    }] resume];
    
    
    
    
}

-(NSMutableURLRequest *)getRequestForSSOWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFHTTPResponseSerializer *jsonResponseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_GET URLString:urlString parameters:params error:nil];
    
    
    // Setting Headers for Own servers
    if(auth_header){
        [self setHeaderOnRequest:req withAuth:auth_header];
    }
    
    return req;

    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];

            NSString *string = [NSString stringWithUTF8String:[responseObject bytes]];

            NSLog(@"json: %@, %@, %@", json, response, responseObject);
            
            NSString * url = response.URL.absoluteString;

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            block(string);
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            block(responseObject);
            
            [self hideProgressAlert];
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];
            
        }
    }] resume];


}



-(void)postRequestForVertifiWithParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response,BOOL succes))block failureBlock:(void(^)(NSError* error))failBlock{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_POST URLString:urlString parameters:nil error:nil];
    
    

    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    
    NSString *boundary = [ShareOneUtility generateBoundaryString];
        
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        
    // create body
    NSData *httpBody = [ShareOneUtility createBodyWithBoundary:boundary parameters:params];
    [req setHTTPBody:httpBody];
    
    
    
        
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    manager.responseSerializer = responseSerializer;
        
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self hideProgressAlert];
            block(responseObject,TRUE);
            NSLog(@"Reply JSON: %@", responseObject);
            
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            block(nil,FALSE);

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

    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
//    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
//    
//    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    
    AFHTTPResponseSerializer *jsonResponseSerializer = [AFHTTPResponseSerializer serializer];

    manager.responseSerializer = jsonResponseSerializer;
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_PUT URLString:urlString parameters:nil error:nil];
    
    if(auth_header)
        [self setHeaderOnRequest:req withAuth:auth_header];
    
    
    if(params){
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self hideProgressAlert];
                block(responseObject);

            }
        } else {
            
            
            
            //NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
            //NSLog(@"Headers : %@",headers);
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            //NSLog(@"status code: %li", (long)httpResponse.statusCode);
            
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            
            //NSLog(@"status code: %li", (long)statusCode);

            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
//            NSLog(@"%@",ErrorResponse);
            
            NSDictionary *userInfo = [error userInfo];
            NSString *errorString = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
            NSLog(@"%@",errorString);

            NSString *eerorString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];


            [self hideProgressAlert];
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:error.localizedDescription title:@"" delegate:delegate];

        }
    }] resume];
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

    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            
            if(auth_header)
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

-(void)deleteRequestWithAuthHeader:(NSString *)auth_header AndParam:(NSDictionary *)params progressMessage:(NSString*)progressMessage urlString:(NSString*)urlString delegate:(id)delegate completionBlock:(void(^)(NSObject *response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(progressMessage)
        [self showProgressWithMessage:progressMessage];
    
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    jsonResponseSerializer.acceptableContentTypes = [self getAcceptableContentTypesWithSerializer:jsonResponseSerializer];
    manager.responseSerializer = jsonResponseSerializer;
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:RequestType_DELETE URLString:urlString parameters:nil error:nil];
    
    if(auth_header)
        [self setHeaderOnRequest:req withAuth:auth_header];
    
    
    if(params){
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
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

-(void)setHeaderForLocationApiOnRequest:(NSMutableURLRequest *)request {
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"1" forHTTPHeaderField:@"Version"];
    [request setValue:kLOCATION_API_KEY forHTTPHeaderField:@"Authorization"];

}


-(NSMutableSet *)getAcceptableContentTypesWithSerializer:(AFJSONResponseSerializer *)jsonResponseSerializer{
    
    NSMutableSet *acceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
    [acceptableContentTypes addObject:@"text/html"];
    [acceptableContentTypes addObject:@"application/json"];
    return acceptableContentTypes;

}

-(void)createBatchOfRequestsWithObject:(NSArray *)reqObjects requestCompletionBlock:(void(^)(NSObject *response,NSURLResponse *responseObj))reqBlock requestFailureBlock:(void(^)(NSError* error))failReqBlock queueCompletionBlock:(void(^)(BOOL sucess))queueBlock queueFailureBlock:(void(^)(NSError* error))failQueueBlock{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    
    NSMutableArray *customReqArr= [[NSMutableArray alloc] init];
    
    [reqObjects enumerateObjectsUsingBlock:^(NSDictionary  *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:dict[REQ_TYPE] URLString:dict[REQ_URL] parameters:dict[REQ_PARAM] error:nil];
        
        // Setting Headers for Own servers
        if(dict[REQ_HEADER]){
            [self setHeaderOnRequest:req withAuth:dict[REQ_HEADER]];
        }
        
        HTTPRequestOperation *operation = [[HTTPRequestOperation alloc] initWithRequest:req];
        [operation setCompletionBlock:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
//                NSLog(@"%@",responseObject);
                reqBlock(responseObject,response);
            } else {
                failReqBlock(error);
                NSLog(@"operation setCompletionBlock %@",[error localizedDescription]);
            }
        }];
        [customReqArr addObject:operation];
        
    }];
    [self concurrentBatchOfRequestOperations:customReqArr progressBlock:^(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks) {
        
        NSLog(@"%d of %d process complete",numberOfFinishedTasks,totalNumberOfTasks);
    } completionBlock:^(NSArray *dataTasks) {
        NSLog(@"ALL TASK DONE WITH REQ COUNT : %d ",[dataTasks count]);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        queueBlock(TRUE);
    }];}



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
                NSLog(@"Here it comes");
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
            completionBlock(tasks);
        }
    });
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
    
    
    //
    //    NSString *getString = [NSString stringWithFormat:@"DeviceFingerprint=%@",[params valueForKey:@"DeviceFingerprint"]];
    //    NSData *getData = [getString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    //
    //    [req setHTTPBody:getData];
    //
    
    
//        id response;
//    
//        NSData * data = [NSURLConnection sendSynchronousRequest:req
//                                              returningResponse:&response
//                                                          error:&error];
//    
//        if (error == nil)
//        {
//            // Parse data here
//            NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@",myString);
//    
//        }
//        else
//        {
//            NSLog(@"%@",error);
//            NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@",myString);
//    
//        }
//        block(nil);
//    
//        
//        return;


}

@end
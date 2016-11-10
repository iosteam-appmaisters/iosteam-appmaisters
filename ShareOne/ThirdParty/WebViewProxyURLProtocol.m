//
//  WebViewProxyURLProtocol.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/10/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "WebViewProxyURLProtocol.h"

@implementation WebViewProxyURLProtocol{
    NSMutableURLRequest* correctedRequest;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return ([[request allHTTPHeaderFields] objectForKey:@"X-WebViewProxy"] == nil);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return NO;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client]) {
        // Add header to prevent loop in proxy
        correctedRequest = request.mutableCopy;
        [correctedRequest addValue:@"True" forHTTPHeaderField:@"X-WebViewProxy"];
    }
    return self;
}

- (void)startLoading {
    [NSURLConnection connectionWithRequest:correctedRequest delegate:self];
}

- (void)stopLoading {
    correctedRequest = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
    if (redirectResponse) {
        NSMutableURLRequest *redirect = [request mutableCopy];
//        [NSURLProtocol removePropertyForKey:@"kFlagRequestHandled" inRequest:redirect];
//        [RequestHelper addWebViewHeadersToRequest:redirect];
        
        // THE IMPORTANT PART
        [self.client URLProtocol:self wasRedirectedToRequest:redirect redirectResponse:redirectResponse];
        
        return redirect;
    }
    return request;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

@end

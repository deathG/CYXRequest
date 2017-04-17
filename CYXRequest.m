//
//  CYXRequest.m
//  HMDoctor
//
//  Created by lijia on 2017/1/11.
//  Copyright © 2017年 zljy. All rights reserved.
//

#import "CYXRequest.h"

@interface CYXRequest()
@property (nonatomic,copy) NSString * component;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) NSDictionary * parameters;
@end
@implementation CYXRequest
+ (instancetype)requestWithComponent:(NSString *)component parameters:(NSDictionary *)parameters
{
    return [[self alloc] initWithComponent:component parameters:parameters];
}
- (instancetype)initWithComponent:(NSString *)component parameters:(NSDictionary *)parameters
{
    if (self)
    {
        _component = component;
        _parameters = parameters;
        if (_parameters == nil)
            _parameters = @{};
        NSString * serviceAddress = Server_URL;
        _url = [serviceAddress stringByAppendingString:component];
    }
    return self;
}
- (RACSignal *)beginRequest
{
    return [self beginRequestWithController:nil];
}
- (RACSignal *)beginRequestWithController:(UIViewController *)controller
{
    return [self beginRequestWithController:controller loading:NO];
}
- (RACSignal *)beginRequestWithController:(UIViewController *)controller loading:(BOOL)loading
{
    MBProgressHUD * hud;
    if (loading)
    {
        hud = [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
        hud.userInteractionEnabled = NO;
    }
    RACSignal * requestSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",nil];
        manager.requestSerializer.timeoutInterval = 15;
        [manager POST:_url parameters:_parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [subscriber sendNext:(NSDictionary *)responseObject];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DLog(@"%@",error);
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [hud hideAnimated:YES];
        }];
    }];
    requestSignal.name = @"request";
    RACMulticastConnection * connection = [requestSignal publish];
    [connection connect];
    return connection.signal;
}
- (RACSignal *)beginUploadFileWhitParameters:(NSString *)parameters file:(NSString *)file
{
    return [RACSignal empty];
}
- (RACSignal *)beginUploadImageWhitParameters:(NSString *)parameters images:(NSArray *)images
{
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = nil;
        manager.requestSerializer.timeoutInterval = 15;
        [images enumerateObjectsUsingBlock:^(UIImage * image, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData * data = UIImageJPEGRepresentation(image,.8);
            [manager POST:_url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:data name:@"Filedata" fileName:@"photo.jpg" mimeType:@"image/jpg"];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                [subscriber sendNext:uploadProgress];
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
        }];
        return nil;
    }];
    signal.name = @"upload image";
    RACMulticastConnection * connection = [signal publish];
    [connection connect];
    return connection.signal;
}
+ (RACSignal *)isReachability
{
    AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [subscriber sendNext:@(status)];
        }];
        [manager startMonitoring];
        return nil;
    }];
    signal.name = @"reachability";
    return [signal distinctUntilChanged];
}
@end

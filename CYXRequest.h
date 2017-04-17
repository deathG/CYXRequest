//
//  CYXRequest.h
//  HMDoctor
//
//  Created by lijia on 2017/1/11.
//  Copyright © 2017年 zljy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYXRequest : NSObject
+ (instancetype)requestWithComponent:(NSString *)component parameters:(NSDictionary *)parameters;
- (instancetype)initWithComponent:(NSString *)component parameters:(NSDictionary *)parameters;
- (RACSignal *)beginRequest;
- (RACSignal *)beginRequestWithController:(UIViewController *)controller;

/**
 网络请求

 @param controller 当前控制器
 @param loading 是否显示加载
 @return 信号
 */
- (RACSignal *)beginRequestWithController:(UIViewController *)controller loading:(BOOL)loading;

/**
 上传文件

 @param parameters 参数
 @param file 文件
 @return 信号
 */
- (RACSignal *)beginUploadFileWhitParameters:(NSString *)parameters file:(NSString *)file;

/**
 上传图片

 @param parameters 参数
 @param images 图片数组
 @return 信号
 */
- (RACSignal *)beginUploadImageWhitParameters:(NSString *)parameters images:(NSArray *)images;

/**
 监听网络

 @return 返回监听的信号
 */
+ (RACSignal *)isReachability;
@end


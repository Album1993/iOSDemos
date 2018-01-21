//
//  YtknetworkHttpsSetting.m
//  iOS_Demos
//
//  Created by 张一鸣 on 19/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "YtknetworkHttpsSetting.h"
#import <YTKNetwork/YTKNetwork.h>
#import <AFNetworking/AFNetworking.h>

@implementation YtknetworkHttpsSetting

// YTKNetWork 的配置
-(void)configHttps{
    
    // 获取证书
    NSString *cerPath = nil;//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // 配置安全模式
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    
    // 验证公钥和证书的其他信息
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // 允许自建证书
    securityPolicy.allowInvalidCertificates = YES;
    
    // 校验域名信息
    securityPolicy.validatesDomainName      = YES;
    
    // 添加服务器证书,单向验证;  可采用双证书 双向验证;
    securityPolicy.pinnedCertificates       = [NSSet setWithObject:certData];
    
    [config setSecurityPolicy:securityPolicy];
    
}

@end

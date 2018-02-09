//
//  HttpsAuthenticationViewController.m
//  iOS_Demos
//
//  Created by 张一鸣 on 16/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

#import "HttpsAuthenticationViewController.h"
#import <AFNetworking/AFNetworking.h>


@interface HttpsAuthenticationViewController ()

@end


@implementation HttpsAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)POST:(NSString *)urlString
  Dictionary:(NSDictionary *)dic
    progress:(void (^)(NSProgress *_Nonnull))uploadProgress
     success:(void (^)(NSURLSessionDataTask *_Nonnull, id _Nullable))success
     failure:(void (^)(NSURLSessionDataTask *_Nullable, NSError *_Nonnull))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //    设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setValue:@"Content-Type" forHTTPHeaderField:@"application/json; charset=utf-8"];
    [manager setSecurityPolicy:[self customSecurityPolicy]];
    [self checkCredential:manager];

    NSData *  data       = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [manager POST:urlString parameters:jsonString progress:uploadProgress success:success failure:failure];
}

- (AFSecurityPolicy *)customSecurityPolicy {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //tomcat1(1)
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    NSData *certData  = [NSData dataWithContentsOfFile:cerPath];
    NSSet * dataSet   = [NSSet setWithArray:@[ certData ]];
    [securityPolicy setAllowInvalidCertificates:YES];
    [securityPolicy setPinnedCertificates:dataSet];
    [securityPolicy setValidatesDomainName:YES];

    return securityPolicy;
}

//校验证书
- (void)checkCredential:(AFURLSessionManager *)manager {
    [manager setSessionDidBecomeInvalidBlock:^(NSURLSession *_Nonnull session, NSError *_Nonnull error){
    }];
    __weak typeof(manager) weakManager = manager;
    [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *_credential) {
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential      = nil;
        NSLog(@"authenticationMethod=%@", challenge.protectionSpace.authenticationMethod);
        //判断是核验客户端证书还是服务器证书
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            // 基于客户端的安全策略来决定是否信任该服务器，不信任的话，也就没必要响应挑战（自建证书使用的。因为自建证书不接受ca认证，会被直接否定）
            if ([weakManager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                // 创建挑战证书（注：挑战方式为UseCredential和PerformDefaultHandling都需要新建挑战证书）
                NSLog(@"serverTrust=%@", challenge.protectionSpace.serverTrust);
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                // 确定挑战的方式
                if (credential) {
                    //证书挑战  设计policy,none，则跑到这里
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            // client authentication（双向认证使用的，这个是服务端索要这个p12中的公钥，将这个公钥取出来放入disposition）
            SecIdentityRef identity    = NULL;
            SecTrustRef    trust       = NULL;
            NSString *p12              = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"p12"];
            NSFileManager *fileManager = [NSFileManager defaultManager];

            if (![fileManager fileExistsAtPath:p12]) {
                NSLog(@"client.p12:not exist");
            } else {
                NSData *PKCS12Data = [NSData dataWithContentsOfFile:p12];

                if ([self extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data]) {
                    SecCertificateRef certificate = NULL;
                    SecIdentityCopyCertificate(identity, &certificate);
                    const void *certs[]   = {certificate};
                    CFArrayRef  certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
                    credential            = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray *)certArray persistence:NSURLCredentialPersistencePermanent];
                    disposition           = NSURLSessionAuthChallengeUseCredential;
                }
            }
        }
        *_credential = credential;
        return disposition;
    }];
}

//读取p12文件中的密码
- (BOOL)extractIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    //client certificate password
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:@"123456"
                                                                  forKey:(__bridge id)kSecImportExportPassphrase];

    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError    = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data, (__bridge CFDictionaryRef)optionsDictionary, &items);

    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *    tempIdentity       = NULL;
        tempIdentity                       = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        *outIdentity                       = (SecIdentityRef)tempIdentity;
        const void *tempTrust              = NULL;
        tempTrust                          = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        *outTrust                          = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failedwith error code %d", (int)securityError);
        return NO;
    }
    return YES;
}


/** swift 版本
 a delegate method to check whether the remote cartification is the same with given certification.
 
 - parameter session:           NSURLSession
 - parameter challenge:         NSURLAuthenticationChallenge
 - parameter completionHandler: the completionHandler closure
 */
/*!
 extension URLSessionDelegate {
@objc(URLSession:didReceiveChallenge:completionHandler:) func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    if self.localCertDataArray.count == 0 {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, nil)
        return
    }
    if let serverTrust = challenge.protectionSpace.serverTrust,
        let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let remoteCertificateData: Data = SecCertificateCopyData(certificate) as Data
            
            var checked = false
            
            for localCertificateData in self.localCertDataArray {
                if localCertificateData as Data == remoteCertificateData {
                    if !checked {
                        checked = true
                    }
                }
            }
            
            if checked {
                let credential = URLCredential(trust: serverTrust)
                challenge.sender?.use(credential, for: challenge)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
            } else {
                challenge.sender?.cancel(challenge)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                DispatchQueue.main.async {
                    self.sSLValidateErrorCallBack?()
                }
                return
            }
        } else {
            // could not test
            print("Pitaya: Get RemoteCertificateData or LocalCertificateData error!")
        }
}
}
 */

@end

//
//  TSEncryption.h
//  CocoaAsyncSocket
//
//  Created by QinChuancheng on 2019/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSEncryption : NSObject


/// 加密
/// @param EncryData 需要加密的数据
+ (NSData *)AES128EncryptDataWithData:(NSData *)EncryData;

/// 解密
/// @param DecryData 需要解密的数据
+ (NSData *)AES128DecryptDataWithData:(NSData *)DecryData;

/// 加密
/// @param EncryStr 需要加密的字符串
+ (NSData *)AES128EncryptDataWithString:(NSString *)EncryStr;

/// 解密
/// @param DecryStr 需要解密的字符串
+ (NSData *)AES128DecryptDataWithString:(NSString *)DecryStr;
+ (NSString *)AES128EncryptStringWithWithData:(NSData *)EncryData;
+ (NSString *)AES128EncryptStringWithWithString:(NSString *)EncryStr;
+ (NSString *)AES128DecryptStringWithString:(NSString *)DecryStr;

@end

NS_ASSUME_NONNULL_END

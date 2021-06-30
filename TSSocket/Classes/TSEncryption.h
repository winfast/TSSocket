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


//CCB模式， 必须有向量

+ (NSData *)AES128EncryptDataWithData:(NSData *)EncryData secretKey:(NSString *)secretKey iv:(NSString *)iv;


+ (NSData *)AES128DecryptDataWithData:(NSData *)DecryData secretKey:(NSString *)secretKey iv:(NSString *)iv;


/**
 * Base64编码
 */
+ (NSData *)base64Encode:(NSData *)data;
 
/**
 * Base64解码
 */
+ (NSData *)base64Dencode:(NSData *)data;



+ (NSData *)AES256EncryptWithData:(NSData *)EncryData secretKey:(NSString *)secretKey;   //加密

+ (NSData *)AES256DecryptWithData:(NSData *)EncryData secretKey:(NSString *)secretKey;    //解密

@end

NS_ASSUME_NONNULL_END

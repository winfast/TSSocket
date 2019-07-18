//
//  TSEncryption.h
//  CocoaAsyncSocket
//
//  Created by QinChuancheng on 2019/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSEncryption : NSObject

+ (NSData *)AES128EncryptDataWithData:(NSData *)EncryData;
+ (NSData *)AES128DecryptDataWithData:(NSData *)DecryData;
+ (NSData *)AES128EncryptDataWithString:(NSString *)EncryStr;
+ (NSData *)AES128DecryptDataWithString:(NSString *)DecryStr;
+ (NSString *)AES128EncryptStringWithWithData:(NSData *)EncryData;
+ (NSString *)AES128EncryptStringWithWithString:(NSString *)EncryStr;
+ (NSString *)AES128DecryptStringWithString:(NSString *)DecryStr;

@end

NS_ASSUME_NONNULL_END

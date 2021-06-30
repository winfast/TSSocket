//
//  TSEncryption.m
//  CocoaAsyncSocket
//
//  Created by QinChuancheng on 2019/7/18.
//

#import "TSEncryption.h"
#import <CommonCrypto/CommonCryptor.h>

#define DecodeOrEncode_Key     @"xxxxxxxxxxx" //加密解密用的Key

@implementation TSEncryption

+ (NSData *)AES128EncryptDataWithData:(NSData *)EncryData
{
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [DecodeOrEncode_Key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [EncryData length];
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    NSUInteger newSize = 0;
    
    if(diff > 0) {
        newSize = dataLength + diff;
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [EncryData bytes], [EncryData length]);
    for(int i = 0; i < diff; i++) {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionECBMode,               //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          NULL,
                                          dataPtr,
                                          newSize,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return resultData;
    }
    free(buffer);
    return nil;
}

+ (NSData *)AES128DecryptDataWithData:(NSData *)DecryData
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [DecodeOrEncode_Key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    //NSData *data = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSUInteger dataLength = [DecryData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [DecryData bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return resultData;
    }
    free(buffer);
    return nil;
}

+ (NSData *)AES128EncryptDataWithString:(NSString *)EncryStr
{
    NSData *data = [EncryStr dataUsingEncoding:NSUTF8StringEncoding];
    return [TSEncryption AES128EncryptDataWithData:data];
}

+ (NSData *)AES128DecryptDataWithString:(NSString *)DecryStr
{
    NSData *data = [self dataForHexString:DecryStr];
    return [TSEncryption AES128DecryptDataWithData:data];
}

+ (NSString *)AES128EncryptStringWithWithData:(NSData *)EncryData
{
    NSData *data = [self AES128EncryptDataWithData:EncryData];
    return [self hexStringFromData:data];
}

+ (NSString *)AES128EncryptStringWithWithString:(NSString *)EncryStr
{
    NSData *data = [EncryStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryData = [self AES128EncryptDataWithData:data];
    return [self hexStringFromData:encryData];
}

+ (NSString *)AES128DecryptStringWithString:(NSString *)DecryStr
{
    NSData *data = [self dataForHexString:DecryStr];
    NSData *decryData = [self AES128DecryptDataWithData:data];
    return [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
}

// 普通字符串转换为十六进
+ (NSString *)hexStringFromData:(NSData *)data {
    Byte *bytes = (Byte *)[data bytes];
    // 下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for(int i=0; i<[data length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i] & 0xff]; //16进制数
        newHexStr = [newHexStr uppercaseString];
        
        if([newHexStr length] == 1) {
            newHexStr = [NSString stringWithFormat:@"0%@",newHexStr];
        }
        
        hexStr = [hexStr stringByAppendingString:newHexStr];
        
    }
    return hexStr;
}

+ (NSData *)dataForHexString:(NSString*)hexString
{
    if (!hexString || [hexString length] == 0) {
        return nil;
    }
    
    NSMutableString *temp = [NSMutableString stringWithString:hexString];
    NSRange rangeTemp = {0,temp.length};
    [temp replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:rangeTemp];
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([temp length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [temp length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [temp substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

+ (NSData *)AES128EncryptDataWithData:(NSData *)EncryData secretKey:(NSString *)secretKey iv:(NSString *)iv {
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [secretKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    

    /*
    这里设置的参数ios默认为CBC加密方式，如果需要其他加密方式如ECB，在kCCOptionPKCS7Padding这个参数后边加上kCCOptionECBMode，即kCCOptionPKCS7Padding | kCCOptionECBMode，但是记得修改上边的偏移量，因为只有CBC模式有偏移量之说
    */
    size_t bufferSize = [EncryData length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,               //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          EncryData.bytes,
                                          EncryData.length,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return resultData;
    }
    free(buffer);
    return nil;
}

+ (NSData *)AES128DecryptDataWithData:(NSData *)DecryData secretKey:(NSString *)secretKey iv:(NSString *)iv {
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [secretKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
   
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [DecryData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    /*
    这里设置的参数ios默认为CBC加密方式，如果需要其他加密方式如ECB，在kCCOptionPKCS7Padding这个参数后边加上kCCOptionECBMode，即kCCOptionPKCS7Padding | kCCOptionECBMode，但是记得修改上边的偏移量，因为只有CBC模式有偏移量之说
    */
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [DecryData bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return resultData;
    }
    free(buffer);
    return nil;
}

/**
 * Base64编码
 */
+ (NSData *)base64Encode:(NSData *)data {
    return [data base64EncodedDataWithOptions:0];
}
 
/**
 * Base64解码
 */
+ (NSData *)base64Dencode:(NSData *)data {
    if (!data) {
        return nil;
    }
    return [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
}


+ (NSData *)AES256EncryptWithData:(NSData *)EncryData secretKey:(NSString *)secretKey{   //加密
    char keyPtr[kCCKeySizeAES256+1];

    bzero(keyPtr, sizeof(keyPtr));

    [secretKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [EncryData length];

    size_t bufferSize = dataLength + kCCBlockSizeAES128;

    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,

                                          kCCOptionPKCS7Padding | kCCOptionECBMode,

                                          keyPtr, 32,

                                          NULL,

                                          [EncryData bytes], dataLength,

                                          buffer, bufferSize,

                                          &numBytesEncrypted);

    if (cryptStatus == kCCSuccess) {

        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];

    }

    free(buffer);

    return nil;
}


+ (NSData *)AES256DecryptWithData:(NSData *)DecryptData secretKey:(NSString *)secretKey {    //解密
    char keyPtr[kCCKeySizeAES256+1];

    bzero(keyPtr, sizeof(keyPtr));

    [secretKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [DecryptData length];

    size_t bufferSize = dataLength + kCCBlockSizeAES128;

    void *buffer = malloc(bufferSize);

    size_t numBytesDecrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,

                                          kCCOptionPKCS7Padding | kCCOptionECBMode,

                                          keyPtr, 32,

                                          NULL,

                                          [DecryptData bytes], dataLength,

                                          buffer, bufferSize,

                                          &numBytesDecrypted);

    if (cryptStatus == kCCSuccess) {

        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];

    }

    free(buffer);

    return nil;
}

@end

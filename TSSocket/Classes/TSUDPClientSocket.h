//
//  TSUDPClientSocket.h
//  CocoaAsyncSocket
//
//  Created by Qincc on 2021/6/1.
//

#import <Foundation/Foundation.h>

@interface TSUDPClientSocket : NSObject

/// 收到UDP数据的block
@property (nonatomic, copy) void (^smartDevicePostData)(NSDictionary *smartDeviceData);

/// UDP  关闭的回调
@property (nonatomic, copy) void (^smartDeviceUDPClose)(void);

//- (instancetype) __unavailable init;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)share;

/// 发送UDP数据
/// @param postDict 发送的数据
/// @param ipaddr IP 地址
/// @param port 端口
- (void)postData:(NSDictionary *)postDict withIpaddr:(NSString *)ipaddr port:(NSInteger)port;

/// 关闭UDP协议
- (void)closeSocket;

/// 清空UDP的回调
- (void)clearCallback;

@end


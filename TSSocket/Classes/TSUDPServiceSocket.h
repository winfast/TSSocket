//
//  TSUDPServiceSocket.h
//  CocoaAsyncSocket
//
//  Created by Qincc on 2021/6/1.
//

#import <Foundation/Foundation.h>


@interface TSUDPServiceSocket : NSObject

/// 收到UDP数据的block
@property (nonatomic, copy) void (^smartDevicePostData)(NSDictionary *smartDeviceData);


/// UDP  关闭的回调
@property (nonatomic, copy) void (^smartDeviceUDPClose)(void);

//- (instancetype) __unavailable init;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)share;

/// 启动UDP服务器
- (void)startUDPServiceSocket:(NSInteger)port;

/// 关闭UDP服务器
- (void)closeSocket;

@end


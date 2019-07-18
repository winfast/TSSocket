//
//  TSTcpSocket.h
//  CocoaAsyncSocket
//
//  Created by QinChuancheng on 2019/7/18.
//

#import "TSBaseSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSTcpSocket : TSBaseSocket

+ (instancetype)share;

/**
 TCP延时断开
 
 @param seconds 多久后断开  单位 S
 */
- (void)disConnectTCPWithSeconds:(NSInteger)seconds callback:(void(^)(void))complete;


/**
 清空回调，断开TCP和该接口的调用时间请注意
 如果先清空回调的话  callback就没有有操作
 如果先断开的话，callback仍然有效，断开之后不需要再次调用clearCallback
 */
- (void)clearCallback;

@end

NS_ASSUME_NONNULL_END

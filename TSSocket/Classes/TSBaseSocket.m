//
//  TSBaseSocket.m
//  CocoaAsyncSocket
//
//  Created by QinChuancheng on 2019/7/18.
//

#import "TSBaseSocket.h"


@implementation TSBaseSocket

/**
 连接tcp服务器 子类必须实现
 
 @param ipAddress 服务器IP地址
 @param port 服务器端口
 @return 连接状态
 */
- (BOOL)connectTCPServer:(NSString *)ipAddress port:(NSInteger)port
{
    return YES;
}

/**
 断开TCP连接  子类必须实现
 
 @return 是否断开 YES 断开
 */
- (BOOL)disConnect
{
    return YES;
}

/**
 发送TCP数据流
 
 @param postData 发送的内容
 */
- (void)postData:(NSDictionary *)postData
{
    
}

@end

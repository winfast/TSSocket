//
//  TSBaseSocket.h
//  CocoaAsyncSocket
//
//  Created by QinChuancheng on 2019/7/18.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

typedef struct DATAHEAD
{
    char tag[8];
    int datlen;
}
DataHeadBlock;


@interface TSBaseSocket : NSObject

/**
 socket实例
 */
@property(nonatomic, strong) GCDAsyncSocket *asyncSocket;

/**
 TCP是否连接
 */
@property(nonatomic, assign) BOOL isConnected;

/**
 TCP连接成功的block
 */
@property (nonatomic, copy) void (^connectServerSuccess)(void);

/**
 TCP连接失败的block
 */
@property (nonatomic, copy) void (^connectServerFailed)(void);

/**
 TCP连接断开的block
 */
@property (nonatomic, copy) void (^connectServerDisConnect)(void);

/**
 收到服务器的数据block
 */
@property (nonatomic, copy) void (^serverPostData)(NSDictionary *serverData);

/**
 连接tcp服务器 子类必须实现
 
 @param ipAddress 服务器IP地址
 @param port 服务器端口
 @return 连接状态
 */
- (BOOL)connectTCPServer:(NSString *)ipAddress port:(NSInteger)port;

/**
 断开TCP连接  子类必须实现
 
 @return 是否断开 YES 断开
 */
- (BOOL)disConnect;

/**
 发送TCP数据流
 
 @param postData 发送的内容
 */
- (void)postData:(NSDictionary *)postData;

@end


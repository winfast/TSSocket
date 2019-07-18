//
//  TSTcpSocket.m
//  CocoaAsyncSocket
//
//  Created by QinChuancheng on 2019/7/18.
//

#import "TSTcpSocket.h"

static NSMutableData   *haveReadData;   //接收数据的缓存
static  NSLock        *readLock;        //接收数据锁
static  NSLock        *sendCommandLock; //发送数据锁

@interface TSTcpSocket ()<GCDAsyncSocketDelegate>

@property (nonatomic) NSUInteger sendNum;
@property (nonatomic, strong) NSTimer *disConnectTimer;
@property (nonatomic, copy) void (^complete)(void);

@end

@implementation TSTcpSocket

+ (instancetype)share
{
    static TSTcpSocket *tcpSocket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tcpSocket = TSTcpSocket.alloc.init;
        haveReadData = NSMutableData.alloc.init;
        readLock = NSLock.alloc.init;
        sendCommandLock = NSLock.alloc.init;
    });
    return tcpSocket;
}

- (BOOL)connectGalanzSmartDevice:(NSString *)ipAddress port:(NSInteger)port
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    _sendNum = 0;
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:ipAddress onPort:port withTimeout:10.0 error:&error])
    {
        NSLog(@"Error connecting: %@", error);
        return NO;
    }
    return YES;
}

- (BOOL)disConnect
{
    NSLog(@"===================== disConnect =====================");
    if ([self.disConnectTimer isValid]) {
        [self.disConnectTimer invalidate];
        self.disConnectTimer = nil;
    }
    [self.asyncSocket setDelegate:nil delegateQueue:NULL];
    [self.asyncSocket disconnect];
    self.asyncSocket = nil;
    [haveReadData replaceBytesInRange:NSMakeRange(0, haveReadData.length) withBytes:NULL length:0];
    return YES;
}

//TCP断开之后需要清空所有的block
- (void)clearCallback
{
    self.complete = nil;
    self.connectServerDisConnect = nil;
    self.connectServerFailed = nil;
    self.connectServerSuccess = nil;
    self.serverPostData = nil;
}

- (void)disConnectTCPWithSeconds:(NSInteger)seconds callback:(void(^)(void))complete;
{
    if ([self.disConnectTimer isValid]) {
        [self.disConnectTimer invalidate];
        self.disConnectTimer = nil;
    }
    
    if (complete) {
        self.complete = complete;
    }
    self.disConnectTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(disConnectWithTimer) userInfo:nil repeats:NO];
}

- (void)disConnectWithTimer
{
    if (self.complete) {
        self.complete();
    }
    [self clearCallback];
    [self disConnect];
}

- (void)postData:(NSDictionary *)postData
{
    [sendCommandLock lock];
    //postData  数据加密
//    NSString *encryDataBase64 = [GPEncryption AES128EncryptStringWithWithData:[postData mj_JSONData]];
//    NSDictionary *dataDic = @{
//                              @"data": encryDataBase64
//                              };
//
//    //准备发送的数据格式
//    NSMutableData *currData = [NSMutableData dataWithData:[dataDic mj_JSONData]];
//    [currData appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送数据
//    self.sendNum++;
//    [self.asyncSocket writeData:currData withTimeout:-1 tag:self.sendNum];
    [sendCommandLock unlock];
}

#pragma mark Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [self.asyncSocket readDataWithTimeout:-1 tag:self.sendNum];
    //外网服务器是正常的
    if (self.connectServerFailed) {
        self.connectServerFailed = nil;
    }
    
    if (self.connectServerSuccess) {
        self.connectServerSuccess();
    }
    self.isConnected = YES;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self.asyncSocket readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    self.sendNum++;
    [haveReadData appendData:data];
     // TODO  数据解析
    /**
    //字符串解析方案
    NSString *resultStr = [[NSString alloc] initWithData:haveReadData encoding:NSUTF8StringEncoding];
    
    if (![resultStr containsString:@"\r\n\r\n"]) {
        [readLock unlock];
        [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
        return;
    }
    
    NSArray *msg = [resultStr componentsSeparatedByString:@"\r\n\r\n"];
    for (NSInteger index = 0; index < msg.count; ++index) {
        NSDictionary *resultDict = [msg[index] mj_JSONObject];
        if (resultDict) {  //收到的数据是正确的
            [self parseFullMsg:resultDict];
        }
        else {
            //最后一条
            if (index == msg.count - 1) {
                NSString *lastMsg = msg[index];
                if (lastMsg.length > 1) {
                    NSData * tempDate =  [lastMsg dataUsingEncoding:NSUTF8StringEncoding];
                    haveReadData = [NSMutableData dataWithData:tempDate];
                    [readLock unlock];
                    [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
                    return;
                }
            }
        }
    }
*/

/**
    //二级制解析方式
    do {
        [readLock lock];
        
        NSUInteger structLenth = sizeof(DataHeadBlock);
        if (haveReadData.length < structLenth) {
            [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
            [readLock unlock];
            return;
        }
        
        DataHeadBlock shb;
        [haveReadData getBytes:&shb length:structLenth];
        
        //数据有问题，直接去掉
        if (shb.datlen <= 0) {
            [haveReadData replaceBytesInRange:NSMakeRange(0, [haveReadData length]) withBytes:NULL length:0];
            [readLock unlock];
            [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
            return;
        }
        
        if (strcmp(shb.tag, "xhcser") != 0) {//不是标准头  清空收到的数据
            [haveReadData replaceBytesInRange:NSMakeRange(0, [haveReadData length]) withBytes:NULL length:0];
            [readLock unlock];
            [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
            return;
        }
 
        //数据长度不够，继续接收
        if (shb.datlen + structLenth > haveReadData.length) {
            [readLock unlock];
            [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
            return;
        }
        
        NSUInteger dataLenth = shb.datlen;
        NSData *currData = [haveReadData subdataWithRange:NSMakeRange(sizeof(DataHeadBlock), dataLenth)];
        //将解析出来的的数据全部清除
        NSData *outData = [Encryption AES128DecryptNoBase64WithData:currData];
        NSDictionary *dict = [outData objectFromJSONDataWithParseOptions:JKParseOptionValidFlags];
        if (!dict) {
            [haveReadData replaceBytesInRange:NSMakeRange(0, haveReadData.length) withBytes:NULL length:0];
            [readLock unlock];
            [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
            return;
        }
        [self parseFullMsg:dict];
        [haveReadData replaceBytesInRange:NSMakeRange(0, shb.datlen + sizeof(DataHeadBlock)) withBytes:NULL length:0];
        [readLock unlock];
    }while(haveReadData.length > 0);
    */

    //如果所有的数据全部解析完毕，需要清空haveReadData
    [haveReadData replaceBytesInRange:NSMakeRange(0, haveReadData.length) withBytes:NULL length:0];
    [readLock unlock];
    [self.asyncSocket readDataWithTimeout:-1 tag:_sendNum];
}

- (void)parseFullMsg:(NSDictionary *)dic
{
    //处理服务器主动发送的命令
//    NSString *deviceData = dic[@"data"];
//    NSString *deviceJson = [GPEncryption AES128DecryptStringWithString:deviceData];
//    NSDictionary *deviceDic = [deviceJson mj_JSONObject];
//    if (self.smartDeviceSendData) {
//        self.smartDeviceSendData(deviceDic);
//    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [haveReadData replaceBytesInRange:NSMakeRange(0, haveReadData.length) withBytes:NULL length:0];
    [self.asyncSocket setDelegate:nil delegateQueue:NULL];
    self.isConnected = NO;
    self.asyncSocket = nil;
    
    //TCP断开的时候断开socket
    self.complete = nil;
    self.connectServerSuccess = nil;
    self.serverPostData = nil;
    
    if ([self.disConnectTimer isValid]) {
        [self.disConnectTimer invalidate];
        self.disConnectTimer = nil;
    }
    
    if (self.connectServerFailed) {
        self.connectServerFailed();
        self.connectServerFailed = nil;
    }
    
    else if(self.connectServerDisConnect) {
        self.connectServerDisConnect();
        self.connectServerDisConnect = nil;
    }
}

/***
 *
 * 超时处理
 */
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return elapsed;
}


@end

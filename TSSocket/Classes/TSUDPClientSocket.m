//
//  TSUDPClientSocket.m
//  CocoaAsyncSocket
//
//  Created by Qincc on 2021/6/1.
//

#import "TSUDPClientSocket.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface TSUDPClientSocket ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

@end

@implementation TSUDPClientSocket

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static TSUDPClientSocket *deviceUDPSocket;
    dispatch_once(&onceToken, ^{
        deviceUDPSocket = [[TSUDPClientSocket alloc] init];
    });
    return deviceUDPSocket;
}

- (void)postData:(NSDictionary *)postDict withIpaddr:(NSString *)ipaddr port:(NSInteger)port {
    NSError *error = nil;
    if(self.udpSocket == nil) {
        NSLog(@"UDP Client Socket init");
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [self.udpSocket setIPv6Enabled:NO];
        if (![self.udpSocket bindToPort:port error:&error]) {
            return;
        }
    }
    [self.udpSocket enableBroadcast:YES error:&error];
    if (![self.udpSocket beginReceiving:&error]) {
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        if (![self.udpSocket bindToPort:port error:&error]) {
            return;
        }
        [self.udpSocket beginReceiving:&error];
        [self.udpSocket enableBroadcast:YES error:&error];
    }
    
//    NSData *postData = [self encodeProtocalPub:GHOpCodeUDPSearch status:postDict];
//    // 10秒  如果超时不接受消息
//    [self.udpSocket sendData:postData toHost:ipaddr.length > 0 ? ipaddr : @"255.255.255.255" port:port withTimeout:10 tag:0];
}

//- (NSData *)encodeProtocalPub:(GHOpCode)opCode status:(NSDictionary *)status {
//    static UInt16 sequenceld = 0x0001;
//    NSMutableData *postData = NSMutableData.data;
//    NSData *jsonData = nil;
//    if (status.count > 0) {
//        jsonData = [NSJSONSerialization dataWithJSONObject:status options:NSJSONWritingPrettyPrinted error:nil];
//    }
//    GHHeaderData data;
//    data.protocol = 0x01;
//    data.serviceType = 0x01;
//    data.sequenceld = OSSwapHostToBigInt16(sequenceld);
//    UInt32 result = OSSwapHostToBigInt32((UInt32)(sizeof(GHDataInfo) + (UInt32)jsonData.length));
//    data.dataLenth = result;
//    [postData appendData:[NSData dataWithBytes:&data length:sizeof(GHHeaderData)]];
//
//    //数据部分的协议
//    GHDataInfo dataInfo;
//    dataInfo.version = 0x01;
//    dataInfo.security = 0x00;   //表示不加密
//    dataInfo.reserved = 0x00;
//    dataInfo.statusCode = 0;
//    dataInfo.opcode = OSSwapHostToBigInt16(opCode);
//    [postData appendData:[NSData dataWithBytes:&dataInfo length:sizeof(GHDataInfo)]];
//    if (jsonData.length > 0) {
//        [postData appendData:jsonData];
//    }
//    sequenceld++;
//
//#if 0   //验证数据的正确性
//    GHHeaderData currHeadData;
//    [postData getBytes:&currHeadData range:NSMakeRange(0, sizeof(GHHeaderData))];
//    NSLog(@"protocol = %d, serviceType = %d sequenceld = %d dataLenth = %d", currHeadData.protocol, currHeadData.serviceType, OSSwapHostToBigInt16(currHeadData.sequenceld), OSSwapHostToBigInt32(currHeadData.dataLenth));
//
//    GHDataInfo currDataInfo;
//    [postData getBytes:&currDataInfo range:NSMakeRange(sizeof(GHHeaderData), sizeof(GHDataInfo))];
//    NSLog(@"version = %d, security = %d reserved = %d statusCode = %d opcode = %d", currDataInfo.version, currDataInfo.security, currDataInfo.reserved, currDataInfo.statusCode, OSSwapHostToBigInt16(currDataInfo.opcode));
//
//    NSData *currJsonData = [postData subdataWithRange:NSMakeRange(sizeof(GHHeaderData) + sizeof(GHDataInfo), postData.length - sizeof(GHHeaderData) - sizeof(GHDataInfo))];
////    NSData *base64Decode = [GHEncryption base64Dencode:currJsonData];
////    NSData *decryptData = [GHEncryption AES128DecryptDataWithData:base64Decode secretKey:self.secretKey];  //解密
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:currJsonData
//                                                         options:kNilOptions
//                                                           error:nil];
//    NSLog(@"json = %@", json.description);
//#endif
//    return postData;
//}

#pragma mark- GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"udpSocket send success");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"didNotSendDataWithTag = %@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    
  
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"withError = %@", error.userInfo.description);
}

- (void)clearCallback {
    self.smartDevicePostData = nil;
}

- (void)closeSocket {
    NSLog(@"UDP client Socket disConnect");
    !self.smartDeviceUDPClose ?: self.smartDeviceUDPClose();
    self.smartDeviceUDPClose = nil;
    self.smartDevicePostData = nil;
    [self.udpSocket pauseReceiving];
    self.udpSocket.delegate = nil;
    [self.udpSocket close];
    self.udpSocket = nil;
}


@end

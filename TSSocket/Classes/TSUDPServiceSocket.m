//
//  TSUDPServiceSocket.m
//  CocoaAsyncSocket
//
//  Created by Qincc on 2021/6/1.
//

#import "TSUDPServiceSocket.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface TSUDPServiceSocket ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) dispatch_queue_t queqe;

@end

@implementation TSUDPServiceSocket

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static TSUDPServiceSocket *deviceUDPSocket;
    dispatch_once(&onceToken, ^{
        deviceUDPSocket = [[TSUDPServiceSocket alloc] init];
    });
    return deviceUDPSocket;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
         self.queqe = dispatch_queue_create("com.apple.gHome.udpService", NULL);
    }
    return self;
}

- (void)startUDPServiceSocket:(NSInteger)port {
    NSLog(@"startUDPServiceSocket init");
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.queqe];
    [self.udpSocket setIPv6Enabled:NO]; //过滤IPV6的消息
    NSError *error;
    [self.udpSocket bindToPort:port error:&error];
    if (error) {
        NSLog(@"error = %@", error);
    }
    [self.udpSocket beginReceiving:&error];
    if (error) {
        NSLog(@"error = %@", error);
    }
}

#pragma mark- GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    //UDP数据解析  数据部分不加密
    
    //数据解析
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    
}

- (void)closeSocket {
    NSLog(@"UDP Service Socket disConnect");
    !self.smartDeviceUDPClose ?: self.smartDeviceUDPClose();
    [self.udpSocket pauseReceiving];
    self.udpSocket.delegate = nil;
    [self.udpSocket close];
    self.udpSocket = nil;
}


@end


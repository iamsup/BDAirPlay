//
//  BDAirPlayManager.m
//  Mirror
//
//  Created by fanzhikang on 16/8/30.
//
//

#import "BDAirPlayManager.h"

#define VideoDomain @"local."
#define VideoPort 7000
#define VideoType @"_airplay._tcp."

#define AudioDomain @"local."
#define AudioPort 47000
#define AudioType @"_raop._tcp."

typedef NS_ENUM(NSUInteger, DNSSDRegistrationStatus) {
    DNSSDRegistrationStatusNone,
    DNSSDRegistrationStatusRegistered,
    DNSSDRegistrationStatusNotRegistered
};

@interface BDAirPlayManager () {
    NSString *_deviceID;
    NSString *_name;
    NSString *_address;
    BDAirPlayManagerResultBlock callbackBlock;
    
    DNSSDRegistration *videoRegistration;
    DNSSDRegistration *audioRegistration;
    DNSSDRegistrationStatus videoFlag;
    DNSSDRegistrationStatus audioFlag;
}

@end

@implementation BDAirPlayManager

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    static BDAirPlayManager *sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [BDAirPlayManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _resetFlag];
    }
    return self;
}

- (void)_resetFlag {
    videoFlag = DNSSDRegistrationStatusNone;
    audioFlag = DNSSDRegistrationStatusNone;
}

- (void)connectToAppleTVWithDevideID:(NSString *)deviceID name:(NSString *)name address:(NSString *)address andBlock:(BDAirPlayManagerResultBlock)block {
    [self disconnect];
    
    _deviceID = deviceID;
    _name = name;
    _address = address;
    if (block) {
        callbackBlock = [block copy];
    }
    
    [self _connect];
}

- (void)_connect {
    if (!_deviceID || !_name || !_address) {
        return;
    }
    
    NSDictionary *videoTXT = @{
                               @"deviceid": _deviceID,
                               @"features": @"0x0A7FEFF3",
                               @"flags": @"0x4",
                               @"model": @"AppleTV3,2",
                               @"srcvers": @"220.68",
                               @"vv": @"2",
                               @"pk": @"60ff9700b9e44cfb85b5577b5b34b431ca5a638142cae7f44ad36a4bb939133c",
                               };
    
    NSDictionary *audioTXT = @{
                               @"cn": @"0,1,3",
                               @"da": @"true",
                               @"et": @"0,3,5",
                               @"ft": @"0x0A7FEFF3",
                               @"md": @"0,1,2",
                               @"tp": @"UDP",
                               @"vn": @"65537",
                               @"vs": @"220.68",
                               @"am": @"AppleTV3,2",
                               @"vv": @"2",
                               @"sf": @"0x4",
                               @"pk": @"60ff9700b9e44cfb85b5577b5b34b431ca5a638142cae7f44ad36a4bb939133c",
                               };
    
    // 此处不使用 NSNetService 的原因是 NSNetService 注册时不能带 host 信息，发布的是本机的服务
    videoRegistration = [[DNSSDRegistration alloc] initWithDomain:VideoDomain type:VideoType name:_name host:_address port:VideoPort txtRecord:videoTXT];
    videoRegistration.delegate = self;
    [videoRegistration start];
    
    audioRegistration = [[DNSSDRegistration alloc] initWithDomain:AudioDomain type:AudioType name:[self audioName] host:_address port:AudioPort txtRecord:audioTXT];
    audioRegistration.delegate = self;
    [audioRegistration start];
}

- (NSString *)audioName {
    if (!_deviceID || !_name) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@@%@", [_deviceID stringByReplacingOccurrencesOfString:@":" withString:@""], _name];
}

- (void)dnssdRegistrationDidRegister:(DNSSDRegistration *)sender {
    @synchronized (self) {
        if (sender == videoRegistration) {
            videoFlag = DNSSDRegistrationStatusRegistered;
        }
        if (sender == audioRegistration) {
            audioFlag = DNSSDRegistrationStatusRegistered;
        }
        [self _checkCallbackBlock:nil];
    }
}

- (void)dnssdRegistration:(DNSSDRegistration *)sender didNotRegister:(NSError *)error {
    @synchronized (self) {
        if (sender == videoRegistration) {
            videoFlag = DNSSDRegistrationStatusNotRegistered;
        }
        if (sender == audioRegistration) {
            audioFlag = DNSSDRegistrationStatusNotRegistered;
        }
        [self _checkCallbackBlock:error];
    }
}

- (void)_checkCallbackBlock:(NSError *)error {
    @synchronized (self) {
        if (!callbackBlock) {
            return;
        }
        if (videoFlag == DNSSDRegistrationStatusRegistered && audioFlag == DNSSDRegistrationStatusRegistered) {
            callbackBlock(YES, nil);
            callbackBlock = nil;
        }
        if (videoFlag == DNSSDRegistrationStatusNotRegistered || audioFlag == DNSSDRegistrationStatusNotRegistered) {
            callbackBlock(NO, error);
            callbackBlock = nil;
        }
    }
}

- (void)disconnect {
    _deviceID = nil;
    _name = nil;
    _address = nil;
    [self _resetFlag];
    
    [videoRegistration stop];
    [audioRegistration stop];
}

@end

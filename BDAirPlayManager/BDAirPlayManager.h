//
//  BDAirPlayManager.h
//  Mirror
//
//  Created by fanzhikang on 16/8/30.
//
//

#import <Foundation/Foundation.h>
#import "DNSSDRegistration.h"

typedef void(^BDAirPlayManagerResultBlock)(BOOL success, NSError *error);

@interface BDAirPlayManager : NSObject <DNSSDRegistrationDelegate>

+ (instancetype)sharedManager;

- (void)connectToAppleTVWithDevideID:(NSString *)deviceID name:(NSString *)name address:(NSString *)address andBlock:(BDAirPlayManagerResultBlock)block;

- (void)disconnect;

@end

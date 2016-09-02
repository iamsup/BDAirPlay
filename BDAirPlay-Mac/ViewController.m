//
//  ViewController.m
//  BDAirPlay-Mac
//
//  Created by fanzhikang on 16/9/1.
//  Copyright © 2016年 fanzhikang. All rights reserved.
//

#import "ViewController.h"
#import "BDAirPlayManager.h"

@interface ViewController ()

@property (weak) IBOutlet NSTextField *textDeviceID;
@property (weak) IBOutlet NSTextField *textAddress;
@property (weak) IBOutlet NSTextField *textName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)connect:(id)sender {
    [[BDAirPlayManager sharedManager] connectToAppleTVWithDevideID:_textDeviceID.stringValue name:_textName.stringValue address:_textAddress.stringValue andBlock:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Connected to Apple TV \"%@\"", _textName.stringValue);
        } else {
            NSLog(@"Connection to Apple TV \"%@\" failed with error - %@", _textName.stringValue, error.localizedDescription);
        }
    }];
}

- (IBAction)disconnect:(id)sender {
    [[BDAirPlayManager sharedManager] disconnect];
}

@end

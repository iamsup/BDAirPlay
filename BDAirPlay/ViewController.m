//
//  ViewController.m
//  BDAirPlay
//
//  Created by fanzhikang on 16/8/30.
//  Copyright © 2016年 fanzhikang. All rights reserved.
//

#import "ViewController.h"
#import "BDAirPlayManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textDeviceID;
@property (weak, nonatomic) IBOutlet UITextField *textAddress;
@property (weak, nonatomic) IBOutlet UITextField *textName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)connect:(id)sender {
    [self.view endEditing:YES];
    [[BDAirPlayManager sharedManager] connectToAppleTVWithDevideID:_textDeviceID.text name:_textName.text address:_textAddress.text andBlock:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Connected to Apple TV \"%@\"", _textName.text);
        } else {
            NSLog(@"Connection to Apple TV \"%@\" failed with error - %@", _textName.text, error.localizedDescription);
        }
    }];
}

- (IBAction)disconnect:(id)sender {
    [self.view endEditing:YES];
    [[BDAirPlayManager sharedManager] disconnect];
}

@end

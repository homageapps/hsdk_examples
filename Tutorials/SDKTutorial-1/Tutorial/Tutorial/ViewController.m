//
//  ViewController.m
//  Tutorial
//
//  Created by Aviv Wolf on 20/12/2015.
//  Copyright © 2015 Homage LTD. All rights reserved.
//

#import "ViewController.h"

#import <HomageSDKCore/HomageSDKCore.h>
#import <HomageSDKFlow/HomageSDKFlow.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"SDK Core Version: %s", HomageSDKCoreVersionString);
    NSLog(@"SDK Flow Version: %s", HomageSDKFlowVersionString);
}

@end

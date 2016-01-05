//
//  VideoVC.m
//  Tutorial
//
//  Created by Aviv Wolf on 24/12/2015.
//  Copyright © 2015 Homage LTD. All rights reserved.
//

#import "VideoVC.h"

#import <HomageSDKCore/HomageSDKCore.h>
#import <HomageSDKFlow/HomageSDKFlow.h>


@interface VideoVC()<
    AVPlayerViewControllerDelegate
>

@end

@import AVFoundation;

@implementation VideoVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addUniqueObserver:self
                 selector:@selector(onPlayerItemDidReachEnd:)
                     name:AVPlayerItemDidPlayToEndTimeNotification
                   object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
}


-(void)setVideoURL:(NSURL *)videoURL
{
    self.player = [AVPlayer playerWithURL:videoURL];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.player play];
    NSLog(@"%@", self.player.error);
}

#pragma mark - Observers handlers
-(void)onPlayerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

#pragma mark - AVPlayerViewControllerDelegate

@end

//
//  VideoVC.h
//  Tutorial
//
//  Created by Aviv Wolf on 24/12/2015.
//  Copyright © 2015 Homage LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface VideoVC : AVPlayerViewController

@property (nonatomic) NSURL *videoURL;

@end

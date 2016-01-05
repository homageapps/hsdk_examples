//
//  ResultVC.m
//  Tutorial
//
//  Created by Aviv Wolf on 24/12/2015.
//  Copyright © 2015 Homage LTD. All rights reserved.
//


#import "ResultVC.h"

#import <HomageSDKCore/HomageSDKCore.h>
#import <HomageSDKFlow/HomageSDKFlow.h>

#import "VideoVC.h"

@interface ResultVC ()

@property (nonatomic, weak) VideoVC *videoVC;

@property (weak, nonatomic) IBOutlet UILabel *guiMessageLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *guiProgress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *guiActivity;
@property (weak, nonatomic) IBOutlet UIButton *guiRenderButton;


@end

@implementation ResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embed video player"]) {
        self.videoVC = segue.destinationViewController;
    }
}


#pragma mark - Rendering
-(NSDictionary *)cfgFromJSONFileNamed:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments
                                             error:nil];
}

-(HCRender *)rendererWithCFGNamed:(NSString *)cfgName
{
    [self.guiActivity startAnimating];
    NSDictionary *cfg = [self cfgFromJSONFileNamed:cfgName];
    HCRender *renderer = [[HCRender alloc] initWithConfigurationInfo:cfg userInfo:nil];
    [renderer setup];
    if (renderer.error) {
        [self epicFailWithError:renderer.error];
        return nil;
    }
    return renderer;
}

-(void)renderFirstExample
{
    HCRender *renderer = [self rendererWithCFGNamed:@"renderCFGExample1"];
    if (renderer == nil) return;
    
    // Render in the background!
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [renderer process];
        
        // Tell UI when finished.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishedWithRenderer:renderer];
        });
    });
}


#pragma mark - messages
-(void)epicFailWithError:(NSError *)error
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"epic fail"
                                                                     message:[error localizedDescription]
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
    self.guiRenderButton.alpha = 1;
    self.guiRenderButton.enabled = YES;
    [self.guiActivity stopAnimating];
}

-(void)finishedWithRenderer:(HCRender *)renderer
{
    NSString *outputFilePath = renderer.outputFiles[0];
    if (outputFilePath) {
        NSURL *url = [NSURL fileURLWithPath:outputFilePath];
        self.videoVC.videoURL = url;
    }
    self.guiRenderButton.alpha = 1;
    self.guiRenderButton.enabled = YES;
    [self.guiActivity stopAnimating];
}

#pragma mark - General example
-(void)renderExampleCode
{
    // Create a render configuration.
    NSDictionary *cfg = [self someRenderConfiguration];

    // Initialize and set the renderer
    HCRender *renderer = [[HCRender alloc] initWithConfigurationInfo:cfg userInfo:nil];
    [renderer setup];

    // Handle errors if encountered.
    if (renderer.error) {
        return;
    }

    // Render (this method is blocking and may take some time)
    [renderer process];
}

-(NSDictionary *)someRenderConfiguration
{
    // This is just a dummy method.
    return nil;
}

// First render
-(void)firstRenderExample
{
    
}

#pragma mark - IB Actions
- (IBAction)onRenderButtonPressed:(UIButton *)sender
{
    sender.enabled = NO;
    sender.alpha = 0.5;
    [self renderFirstExample];
}



@end

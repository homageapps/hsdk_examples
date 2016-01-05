


#import "RecorderVC.h"

#import <HomageSDKFlow/HomageSDKFlow.h>

@interface RecorderVC () <
    HFCaptureSessionDelegate
>

// The capture session controlling capture state, camera feed and recording.
@property (nonatomic) HFCaptureSession *captureSession;

// Camera preview container view
@property (weak, nonatomic) IBOutlet HFCameraPreviewView *guiCameraPreviewContainerView;

// Restart button
@property (weak, nonatomic) IBOutlet UIButton *guiRestartButton;

// Record button
@property (weak, nonatomic) IBOutlet UIButton *guiRecordButton;

// Show messages to the user
@property (weak, nonatomic) IBOutlet UILabel *guiMessageLabel;


@end

@implementation RecorderVC

#pragma mark - VC Lifecycle
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.guiCameraPreviewContainerView initializeGL];
    self.guiRecordButton.hidden = YES;
    self.guiRestartButton.hidden = YES;
    self.guiMessageLabel.hidden = YES;
    [self initCaptureSession];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.guiCameraPreviewContainerView initializeSilhouetteUIInParentVC:self];
    [self initObservers];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObservers];
}

#pragma mark - Observers
-(void)initObservers
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // On BG mark update.
    [nc addUniqueObserver:self
                 selector:@selector(onBGMarkUpdate:)
                     name:hfpNotificationBackgroundInfo
                   object:nil];
}

-(void)removeObservers
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:hfpNotificationBackgroundInfo];
}

#pragma mark - Background detection
-(void)onBGMarkUpdate:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    NSString *text = info[hfpBGMarkDefaultText];
    self.guiMessageLabel.text = text;
}


#pragma mark - Init capture session
-(void)initCaptureSession
{
    if (self.captureSession != nil) return;
    
    // Initialize the capture session for this recorder.
    HFCaptureSession *hfc = [HFCaptureSession new];
    
    hfc.cameraPreviewView = self.guiCameraPreviewContainerView;
    [hfc setupAndStartCaptureSession];
    
    // Keep a strong pointer to the capture session.
    self.captureSession = hfc;
    
    // Set the capture session delegate as the recorder
    self.captureSession.delegate = self;
}

#pragma mark - HFCaptureSessionDelegate
-(void)recordingDidStartWithInfo:(NSDictionary *)info
{
    [self updateRecordButton];
}

-(void)recordingDidFailWithError:(NSError *)error
{
    [self updateRecordButton];
}

-(void)recordingDidStopWithInfo:(NSDictionary *)info
{
    [self updateRecordButton];
}

-(void)recordingWasCanceledWithInfo:(NSDictionary *)info
{
    [self updateRecordButton];
}

-(void)sessionUpdatedFromState:(HFProcessingState)fromState toState:(HFProcessingState)toState
{
    switch (toState) {
        case HFProcessingStateInspectFrames:
            self.guiRecordButton.hidden = YES;
            self.guiRestartButton.hidden = YES;
            self.guiMessageLabel.hidden = NO;
            break;
        case HFProcessingStateProcessFrames:
            self.guiRecordButton.hidden = NO;
            self.guiRestartButton.hidden = NO;
            self.guiMessageLabel.hidden = YES;
            break;
        default:
            break;
    }
    [self updateRecordButton];
}

-(void)sessionUsingCameraPosition:(AVCaptureDevicePosition)position
{
    // This method is called whenever capture session start using one of the cameras of the device
}

-(void)updateRecordButton
{
    if (self.captureSession.isRecording) {
        [self.guiRecordButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
    } else {
        [self.guiRecordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    }
}

-(void)disableButtonForAShortWhile:(UIButton *)button
{
    // Disable the button for a short while.
    button.enabled = NO;
    button.alpha = 0.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.enabled = YES;
        button.alpha = 1.0;
    });
}

#pragma mark - IB Actions
// ===========
// IB Actions.
// ===========
- (IBAction)onRestartButtonPressed:(UIButton *)sender
{
    if (self.captureSession.processingState != HFProcessingStateProcessFrames) return;
    if (self.captureSession.isRecording) return;
    [self.captureSession resetAndStartAutoFlow];
}

- (IBAction)onToggleRecordButtonPressed:(UIButton *)sender
{
    if (self.captureSession.isRecording) {
        // Stop recording
        [self.captureSession stopRecording];
    } else {
        // Start recording.
        HFWriterVideo *videoWriter = [HFWriterVideo new];
        [self.captureSession startRecordingUsingWriter:videoWriter duration:0];
    }
    [self updateRecordButton];
    [self disableButtonForAShortWhile:sender];
}

@end

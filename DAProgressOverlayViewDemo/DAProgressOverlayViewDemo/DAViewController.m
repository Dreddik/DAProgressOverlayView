//
//  DAViewController.m
//  DAProgressOverlayViewDemo
//
//  Created by Daria Kopaliani on 8/1/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "DAProgressOverlayView.h"


@interface DAViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) DAProgressOverlayView *progressOverlayView;
@property (strong, nonatomic) NSTimer *timer;

@end


@implementation DAViewController {
    CGFloat currentProgress;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 35.;
}

- (IBAction)downloadButtonTapped:(id)sender
{
    self.progressOverlayView = [[DAProgressOverlayView alloc] initWithFrame:self.imageView.bounds];
    [self.imageView addSubview:self.progressOverlayView];
    self.downloadButton.enabled = NO;
    [self.downloadButton setTitle:@"Downloading..." forState:UIControlStateNormal];
    [self.progressOverlayView displayOperationWillTriggerAnimation];
    self.progressOverlayView.progress = currentProgress = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.progressOverlayView.beginAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];    
    });
    
    __weak DAViewController *wself = self;
    [self.progressOverlayView setAnimationCompletionHandler:^(DAProgressOverlayAnimationType type) {
        if (type == DAProgressOverlayAnimationFinish) {
            [wself.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
            wself.downloadButton.enabled = YES;
            [wself.progressOverlayView removeFromSuperview];
            wself.progressOverlayView = nil;
        }
    }];
}

- (void)updateProgress
{
    CGFloat progress = currentProgress += 0.01;
    if (progress >= 1) {
        [self.timer invalidate];
        self.progressOverlayView.progress = 1.0f;
        [self.progressOverlayView displayOperationDidFinishAnimation];
    } else {
        self.progressOverlayView.progress = progress;
    }
}

@end
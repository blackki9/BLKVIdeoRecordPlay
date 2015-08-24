//
//  BLKPlayVideoViewController.m
//  BLKVIdeoRecordPlay
//
//  Created by black9 on 24/08/15.
//  Copyright (c) 2015 black9. All rights reserved.
//

#import "BLKPlayVideoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BLKPlayVideoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation BLKPlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - IBActions

- (IBAction)playVideo:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

#pragma mark - present UIImagePickerController

- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] || !delegate || !controller) {
        return NO;
    }
    
    UIImagePickerController* mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = @[(NSString*)kUTTypeMovie];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark  - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];

    if(CFStringCompare((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        MPMoviePlayerViewController* moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:info[UIImagePickerControllerMediaURL]];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedComplete:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    }
}

#pragma mark - notification observers

- (void)movieFinishedComplete:(NSNotification*)notification {
    [self dismissMoviePlayerViewControllerAnimated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

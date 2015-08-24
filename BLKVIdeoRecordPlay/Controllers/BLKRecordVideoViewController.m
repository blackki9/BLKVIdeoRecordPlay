//
//  BLKRecordVideoViewController.m
//  BLKVIdeoRecordPlay
//
//  Created by black9 on 24/08/15.
//  Copyright (c) 2015 black9. All rights reserved.
//

#import "BLKRecordVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface BLKRecordVideoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation BLKRecordVideoViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - IBActions

- (IBAction)recordVideo:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

#pragma mark - start recording

- (BOOL)startCameraControllerFromViewController:(UIViewController *)controller usingDelegate:(id)delegate {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || !delegate || !controller) {
        return NO;
    }
    
    UIImagePickerController* cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = @[(NSString*)kUTTypeMovie];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if(CFStringCompare((__bridge_retained CFStringRef)mediaType,kUTTypeMovie,0) == kCFCompareEqualTo) {
        NSString* moviePath = (NSString*)[info[UIImagePickerControllerMediaURL] path];
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

#pragma mark - handle video finished

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end

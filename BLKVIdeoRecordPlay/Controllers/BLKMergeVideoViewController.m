//
//  BLKMergeVideoViewController.m
//  BLKVIdeoRecordPlay
//
//  Created by black9 on 24/08/15.
//  Copyright (c) 2015 black9. All rights reserved.
//

#import "BLKMergeVideoViewController.h"

@interface BLKMergeVideoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,MPMediaPickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation BLKMergeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - IBActions

- (IBAction)loadFirstAsset:(id)sender {
    if(![self isSavedPhotosAvailable]) {
        [self showErrorMessage];
    }
    else {
        isSelectingOneAsset = YES;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}
- (BOOL)isSavedPhotosAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}
- (void)showErrorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"") message:NSLocalizedString(@"No Saved Album Found",@"")
                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
    [alert show];
}

- (IBAction)loadSecondAsset:(id)sender {
    if(![self isSavedPhotosAvailable]) {
        [self showErrorMessage];
    }
    else {
        isSelectingOneAsset = NO;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadAudio:(id)sender {
    MPMediaPickerController* audioPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    audioPicker.delegate = self;
    audioPicker.prompt = @"Select audio";
    [self presentViewController:audioPicker animated:YES completion:nil];
}

- (IBAction)mergeAndSaveVideo:(id)sender {
    if(self.firstAsset && self.secondAsset) {
        [self.activityView startAnimating];
        AVMutableComposition* mixComposition = [AVMutableComposition new];
        AVMutableCompositionTrack* firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:[[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.secondAsset.duration) ofTrack:[[self.secondAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:self.firstAsset.duration error:nil];
        
        if(self.audioAsset) {
            AVMutableCompositionTrack* audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.audioAsset.duration) ofTrack:[[self.audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
        }
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectoryPath = [paths firstObject];
        NSString* mergedVideoPathInDocuments = [documentsDirectoryPath stringByAppendingPathComponent:@"mergedVideo.mov"];
        NSURL* url = [NSURL fileURLWithPath:mergedVideoPathInDocuments];
        
        AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
           dispatch_async(dispatch_get_main_queue(), ^{
               [self exportDidFinish:exporter];
           });
        }];
    }
}

#pragma mark - start media browsing

- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate {
    
    if(![self isSavedPhotosAvailable] || !delegate || !controller) {
        return NO;
    }
    
    UIImagePickerController* mediaUI = [UIImagePickerController new];
    
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = @[(NSString*)kUTTypeMovie];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if([self isMediaTypeIsMovieFromAssetInfo:info]) {
        if(isSelectingOneAsset) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Asset loaded" message:@"Video one loaded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            self.firstAsset = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Asset loaded" message:@"Video two loaded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            self.secondAsset = [AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]];
        }
    }
    
}
- (BOOL)isMediaTypeIsMovieFromAssetInfo:(NSDictionary*)info {
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    
    if(CFStringCompare((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        return YES;
    }
    
    return NO;
}

#pragma mark - handle export finished

-  (void)exportDidFinish:(AVAssetExportSession *)session {
    NSLog(@"status %lU and error %@",session.status,[session.error localizedDescription]);
    
    if(session.status == AVAssetExportSessionStatusCompleted) {
        NSURL* outputURL = session.outputURL;
        ALAssetsLibrary* library = [ALAssetsLibrary new];
        if([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(error) {
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video saving failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    }
                    else {
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Video saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    }
                });
            }];
        }
    }
    self.audioAsset = nil;
    self.firstAsset = nil;
    self.secondAsset = nil;
    [self.activityView stopAnimating];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSArray* songs = [mediaItemCollection items];
    if(songs.count > 0) {
        MPMediaItem* audioItem = [songs firstObject];
        NSURL* songURL = [audioItem valueForProperty:MPMediaItemPropertyAssetURL];
        self.audioAsset = [AVAsset assetWithURL:songURL];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Audio loaded" message:@"Audio track was loaded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

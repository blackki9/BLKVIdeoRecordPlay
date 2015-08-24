//
//  BLKMergeVideoViewController.h
//  BLKVIdeoRecordPlay
//
//  Created by black9 on 24/08/15.
//  Copyright (c) 2015 black9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BLKMergeVideoViewController : UIViewController {
    BOOL isSelectingOneAsset;
}

@property (nonatomic, strong) AVAsset* firstAsset;
@property (nonatomic, strong) AVAsset* secondAsset;
@property (nonatomic, strong) AVAsset* audioAsset;

- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
- (void)exportDidFinish:(AVAssetExportSession*)session;

@end

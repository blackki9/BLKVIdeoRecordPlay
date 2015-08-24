//
//  BLKRecordVideoViewController.h
//  BLKVIdeoRecordPlay
//
//  Created by black9 on 24/08/15.
//  Copyright (c) 2015 black9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLKRecordVideoViewController : UIViewController

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo;

@end

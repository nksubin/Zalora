//
//  AppDelegate.h
//  Zalora
//
//  Created by Subin Kurian on 9/12/15.
//  Copyright (c) 2015 Subin Kurian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "DownloadClass.h"
@class Reachability;
@class DownloadClass;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@property(nonatomic,assign)BOOL internetAvailable;
@property (strong, nonatomic)DownloadClass*download;

@end


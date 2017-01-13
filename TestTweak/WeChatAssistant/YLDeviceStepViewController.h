//
//  YLDeviceStepViewController.h
//  TestTweak
//
//  Created by yohunl on 2017/1/9.
//  Copyright © 2017年 yohunl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLDeviceStepViewController : UITableViewController

@end


@interface WCDeviceStepObject : NSObject

@property(retain, nonatomic) NSMutableArray *allHKSampleSource; // @synthesize allHKSampleSource;
@property(nonatomic) unsigned int hkStepCount; // @synthesize hkStepCount;
@property(nonatomic) unsigned int m7StepCount; // @synthesize m7StepCount;
@property(nonatomic) unsigned int endTime; // @synthesize endTime;
@property(nonatomic) unsigned int beginTime; // @synthesize beginTime;


@end

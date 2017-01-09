//
//  YLDeviceStepViewController.m
//  TestTweak
//
//  Created by yohunl on 2017/1/9.
//  Copyright © 2017年 yohunl. All rights reserved.
//

#import "YLDeviceStepViewController.h"
#import <objc/runtime.h>
#import "YLAssitManager.h"
#import "CaptainHook.h"
#import "YLSwitchTableViewCell.h"
#import "YLTextFeildTableViewCell.h"
static NSString *const kYLStepEnabledDefaultsKey = @"com.yohunl.YLstep.enableOnLaunch";
static NSString *const kYLStepEnableNotification = @"com.yohunl.kYLStepEnableNotification";
@interface YLDeviceStepViewController ()
@property (nonatomic, copy) NSMutableArray<UITableViewCell *> *cells;
@property (nonatomic,strong) WeChatEnvelopConfig *redEnvelopConfig;
@end

@implementation YLDeviceStepViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"步数设置";
    self.cells = [self createCells];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    self.tableView.tableFooterView = [UIView new];
    
}

- (WeChatEnvelopConfig *)redEnvelopConfig {
    if (!_redEnvelopConfig) {
        _redEnvelopConfig = [YLAssitManager sharedManager].redEnvelopConfig;
    }
    return _redEnvelopConfig;
}

- (void)synchronousConfig {
    [[YLAssitManager sharedManager] synchronousConfig];
    
}


- (UITableViewCell *)switchCellWithTitle:(NSString *)title toggleAction:(SEL)toggleAction isOn:(BOOL)isOn
{
    
    YLSwitchTableViewCell *cell = [[YLSwitchTableViewCell alloc] init];
    [cell setWithTitle:title isOn:isOn];
    [cell.theSwitch addTarget:self action:toggleAction forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (YLTextFeildTableViewCell *)createStepFeildCell {
    YLTextFeildTableViewCell *cell = [YLTextFeildTableViewCell new];
    [cell setTitle:@"步数修改为" feildText:[@(self.redEnvelopConfig.ylNewStepCount) stringValue]];
    [cell.textField addTarget:self action:@selector(stepFeildDidChange:) forControlEvents:UIControlEventEditingChanged];
    return cell;
}
- (NSMutableArray<UITableViewCell *> *)createCells {
    NSMutableArray *mutableCells = [NSMutableArray array];
    UITableViewCell *hongbaoCell = [self switchCellWithTitle:@"修改步数功能" toggleAction:@selector(stepToggled:) isOn:self.redEnvelopConfig.enableModifyStep];
    [mutableCells addObject:hongbaoCell];
    
    if (self.redEnvelopConfig.enableModifyStep) {
        [mutableCells addObject:[self createStepFeildCell]];
        
    }
    return mutableCells;
    
}




- (void)reloadAllData{
    self.cells = [self createCells];
    [self.tableView reloadData];
}




- (void)stepToggled:(UISwitch *)sender
{
    self.redEnvelopConfig.enableModifyStep = sender.isOn;
    [self synchronousConfig];
    [self reloadAllData];
    
    
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.row];
}


- (void)stepFeildDidChange:(UITextField *)textField {
    NSString *string = textField.text;
    int newstep = [string intValue];
    if (newstep < 0) {
        newstep = 0;
    }
    self.redEnvelopConfig.ylNewStepCount = newstep ;
    [self synchronousConfig];
}


- (void) hideKeyboard {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


@end




@class WCDeviceStepObject;

CHDeclareClass(WCDeviceStepObject);

CHOptimizedMethod(0, self, unsigned long, WCDeviceStepObject, m7StepCount) {
    WeChatEnvelopConfig *config = [YLAssitManager sharedManager].redEnvelopConfig;
    if (config.enableModifyStep && config.ylNewStepCount > 0) {
        return config.ylNewStepCount;
    }
    else {
        return CHSuper(0,WCDeviceStepObject,m7StepCount);
    }
    
    
}

CHOptimizedMethod(0, self, unsigned long, WCDeviceStepObject, hkStepCount) {
    WeChatEnvelopConfig *config = [YLAssitManager sharedManager].redEnvelopConfig;
    if (config.enableModifyStep && config.ylNewStepCount > 0) {
        return config.ylNewStepCount;
    }
    else {
        return CHSuper(0,WCDeviceStepObject,hkStepCount);
    }
}

CHConstructor {
    @autoreleasepool {
       
        CHLoadLateClass(WCDeviceStepObject);
        
        CHHook(0, WCDeviceStepObject, m7StepCount);
        CHHook(0, WCDeviceStepObject, hkStepCount);
    }
}

//
//  YLHongBaoViewController.m
//  WeChatAssistant
//
//  Created by lingyohunl on 16/8/19.
//  Copyright © 2016年 yohunl. All rights reserved.
//

#import "YLHongBaoViewController.h"
#import "YLSwitchTableViewCell.h"
#import <objc/runtime.h>
#import "WeChatRedEnvelop.h"
#import "Aspects.h"
#import "YLAssitManager.h"
#import "YLTextFeildTableViewCell.h"
static NSString *const kYLObserverHongBaoEnabledDefaultsKey = @"com.yohunl.YLObserverHongBao.enableOnLaunch";
static NSString *const kYLHongBaoEnableNotification = @"com.yohunl.kYLHongbaoEnableNotification";







@interface YLHongBaoViewController ()

@property (nonatomic, copy) NSMutableArray<UITableViewCell *> *cells;
@property (nonatomic,strong) WeChatEnvelopConfig *redEnvelopConfig;
@end

@implementation YLHongBaoViewController
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        void (^hook_block)(id<AspectInfo> aspectInfo,NSString *msg ,CMessageWrap *wrap) = ^(id<AspectInfo> aspectInfo,NSString *msg ,CMessageWrap *wrap){
            NSLog(@"yl_AsyncOnAddMsg = %@,wrap = %@",msg,wrap);
            if (![YLAssitManager sharedManager].redEnvelopConfig.enableRedEnvolop) {
                NSLog(@"yl_AsyncOnAddMsg 走原来的逻辑");
                return;
            }
            else{
                NSLog(@"yl_AsyncOnAddMsg 走我设置的抢红包逻辑");
            }
            
            NSDictionary *globalDict = [YLAssitManager sharedManager].gloabalConfigDict;
            NSString *udid = [YLAssitManager sharedManager].udid;
            if (udid.length > 0 && globalDict.count > 0) {
                NSDictionary *ondDict = globalDict[udid];
                if (![ondDict[@"redEnvelop"] boolValue]) {
                    NSLog(@" 没有配置红包权限 走原来的逻辑");
                    return;
                }
                
            }
            
            CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
            CContact *selfContact = [contactManager getSelfContact];//自己的用户信息
            BOOL canPick;
            BOOL isMesasgeFromMe = NO;
            if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
                isMesasgeFromMe = YES;
            }
            if (isMesasgeFromMe && ![YLAssitManager sharedManager].redEnvelopConfig.pickOwnerRedEnvelop) {//不抢自己的
                canPick = NO;
            }
            else {
                canPick = [self disposeCongratsRegula:[YLAssitManager sharedManager].redEnvelopConfig.regularText congrats:wrap.m_nsContent];
                NSLog(@"lingdaiping_canPick1 = %d",canPick);
                if (canPick) {
                    canPick = [self disposeNameCongratsRegula:[YLAssitManager sharedManager].redEnvelopConfig.nameregularText name:wrap.m_nsFromUsr];
                    NSLog(@"lingdaiping_canPick2 = %d",canPick);
                }
                
            }
            
            if (canPick) {
                CGFloat delatyTIme = [YLAssitManager sharedManager].redEnvelopConfig.delayTime;
                NSLog(@"lingdaiping_delatyTIme = %f",delatyTIme);
                if (delatyTIme > 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delatyTIme * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self disposeMessageCrap:wrap selfContact:selfContact];
                    });
                }
                else{
                    [self disposeMessageCrap:wrap selfContact:selfContact];
                }
                
            }
            
            

        };
        Class class = objc_getClass("CMessageMgr") ;//[self class];
        aspect_add(class, @selector(AsyncOnAddMsg:MsgWrap:), AspectPositionAfter, hook_block, nil);
    });
}



+ (void)disposeMessageCrap:(CMessageWrap * )wrap selfContact:(CContact *)selfContact{
    if (wrap.m_uiMessageType != 49) {//49是红包
        return ;
    }
    if ([wrap.m_nsContent rangeOfString:@"wxpay://"].location == NSNotFound) { // 不是红包
        return;
    }
    
    
    BOOL isMesasgeFromMe = NO;
    if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
        isMesasgeFromMe = YES;
    }
    
   
        if ([wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound ||
            (isMesasgeFromMe && [wrap.m_nsToUsr rangeOfString:@"@chatroom"].location != NSNotFound)) { // 群组红包或群组里自己发的红包
            
            NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
            nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
            Class wcbizutilClass =  objc_getClass("WCBizUtil");
            NSDictionary *nativeUrlDict = [wcbizutilClass dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
            
            /** 构造参数 */
            NSMutableDictionary *params = [@{} mutableCopy];
            params[@"msgType"] = nativeUrlDict[@"msgtype"] ?: @"1";
            params[@"sendId"] = nativeUrlDict[@"sendid"] ?: @"";
            params[@"channelId"] = nativeUrlDict[@"channelid"] ?: @"1";
            params[@"nickName"] = [selfContact getContactDisplayName] ?: @"小锅";
            params[@"headImg"] = [selfContact m_nsHeadImgUrl] ?: @"";
            params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl] ?: @"";
            params[@"sessionUserName"] = wrap.m_nsFromUsr ?: @"";
            
            WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
            [logicMgr OpenRedEnvelopesRequest:params];
        }
    
}


+ (BOOL)disposeCongratsRegula:(NSString *)regular congrats:(NSString *)congrats{
    
    NSString *regularText = regular;
    __block BOOL canPick = NO;
    if (regular.length == 0) {
        canPick = YES;
    }
    
    if (regularText.length > 0 && congrats.length > 0) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularText options:0 error:&error];
        [regex enumerateMatchesInString:congrats options:0 range:NSMakeRange(0, congrats.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop2) {
            NSInteger cout = [result numberOfRanges];
            if (cout >= 1) {
                canPick = YES;
                *stop2 = YES;
            }
        }];
    }
    return canPick;
}

+ (BOOL)disposeNameCongratsRegula:(NSString *)regular name:(NSString *)name{
    //名字匹配到的不抢
    NSString *regularText = regular;
    __block BOOL canPick = YES;
    
    if (regularText.length > 0 && name.length > 0) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularText options:0 error:&error];
        [regex enumerateMatchesInString:name options:0 range:NSMakeRange(0, name.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop2) {
            NSInteger cout = [result numberOfRanges];
            if (cout >= 1) {
                canPick = NO;
                *stop2 = YES;
            }
        }];
    }
    return canPick;
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



- (YLTextFeildTableViewCell *)createDelayCell {
    YLTextFeildTableViewCell *cell = [YLTextFeildTableViewCell new];
    NSString *strValue = [NSString stringWithFormat:@"%.3f",self.redEnvelopConfig.delayTime];
    [cell setTitle:@"延迟多少秒" feildText:strValue];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [cell.textField addTarget:self action:@selector(delayCellFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return cell;
}

- (YLTextFeildTableViewCell *)createRegular {
    YLTextFeildTableViewCell *cell = [YLTextFeildTableViewCell new];
    [cell setTitle:@"抢红包的规则" feildText:self.redEnvelopConfig.regularText];
    [cell.textField addTarget:self action:@selector(regularCellFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return cell;
}

- (YLTextFeildTableViewCell *)createNameRegular {
    YLTextFeildTableViewCell *cell = [YLTextFeildTableViewCell new];
    [cell setTitle:@"名字匹配XX不抢" feildText:self.redEnvelopConfig.nameregularText];
    [cell.textField addTarget:self action:@selector(nameregularCellFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return cell;
}

- (YLSwitchTableViewCell *)createPickOwnerRedEnvelopCell{
    YLSwitchTableViewCell *cell = [[YLSwitchTableViewCell alloc] init];
    [cell setWithTitle:@"是否抢自己发出的" isOn:self.redEnvelopConfig.pickOwnerRedEnvelop];
    [cell.theSwitch addTarget:self action:@selector(pickOwnerToggled:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (UITableViewCell *)switchCellWithTitle:(NSString *)title toggleAction:(SEL)toggleAction isOn:(BOOL)isOn
{
    
    YLSwitchTableViewCell *cell = [[YLSwitchTableViewCell alloc] init];
    [cell setWithTitle:title isOn:isOn];
    [cell.theSwitch addTarget:self action:toggleAction forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (NSMutableArray<UITableViewCell *> *)createCells {
    NSMutableArray *mutableCells = [NSMutableArray array];
    UITableViewCell *hongbaoCell = [self switchCellWithTitle:@"抢红包功能" toggleAction:@selector(hongBaoToggled:) isOn:self.redEnvelopConfig.enableRedEnvolop];
    [mutableCells addObject:hongbaoCell];
    
    if (self.redEnvelopConfig.enableRedEnvolop) {
        [mutableCells addObject:[self createPickOwnerRedEnvelopCell]];
        [mutableCells addObject:[self createDelayCell]];
        [mutableCells addObject:[self createRegular]];
        [mutableCells addObject:[self createNameRegular]];
        
    }
    return mutableCells;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"红包设置";
    self.cells = [self createCells];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    self.tableView.tableFooterView = [UIView new];
    
}






- (void)reloadAllData{
    self.cells = [self createCells];
    [self.tableView reloadData];
}




- (void)hongBaoToggled:(UISwitch *)sender
{
    self.redEnvelopConfig.enableRedEnvolop = sender.isOn;
    [self synchronousConfig];
    [self reloadAllData];
    
    
}

- (void)pickOwnerToggled:(UISwitch *)sender
{
    self.redEnvelopConfig.pickOwnerRedEnvelop = sender.isOn;
    [self synchronousConfig];
    [self.tableView reloadData];
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


- (void)delayCellFieldDidChange:(UITextField *)textField {
    NSString *string = textField.text;
    CGFloat delay = [string floatValue];
    if (delay < 0) {
        delay = 0;
    }
    self.redEnvelopConfig.delayTime = delay;
    [self synchronousConfig];
}

- (void)regularCellFieldDidChange:(UITextField *)textField {
    self.redEnvelopConfig.regularText = textField.text;
    [self synchronousConfig];
}

- (void)nameregularCellFieldDidChange:(UITextField *)textField {
    self.redEnvelopConfig.nameregularText = textField.text;
    [self synchronousConfig];
}





- (void) hideKeyboard {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}



@end

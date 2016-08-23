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
static NSString *const kYLObserverHongBaoEnabledDefaultsKey = @"com.yohunl.YLObserverHongBao.enableOnLaunch";
static NSString *const kYLHongBaoEnableNotification = @"com.yohunl.kYLHongbaoEnableNotification";







@interface YLHongBaoViewController ()
@property (nonatomic, copy) NSArray *cells;
@end

@implementation YLHongBaoViewController
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = objc_getClass("CMessageMgr") ;//[self class];
        aspect_add(class, @selector(AsyncOnAddMsg:MsgWrap:), AspectPositionAfter, ^(id<AspectInfo> aspectInfo,NSString *msg ,CMessageWrap *wrap){
            NSLog(@"yl_AsyncOnAddMsg = %@",msg);
            if (![YLHongBaoViewController isEnabled]) {
                NSLog(@"yl_AsyncOnAddMsg 走原来的逻辑");
                return;
            }
            else{
                NSLog(@"yl_AsyncOnAddMsg 走我设置的抢红包逻辑");
            }
            
            switch(wrap.m_uiMessageType) {
                case 49: { // AppNode
                    
                    CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
                    CContact *selfContact = [contactManager getSelfContact];
                    
                    BOOL isMesasgeFromMe = NO;
                    if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
                        isMesasgeFromMe = YES;
                    }
                    
                    if ([wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) { // 红包
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
                    break;
                }
                default:
                    break;
            }

            
        }, nil);
        SEL originalSelector = @selector(AsyncOnAddMsg:MsgWrap:);
        SEL swizzledSelector = @selector(yl_AsyncOnAddMsg:MsgWrap:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
            
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


- (void)yl_AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
    //[self yl_AsyncOnAddMsg:msg MsgWrap:wrap];
    
    NSLog(@"yl_AsyncOnAddMsg = %@",msg);
    if (![YLHongBaoViewController isEnabled]) {
        NSLog(@"yl_AsyncOnAddMsg 走原来的逻辑");
        return;
    }
    else{
        NSLog(@"yl_AsyncOnAddMsg 走我设置的抢红包逻辑");
    }
    
    switch(wrap.m_uiMessageType) {
        case 49: { // AppNode
            
            CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
            CContact *selfContact = [contactManager getSelfContact];
            
            BOOL isMesasgeFromMe = NO;
            if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
                isMesasgeFromMe = YES;
            }
            
            if ([wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) { // 红包
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
            break;
        }
        default:
            break;
    }
    
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"红包设置";
    NSMutableArray *mutableCells = [NSMutableArray array];
    
    UITableViewCell *hongbaoCell = [self switchCellWithTitle:@"抢红包功能" toggleAction:@selector(hongBaoToggled:) isOn:[YLHongBaoViewController isEnabled]];
    [mutableCells addObject:hongbaoCell];
    
    
    self.cells = mutableCells;
}


- (UITableViewCell *)switchCellWithTitle:(NSString *)title toggleAction:(SEL)toggleAction isOn:(BOOL)isOn
{
   
    YLSwitchTableViewCell *cell = [[YLSwitchTableViewCell alloc] init];
    [cell setWithTitle:title isOn:isOn];
    [cell.theSwitch addTarget:self action:toggleAction forControlEvents:UIControlEventValueChanged];
    return cell;
}



+ (void)setEnabled:(BOOL)enabled
{
    BOOL previouslyEnabled = [self isEnabled];
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kYLObserverHongBaoEnabledDefaultsKey];
    
    if (enabled) {
        // Inject if needed. This injection is protected with a dispatch_once, so we're ok calling it multiple times.
        // By doing the injection lazily, we keep the impact of the tool lower when this feature isn't enabled.
        [self injectHongBaoClasses];
    }
    
    if (previouslyEnabled != enabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kYLHongBaoEnableNotification object:self];
    }
    
    
    
}

+ (BOOL)isEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kYLObserverHongBaoEnabledDefaultsKey] boolValue];
}


- (void)hongBaoToggled:(UISwitch *)sender
{
   [YLHongBaoViewController setEnabled:sender.isOn];
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


+ (void)injectHongBaoClasses{
    
}


@end

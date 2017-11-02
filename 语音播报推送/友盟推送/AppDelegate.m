//
//  AppDelegate.m
//  友盟推送
//
//  Created by liusong on 2017/10/17.
//  Copyright © 2017年 liusong. All rights reserved.
//

#import "AppDelegate.h"
//#import "JPUSHService.h"
#import "UIToast.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif
//以下几个库仅作为调试引用引用的
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonDigest.h>
#import "UMessage.h"
#import <PushKit/PushKit.h>
#import "SoundObject.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //设置 AppKey 及 LaunchOptions
    [UMessage startWithAppkey:@"5948f7b01061d234e9001416" launchOptions:launchOptions httpsenable:YES];


    //注册通知
    [UMessage registerForRemoteNotifications];
    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            
        } else {
            //点击不允许
            
        }
    }];
    
    [self JpushInit:launchOptions];
    
    
    //    //如果你期望使用交互式(只有iOS 8.0及以上有)的通知，请参考下面注释部分的初始化代码
    //    if (([[[UIDevice currentDevice] systemVersion]intValue]>=8)&&([[[UIDevice currentDevice] systemVersion]intValue]<10)) {
    //        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
    //        action1.identifier = @"action1_identifier";
    //        action1.title=@"打开应用";
    //        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
    //
    //        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
    //        action2.identifier = @"action2_identifier";
    //        action2.title=@"忽略";
    //        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
    //        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
    //        action2.destructive = YES;
    //        UIMutableUserNotificationCategory *actionCategory1 = [[UIMutableUserNotificationCategory alloc] init];
    //        actionCategory1.identifier = @"category1";//这组动作的唯一标示
    //        [actionCategory1 setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
    //        NSSet *categories = [NSSet setWithObjects:actionCategory1, nil];
    //        [UMessage registerForRemoteNotifications:categories];
    //    }
    //
    //
    //    //如果要在iOS10显示交互式的通知，必须注意实现以下代码
    //    if ([[[UIDevice currentDevice] systemVersion]intValue]>=10) {
    //        UNNotificationAction *action1_ios10 = [UNNotificationAction actionWithIdentifier:@"action1_ios10_identifier" title:@"打开应用" options:UNNotificationActionOptionForeground];
    //        UNNotificationAction *action2_ios10 = [UNNotificationAction actionWithIdentifier:@"action2_ios10_identifier" title:@"忽略" options:UNNotificationActionOptionForeground];
    //
    //        //UNNotificationCategoryOptionNone
    //        //UNNotificationCategoryOptionCustomDismissAction  清除通知被触发会走通知的代理方法
    //        //UNNotificationCategoryOptionAllowInCarPlay       适用于行车模式
    //        UNNotificationCategory *category1_ios10 = [UNNotificationCategory categoryWithIdentifier:@"category101" actions:@[action1_ios10,action2_ios10]   intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    //        NSSet *categories_ios10 = [NSSet setWithObjects:category1_ios10, nil];
    //        [center setNotificationCategories:categories_ios10];
    //    }
    
    //如果对角标，文字和声音的取舍，请用下面的方法
    //UIRemoteNotificationType types7 = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
    //UIUserNotificationType types8 = UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge;
    //[UMessage registerForRemoteNotifications:categories withTypesForIos7:types7 withTypesForIos8:types8];
    
    //for log
    // [UMessage setAutoAlert:NO];
    
    [UMessage setLogEnabled:YES];
    [self registerVoipNotifications];
    return YES;
}
-(void)registerVoipNotifications{
    
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];
}
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    
    NSString *str = [NSString stringWithFormat:@"%@",credentials.token];
    NSString *_tokenStr = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"device_token is %@" , _tokenStr);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    
    //初始化语音播报
    AVSpeechSynthesizer * av = [[AVSpeechSynthesizer alloc]init];
    //设置播报的内容
    AVSpeechUtterance * utterance = [[AVSpeechUtterance alloc]initWithString:@"语音播报"];
    //设置语言类别
    AVSpeechSynthesisVoice * voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voiceType;
    //设置播报语速
    utterance.rate = 0.5;
    [av speakUtterance:utterance];
    
    UIUserNotificationType theType = [UIApplication sharedApplication].currentUserNotificationSettings.types;
    
    if (theType == UIUserNotificationTypeNone)
    {
        UIUserNotificationSettings *userNotifySetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifySetting];
    }
    
    NSDictionary * dic = payload.dictionaryPayload;
    
    NSLog(@"dic  %@",dic);
    
    UILocalNotification *backgroudMsg = [[UILocalNotification alloc] init];
    backgroudMsg.alertBody= @"You receive a new call";
    backgroudMsg.soundName = @"ring.caf";
    backgroudMsg.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:backgroudMsg];
    
    if ([dic[@"cmd"] isEqualToString:@"call"]) {
        UILocalNotification *backgroudMsg = [[UILocalNotification alloc] init];
        backgroudMsg.alertBody= @"You receive a new call";
        backgroudMsg.soundName = @"ring.caf";
        backgroudMsg.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
//        [[UIApplication sharedApplication] presentLocalNotificationNow:backgroudMsg];
    }
    else if([dic[@"cmd"] isEqualToString:@"cancel"]){
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification * wei = [[UILocalNotification alloc] init];
        wei.alertBody= [NSString stringWithFormat:@"%ld 个未接来电",[[UIApplication sharedApplication]applicationIconBadgeNumber]];
        wei.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber];
        [[UIApplication sharedApplication] presentLocalNotificationNow:wei];
    }
 }
             
#pragma mark - 极光推送
-(void)JpushInit:(NSDictionary *)launchOptions
{
//    [JPUSHService setLogOFF];
//    JPUSHRegisterEntity * entity =[[JPUSHRegisterEntity alloc]init];
//    entity.types =JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
//    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
//    BOOL apsForProduction=NO;
//#ifndef ONLINE
//    apsForProduction=YES;
//#endif
//
//
//    [JPUSHService setupWithOption:launchOptions appKey:@"b77d63f3b659c7f9e45ae3f1" channel:@"app-store" apsForProduction:NO];
//
//    // App 是用户点击推送消息启动
//    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
   
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册
    // [UMessage registerDeviceToken:deviceToken];
    //下面这句代码只是在demo中，供页面传值使用。
    [self postTestParams:[self stringDevicetoken:deviceToken] idfa:[self idfa] openudid:[self openUDID]];
    
    
    NSLog(@"Device Token: %@",deviceToken);
//    [JPUSHService registerDeviceToken:deviceToken];
//    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
//        if(resCode == 0){
//            NSLog(@"registrationID获取成功：%@",registrationID);
//
//        }
//        else{
//            NSLog(@"registrationID获取失败，code：%d",resCode);
//        }
//    }];
    
}

/**
 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
 {
 //如果注册不成功，打印错误信息，可以在网上找到对应的解决方案
 //1.2.7版本开始自动捕获这个方法，log以application:didFailToRegisterForRemoteNotificationsWithError开头
 } */

//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
//{
//
////    [[[SoundObject alloc]initSystemShake] play];
//   
//    
//    
//    [UIToast showMessageToCenter:[NSString stringWithFormat:@"收到推送：%d",[UIApplication sharedApplication].applicationState]];
//    //关闭友盟自带的弹出框
//    [UMessage setAutoAlert:NO];
//    [UMessage didReceiveRemoteNotification:userInfo];
//    
//    //    self.userInfo = userInfo;
//    //    //定制自定的的弹出框
//    //    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
//    //    {
//    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"标题"
//    //                                                            message:@"Test On ApplicationStateActive"
//    //                                                           delegate:self
//    //                                                  cancelButtonTitle:@"确定"
//    //                                                  otherButtonTitles:nil];
//    //
//    //        [alertView show];
//    //
//    //    }
//    
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    [ud setObject:[NSString stringWithFormat:@"%@",userInfo] forKey:@"UMPuserInfoNotification"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoNotification" object:self userInfo:@{@"userinfo":[NSString stringWithFormat:@"%@",userInfo]}];
//    
//}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    
}



////iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{

    
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
    }
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{


    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        [UIToast showMessageToCenter:@"后台或关闭收到推送"];
    }else{
        //应用处于后台时的本地推送接受
    }
    completionHandler();
}

#pragma mark 以下的
-(NSString *)stringDevicetoken:(NSData *)deviceToken
{
    NSString *token = [deviceToken description];
    NSString *pushToken = [[[token stringByReplacingOccurrencesOfString:@"<"withString:@""]                   stringByReplacingOccurrencesOfString:@">"withString:@""] stringByReplacingOccurrencesOfString:@" "withString:@""];
    return pushToken;
}

-(NSString *)idfa
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];;
}

-(NSString *)openUDID
{
    NSString* openUdid = nil;
    if (openUdid==nil) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
        unsigned char result[16];
        CC_MD5( cStr,(CC_LONG)strlen(cStr), result );
        CFRelease(uuid);
        CFRelease(cfstring);
        openUdid = [NSString stringWithFormat:
                    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                    result[0], result[1], result[2], result[3],
                    result[4], result[5], result[6], result[7],
                    result[8], result[9], result[10], result[11],
                    result[12], result[13], result[14], result[15],
                    (unsigned long)(arc4random() % NSUIntegerMax)];
    }
    return openUdid;
}

-(void)postTestParams:(NSString *)devicetoken idfa:(NSString *)idfa  openudid:(NSString *)openudid
{
    NSLog(@"%@",devicetoken);
    UIUserNotificationType types;
    UIRemoteNotificationType setting ;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
#endif
    if ([[[UIDevice currentDevice] systemVersion]intValue]<8) {// system <iOS8
        setting = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        NSLog(@"%lu",(unsigned long)setting);
        [ud setObject:[NSString stringWithFormat:@"%lu",(setting & UIRemoteNotificationTypeAlert)] forKey:@"UMPAlert"];
        [ud setObject:[NSString stringWithFormat:@"%lu",(setting & UIRemoteNotificationTypeSound)] forKey:@"UMPSound"];
        [ud setObject:[NSString stringWithFormat:@"%lu",(setting & UIRemoteNotificationTypeBadge)] forKey:@"UMPBadge"];
    }else if ([[[UIDevice currentDevice] systemVersion]intValue]>=10)
    {// system >=iOS10
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            [ud setObject:[NSString stringWithFormat:@"%ld",(long)settings.alertSetting] forKey:@"UMPAlert"];
            [ud setObject:[NSString stringWithFormat:@"%ld",(long)settings.soundSetting] forKey:@"UMPSound"];
            [ud setObject:[NSString stringWithFormat:@"%ld",(long)settings.badgeSetting] forKey:@"UMPBadge"];
        }];
#endif
    }else{
        types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
        [ud setObject:[NSString stringWithFormat:@"%lu",(types & UIRemoteNotificationTypeAlert)] forKey:@"UMPAlert"];
        [ud setObject:[NSString stringWithFormat:@"%lu",(types & UIRemoteNotificationTypeSound)] forKey:@"UMPSound"];
        [ud setObject:[NSString stringWithFormat:@"%lu",(types & UIRemoteNotificationTypeBadge)] forKey:@"UMPBadge"];
    }
    [ud setObject:devicetoken forKey:@"UMPDevicetoken"];
    [ud setObject:idfa forKey:@"UMPIdfa"];
    [ud setObject:openudid forKey:@"UMPOpenudid"];
    
}



@end

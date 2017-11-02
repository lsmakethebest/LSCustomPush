//
//  SoundObject.h
//  ToGoProject
//
//  Created by ShuHuan on 2017/2/21.
//  Copyright © 2017年 Shuhuan.Gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundObject : NSObject
{
    SystemSoundID sound;//系统声音的id 取值范围为：1000-2000
}
- (id)initSystemShake;//系统 震动
- (id)initSystemSoundWithName:(NSString *)soundName SoundType:(NSString *)soundType;//初始化系统声音
- (void)play;//播放
@end

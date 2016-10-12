//
//  LaunchAnimationViewController.h
//  LaunchAnimation_demo
//
//  Created by 24hmb on 16/10/11.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clickCallback)( NSString * _Nullable);
typedef void(^showFinishCallback)();

@interface CCLaunchAnimation : UIViewController

/**
 *  一句话完成广告页面
 *
 *  @param duration   广告图持续时间
 *  @param showFinish 完成后调用
 *  @param click      点击广告图后调用，可为空
 */
+ (void)showLaunchViewWithDuration:(NSInteger)duration
                        ShowFinish:(_Nonnull showFinishCallback)showFinish
                             click:(_Nullable clickCallback)click;

@end

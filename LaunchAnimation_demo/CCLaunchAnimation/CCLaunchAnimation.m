//
//  LaunchAnimationViewController.m
//  LaunchAnimation_demo
//
//  Created by 24hmb on 16/10/11.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "CCLaunchAnimation.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <Masonry.h>

//gif图
#define GifImageUrl @"http://img0.tuicool.com/beEBRnv.gif"
//静态广告
#define JpgImageUrl1 @"http://d.hiphotos.baidu.com/image/pic/item/14ce36d3d539b60071473204e150352ac75cb7f3.jpg"
//动态广告
#define JpgImageUrl2 @"http://c.hiphotos.baidu.com/image/pic/item/d62a6059252dd42a6a943c180b3b5bb5c8eab8e7.jpg"

static float _animationDuration = 0.5f;

@interface CCLaunchAnimation ()

/**
 *  显示完成执行
 */
@property (copy, nonatomic) showFinishCallback showFinish;
/**
 *  广告点击
 */
@property (copy, nonatomic) clickCallback click;

/**
 *  持续时间
 */
@property (assign, nonatomic) NSInteger duration;
/**
 *  广告图片数组
 */
@property (strong, nonatomic) NSArray *advertImageArray;
/**
 *  广告图片image
 */
@property (strong, nonatomic) UIImage *advertImage;
/**
 *  图片加载的定时器
 */
@property (retain, nonatomic) dispatch_source_t timer;
/**
 *  跳过button倒计时的定时器
 */
@property (retain, nonatomic) dispatch_source_t skipButtonTimer;

@property (strong, nonatomic) UIButton *skipButton;

@end

@implementation CCLaunchAnimation

+ (void)showLaunchViewWithDuration:(NSInteger)duration
                        ShowFinish:(showFinishCallback)showFinish
                             click:(clickCallback)click {
    CCLaunchAnimation *launchAnimation = [[CCLaunchAnimation alloc]initWithDuration:duration showFinish:showFinish click:click];
    [[UIApplication sharedApplication].delegate window].rootViewController = launchAnimation;
}

- (instancetype)initWithDuration:(NSInteger)duration
                      showFinish:(showFinishCallback)showFinish
                           click:(clickCallback)click
{
    self = [super init];
    if (self) {
        _duration = duration;
        _click = [click copy];
        _showFinish = [showFinish copy];
    }
    return self;
}

/*
 *如果需要将背景图变成launch图，打开注释
- (void)loadView {
    //直接将self.view替换成launch 图片
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[self getLaunchImage]];
    self.view = imageView;
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    //[[UIApplication sharedApplication] setStatusBarHidden:YES];ios 9 之后已经弃用，如果需要适配7.0以下的可以使用
    
    [self configLogoAnimation];
    
    //加载广告图片
    [self loadAdvertView];
}

#pragma mark - private

- (void)configLogoAnimation {
    
//    __weak __typeof(self) weakSelf = self;
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_text"]];
    [self.view addSubview:imageView];
    
    /**
     *  使用约束来进行动画
     */
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_centerY).offset(-50);
    }];
    
    [self.view layoutIfNeeded];
    
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_bottom).offset(-50);
    }];
    
    [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //位移动画和比例缩小动画
        [self.view layoutIfNeeded];
        imageView.transform = CGAffineTransformScale(imageView.transform, 0.72, 0.72);
    } completion:^(BOOL finished) {
        //动画完成后需要现实广告图片
//        __strong __typeof(self) strongSelf = weakSelf;
        [self showAdvertView];
    }];
}

- (void)loadAdvertView {
    //模拟接口加载时间，并得到数据
    //__weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //__strong __typeof(self) strongSelf = weakSelf;
        //随机显示一个图片
        NSUInteger n = arc4random()%(self.advertImageArray.count);
        NSLog(@"下载的为第%ld张图片",n+1);
        NSURL *imageURL = [NSURL URLWithString:self.advertImageArray[n]];
        //这里是使用SDWebImage来下载并缓存广告图片
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        downloader.downloadTimeout = 3.0f;
        
        SDImageCache *cache = [SDImageCache sharedImageCache];
        cache.maxMemoryCountLimit = 1;
        SDWebImageManager *manager = [[SDWebImageManager alloc]initWithCache:cache downloader:downloader];
        
        [manager downloadImageWithURL:imageURL options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            NSLog(@"缓存的图片个数为 %ld",[cache getDiskCount]);
            if (error) {
                //如果3秒内没有下载下来，判断网络问题，不进行加载广告页面
                NSLog(@"图片下载失败！！！");
                return;
            }else {
                self.advertImage = image;
            }
        }];
    });
}

- (void)showAdvertView {
    __block int count = 0;
    if (self.advertImage) {
        //NSString *imageCategory = [self contentTypeForImageData:self.advertImageData];
        //NSLog(@"图片的类型为%@",imageCategory);
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-100)];
        [self.view addSubview:imageView];
        imageView.image = self.advertImage;
        [self imageViewTapGestureWith:imageView];
    }else {
        //如果图片下载过慢，动画完成后，可能image数据为空.这时候需要加一个定时器来每过半秒钟进行一次判断，如果有数据则显示image，并终止定时器。如果2秒过后还是没有数据，则不显示广告，直接进入主界面。
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//线程
        
        // 创建一个定时器(dispatch_source_t本质还是个OC对象)
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
        // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
        // 何时开始执行第一个任务
        // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚2秒
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer, ^{
            //半秒执行一次
            count ++;
            if (self.advertImage) {
                //有数据之后切换到主线程更新UI
                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *imageCategory = [self contentTypeForImageData:self.advertImageData];
//                    NSLog(@"图片的类型为%@",imageCategory);
                    
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-100)];
                    
                    [self.view addSubview:imageView];
                    imageView.image = self.advertImage;
                    [self imageViewTapGestureWith:imageView];
                });
                //获得数据后取消定时器
                dispatch_cancel(self.timer);
            }
            if (count == 4) {
                //2秒之后取消定时器
                dispatch_cancel(self.timer);
                if (_showFinish) {
                    _showFinish();
                }
            }
        });
        dispatch_resume(self.timer);
    }
}


- (void)imageViewTapGestureWith:(UIImageView *)imageView {
    //给imageView加上手势，点击后进入广告页面
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [imageView addGestureRecognizer:tapGesture];
    
    //在imageView上加上跳过的button，点击可以跳过广告
    [imageView addSubview:self.skipButton];
    //加入button后加上定时器来定时改变button的title
    _skipButtonTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_skipButtonTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_skipButtonTimer, ^{
        [self.skipButton setTitle:[NSString stringWithFormat:@"跳过 %.2ld",_duration] forState:UIControlStateNormal];
        if (_duration == 0) {
            dispatch_cancel(_skipButtonTimer);
            [self transitionAnimation];
        }
        _duration --;
    });
    dispatch_resume(_skipButtonTimer);
}

/**
 *  点击跳过button
 */
- (void)skipAction:(UIButton *)button {
    dispatch_cancel(_skipButtonTimer);
    [self transitionAnimation];
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    //取消定时器
    if (_timer) {
        dispatch_cancel(self.timer);
    }
    NSLog(@"点击图片进入广告页面！！！");
    if (_click) {
        dispatch_cancel(_skipButtonTimer);
        _click(@"https://www.baidu.com");
    }else {
        if (_showFinish) {
            _showFinish();
        }
    }
}

//通过图片Data数据第一个字节 来获取图片扩展名
- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

/**
 *  广告页面消失时，加入转场动画
 */
- (void)transitionAnimation {
    NSLog(@"----------转场动画---------");
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        if (_showFinish) {
            _showFinish();
        }
    }];
}
 
/**
 *  返回launch图片，暂时不考虑横屏的问题
 *
 */
- (UIImage *)getLaunchImage {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *launchImageName = nil;
    NSArray *imagesArray = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary *dic in imagesArray) {
        //NSLog(@"dic === %@",dic);
        //得到不同的图片的尺寸，并找到跟当前屏幕相同的image
        CGSize imageSize = CGSizeFromString(dic[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(viewSize, imageSize)) {
            launchImageName = dic[@"UILaunchImageName"];
            return [UIImage imageNamed:launchImageName];
        }
    }
    return nil;
}

/**
 *  ios 7 开始使用这个方法来控制状态栏的隐藏和显示
 */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - getting

- (NSArray *)advertImageArray {
    if (!_advertImageArray) {
        _advertImageArray = [NSArray arrayWithObjects:GifImageUrl,JpgImageUrl1,JpgImageUrl2, nil];
    }
    return _advertImageArray;
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
        _skipButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-70, 30, 60, 30);
        _skipButton.layer.cornerRadius = 15;
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _skipButton.layer.masksToBounds = YES;
        [_skipButton addTarget:self action:@selector(skipAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"释放广告页面");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

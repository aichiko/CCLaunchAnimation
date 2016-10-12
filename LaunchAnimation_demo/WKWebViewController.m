//
//  WKWebViewController.m
//  LaunchAnimation_demo
//
//  Created by 24hmb on 16/10/12.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry.h>

@interface WKWebViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"广告详情";
    [self configWKWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//@end


- (void)backToForward{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configWKWebView{
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_requestURL]]];
    [_webView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [[self.navigationController.navigationBar.subviews objectAtIndex:0] addSubview:self.progressView];
    
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"loading"]) {
        if (self.navigationItem.leftBarButtonItems.count == 1) {
            if (self.webView.canGoBack) {
                //[self updateNavigationItems];
            }
        }
    }
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.hidden = [change[@"new"] floatValue] == 1;
        [self.progressView setProgress:[change[@"new"] floatValue] animated:YES];
    }
    if ([keyPath isEqualToString:@"title"]) {
        //NSLog(@"title ==== %@",self.webView.title);
        self.navigationItem.title = self.webView.title;
    }
}

- (void)updateNavigationItems{
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:<#(UIBarButtonSystemItem)#> target:<#(nullable id)#> action:<#(nullable SEL)#> style:UIBarButtonItemStylePlain target:self action:@selector(backToForward)];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    [closeItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItems = @[self.navigationItem.backBarButtonItem, closeItem];
}

- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc]init];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        //_progressView.trackTintColor = [UIColor whiteColor];
    }
    return _progressView;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //NSLog(@"navigationAction ==== %@",navigationAction);
    //    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
    //        //[[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    //        decisionHandler(WKNavigationActionPolicyCancel);
    //    }else{
    //
    //    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"navigationResponse ==== %@",navigationResponse);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [self.progressView setProgress:0.0 animated:NO];
    //NSLog(@"%@\n%@",webView.configuration,navigation);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [self.progressView setProgress:0.0 animated:NO];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.progressView removeFromSuperview];
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

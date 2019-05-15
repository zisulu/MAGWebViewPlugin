//
//  MAGWebClientViewController.m
//  MAGWebViewPlugin
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import "MAGWebClientViewController.h"
#import "MAGWebView.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@interface MAGWebClientViewController ()<MAGWebViewDelegate>

@property (nonatomic, strong) MAGWebView *webView;

@property (nonatomic, strong) WebViewJavascriptBridge *jsBridge;

@end

@implementation MAGWebClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MAGWebView *webView = [[MAGWebView alloc] init];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.webView = webView;
    NSURL *requestURL = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    [self.webView loadRequest:request];
    //注册jsBridge
    [self registerJavascriptBridge];
    //添加刷新
    [self addRefreshComponent];
}

- (void)addRefreshComponent
{
    __weak typeof(self)wself = self;
    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself.webView reload];
    }];
}

- (void)registerJavascriptBridge
{
    [WebViewJavascriptBridge enableLogging];
    WebViewJavascriptBridge *jsBridge = [WebViewJavascriptBridge bridge:self.webView.webView];
    [jsBridge setWebViewDelegate:self.webView];
    self.jsBridge = jsBridge;
}

- (BOOL)webView:(id<MAGWebView>)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(MAGWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest");
    return YES;
}

- (void)webViewDidStartLoad:(id<MAGWebView>)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(id<MAGWebView>)webView
{
    [webView.scrollView.mj_header endRefreshing];
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(id<MAGWebView>)webView didResetWithURL:(NSURL *)requestURL
{
    NSLog(@"didResetWithURL:%@", requestURL);
    //如果是UIWebView更新UserAgent的时候，会被重新创建，所以可能需要重新设置
    if (webView.webContext == MAGWebContextUIKit) {
        //注册jsBridge
        [self registerJavascriptBridge];
        //添加刷新
        [self addRefreshComponent];
    }
}

- (void)webView:(id<MAGWebView>)webView longPressGestureRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    //触发长按
    NSLog(@"longPressGestureRecognized");
}

- (void)webView:(id<MAGWebView>)webView didFailLoadWithError:(nonnull NSError *)error
{
    [webView.scrollView.mj_header endRefreshing];
    NSLog(@"didFailLoadWithError:%@", error);
}

- (void)webViewWebContentProcessDidTerminate:(id<MAGWebView>)webView
{
    [webView.scrollView.mj_header endRefreshing];
    [webView reload];
}

- (void)webView:(id<MAGWebView>)webView showAlertWithMessage:(nonnull NSString *)message completionHandler:(nonnull void (^)(void))completionHandler
{
    //Use UIAlertController or Custom alert View
}

- (void)webView:(id<MAGWebView>)webView showConfirmAlertWithMessage:(nonnull NSString *)message completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    //Use UIAlertController or Custom alert View
}

- (void)webView:(id<MAGWebView>)webView showTextInputAlertWithMessage:(nonnull NSString *)message placeholder:(nonnull NSString *)placeholder completionHandler:(nonnull void (^)(NSString * _Nonnull))completionHandler
{
    //Use UIAlertController or Custom alert View
}

@end

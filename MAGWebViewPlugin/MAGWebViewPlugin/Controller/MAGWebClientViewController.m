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
    NSURL *requestURL = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    [webView loadRequest:request];
    self.webView = webView;
    //注册jsBridge
//    [self registerJavascriptBridge];
//    [self addRefreshComponent];
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
#if DEBUG
    [WebViewJavascriptBridge enableLogging];
#endif
    WebViewJavascriptBridge *jsBridge = [WebViewJavascriptBridge bridge:self.webView.webView];
    [jsBridge setWebViewDelegate:self.webView];
}

- (BOOL)webView:(id<MAGWebView>)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(MAGWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(id<MAGWebView>)webView
{
    
}

- (void)webViewDidFinishLoad:(id<MAGWebView>)webView
{
    
}

//- (void)webView:(id<MAGWebView>)webView willResetWithURL:(NSURL *)requestURL
//{
//    
//}
//
//- (void)webView:(id<MAGWebView>)webView didResetWithURL:(NSURL *)requestURL
//{
//    [self registerJavascriptBridge];
//    [self addRefreshComponent];
//}

- (void)webView:(id<MAGWebView>)webView longPressGestureRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    //触发长按
}

- (void)webView:(id<MAGWebView>)webView didFailLoadWithError:(nonnull NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
}

- (void)webViewWebContentProcessDidTerminate:(id<MAGWebView>)webView
{
    
}

- (void)webView:(id<MAGWebView>)webView showAlertWithMessage:(nonnull NSString *)message completionHandler:(nonnull void (^)(void))completionHandler
{
    
}

- (void)webView:(id<MAGWebView>)webView showConfirmAlertWithMessage:(nonnull NSString *)message completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    
}

- (void)webView:(id<MAGWebView>)webView showTextInputAlertWithMessage:(nonnull NSString *)message placeholder:(nonnull NSString *)placeholder completionHandler:(nonnull void (^)(NSString * _Nonnull))completionHandler
{
    
}

@end

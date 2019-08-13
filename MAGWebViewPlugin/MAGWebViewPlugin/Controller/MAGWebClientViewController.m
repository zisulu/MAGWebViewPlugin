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
//    NSArray *whiteSchemes = webView.configuration.customWhiteSchemes;
//    NSMutableArray *mutableList = [NSMutableArray arrayWithArray:whiteSchemes];
//    [mutableList addObject:@"customscheme"];
//    webView.configuration.customWhiteSchemes = [mutableList copy];
//    webView.configuration.customWhiteSchemes = @[];
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.webView = webView;
    NSURL *requestURL = [NSURL URLWithString:@"https://fir.im/magoa"];
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
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(id<MAGWebView>)webView showConfirmAlertWithMessage:(nonnull NSString *)message completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    //Use UIAlertController or Custom alert View
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    [alertController addAction:cancelAction];
    UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(id<MAGWebView>)webView showTextInputAlertWithMessage:(nonnull NSString *)message placeholder:(nonnull NSString *)placeholder completionHandler:(nonnull void (^)(NSString * _Nonnull))completionHandler
{
    //Use UIAlertController or Custom alert View
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = placeholder;
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.lastObject;
        completionHandler(textField.text);
    }];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(id<MAGWebView>)webView openExternalURL:(NSURL *)externalURL completionHandler:(void (^)(BOOL))completionHandler
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *externalScheme = externalURL.scheme;
    NSString *externalHost = externalURL.host;
    NSString *specialSchemePrefix = [NSString stringWithFormat:@"%@%@%@%@", @"i", @"t", @"m", @"s"];
    NSString *message = nil;
    if ([externalScheme hasPrefix:specialSchemePrefix]) {
        if ([externalScheme isEqualToString:specialSchemePrefix]) {
            message = [NSString stringWithFormat:@"即将离开「 %@ 」，打开「 iTunes 」", appName];
        } else {
            NSString *appStoreSchemeSuffix = [NSString stringWithFormat:@"-%@%@%@%@", @"a", @"p", @"p", @"s"];
            if ([externalScheme containsString:appStoreSchemeSuffix]) {
                message = [NSString stringWithFormat:@"即将离开「 %@ 」，打开「 AppStore 」", appName];
            } else {
                message = [NSString stringWithFormat:@"允许当前网页打开「 %@ 」应用？", externalScheme];
            }
        }
    } else {
        if ([webView.configuration.customInterceptHttpHosts containsObject:externalHost]) {
            NSString *itunesHost = @"itunes.apple.com";
            if ([externalHost isEqualToString:itunesHost]) {
                message = [NSString stringWithFormat:@"即将离开「 %@ 」，打开「 iTunes 」", appName];
            } else {
                message = [NSString stringWithFormat:@"即将离开「 %@ 」，打开「 AppStore 」", appName];
            }
        } else {
            message = [NSString stringWithFormat:@"即将离开「 %@ 」，唤起其他应用", appName];
        }
    }
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    [alertController addAction:cancelAction];
    UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"允许" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

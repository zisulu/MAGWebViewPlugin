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
#import "JSNativeService.h"

@interface MAGWebClientViewController ()<MAGWebViewDelegate>

@property (nonatomic, strong) MAGWebView *webView;

@property (nonatomic, strong) JSNativeService *jsService;

@end

@implementation MAGWebClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MAGWebViewConfiguration *configuration = [[MAGWebViewConfiguration alloc] init];
    configuration.allowsUserActionForMediaPlayback = NO;
    [configuration addCustomWhiteSchemes:@[@"wvjbscheme"]];
    MAGWebView *webView = [[MAGWebView alloc] initWithConfiguration:configuration];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.webView = webView;
//    NSURL *requestURL = [NSURL URLWithString:@"https://www.baidu.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
//    [self.webView loadRequest:request];
    NSString *testBundlePath = [[NSBundle mainBundle] pathForResource:@"MWDEMO" ofType:@"bundle"];
    NSBundle *testBundle = [NSBundle bundleWithPath:testBundlePath];
    NSURL *htmlURL = [testBundle URLForResource:@"MWDEMO" withExtension:@"htm"];
    [self.webView loadFileURL:htmlURL allowingReadAccessToURL:testBundle.bundleURL];
    /// 注册jsBridge
    [self registerJavascriptBridge];
}

- (void)addRefreshComponent
{
    __weak typeof(self)wself = self;
    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself.webView reloadFromOrigin];
    }];
}

- (void)registerJavascriptBridge
{
    self.jsService = [JSNativeService doJSRegistry:self.webView.webView context:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.jsService pageAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.jsService pageDisappear];
}

- (void)dealloc
{
    [self.jsService pageDestroy];
}

- (BOOL)webView:(id<MAGWebView>)webView shouldAllowWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest");
    return YES;
}

- (void)webViewDidLoadStarted:(id<MAGWebView>)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidLoadFinished:(id<MAGWebView>)webView
{
    [webView.scrollView.mj_header endRefreshing];
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(id<MAGWebView>)webView longPressGestureRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    //触发长按
    NSLog(@"longPressGestureRecognized");
}

- (void)webView:(id<MAGWebView>)webView didLoadFailedWithError:(nonnull NSError *)error
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
    /// Use UIAlertController or Custom alert View
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(id<MAGWebView>)webView showConfirmAlertWithMessage:(nonnull NSString *)message completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    /// Use UIAlertController or Custom alert View
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
    /// Use UIAlertController or Custom alert View
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
        if ([webView.configuration.customExternalHttpHosts containsObject:externalHost]) {
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

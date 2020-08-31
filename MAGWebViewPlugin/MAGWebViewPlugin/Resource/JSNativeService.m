//
//  JSNativeService.m
//  MAGWebView
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import "JSNativeService.h"
#import "MAGWebView.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

static BOOL useWebViewJavascriptBridge = YES;

@interface JSNativeService ()

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) __kindof UIViewController *context;

@property (nonatomic, copy) NSArray *interfaceList;
@property (nonatomic, copy) NSString *injectedScript;
@property (nonatomic, strong) WebViewJavascriptBridge *jsBridge;

@property (nonatomic, copy) NSArray *actionList;


@end

@implementation JSNativeService

- (instancetype)init
{
    self = [super init];
    if (self) {
        /// 加载配置
        NSString *path = [[NSBundle mainBundle] pathForResource:@"JSNativeInterface" ofType:@"plist"];
        NSDictionary *configData = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *interfaceList = configData[@"list"];
        self.interfaceList = interfaceList;
//        NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"mwjs-2.0.0" ofType:@"js"];
        NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"mwjs-pure" ofType:@"js"];
        NSString *injectedScript = [[NSString alloc] initWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
        self.injectedScript = injectedScript;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterAllJSHandlers];
}

- (void)registerAllJSHandlers
{
    WKUserContentController *userContentController = self.webView.configuration.userContentController;
    [userContentController mag_addScriptAtDocumentStart:self.injectedScript];
    for (NSDictionary *aFunction in self.interfaceList) {
        NSString *functionName = aFunction[@"name"];
        [userContentController addScriptMessageHandler:self name:functionName];
    }
}

- (void)unregisterAllJSHandlers
{
    WKUserContentController *userContentController = self.webView.configuration.userContentController;
    [userContentController removeAllUserScripts];
    for (NSDictionary *aFunction in self.interfaceList) {
        NSString *functionName = aFunction[@"name"];
        [userContentController removeScriptMessageHandlerForName:functionName];
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self onReceiveJsCall:message.name data:message.body];
}

+ (JSNativeService *)doJSRegistry:(WKWebView *)webView context:(__kindof UIViewController *)context
{
    JSNativeService *service = [[JSNativeService alloc] init];
    service.webView = webView;
    service.context = context;
    if (useWebViewJavascriptBridge) {
        service.jsBridge = [WebViewJavascriptBridge bridgeForWebView:webView];
        for (NSDictionary *aFunction in service.interfaceList) {
            NSString *functionName = aFunction[@"name"];
            __block JSNativeService *weakService = service;
            [service.jsBridge registerHandler:functionName handler:^(id data, WVJBResponseCallback responseCallback) {
                [weakService onReceiveJsCall:functionName data:data];
            }];
        }
    } else {
        [service registerAllJSHandlers];
    }
    return service;
}

- (void)onReceiveJsCall:(NSString *)functionName data:(id)data
{
    NSDictionary *targetFunction = nil;
    for (NSDictionary *aFunction in self.interfaceList) {
        NSString *name = aFunction[@"name"];
        if ([name isEqualToString:functionName]) {
            targetFunction = aFunction;
            break;
        }
    }
    NSAssert(targetFunction, @"");
    NSString *handlerName = targetFunction[@"handlerName"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(handlerName);
    if ([handlerName hasSuffix:@":"]) {
        [self performSelector:selector withObject:data];
    } else {
        [self performSelector:selector];
    }
#pragma clang diagnostic pop
}

- (void)callHandler:(NSString *)handler data:(NSString *)data
{
    if (!data) data = @"";
    NSDictionary *returnData = @{
        @"id" : handler,
        @"val" : data,
    };
    NSString *result = nil;
    if ([NSJSONSerialization isValidJSONObject:returnData]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:returnData options:0 error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    if (useWebViewJavascriptBridge) {
        [self.jsBridge callHandler:@"jsCallBack" data:result];
    } else {
        NSString *callbackJS = [NSString stringWithFormat:@"window.mag.jsCallBack('%@','%@')", handler, data];
        [self.webView evaluateJavaScript:callbackJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)callHandler:(NSString *)handler jsCallback:(NSString *)jsCallback data:(NSString *)data
{
    if (!data) data = @"";
    NSDictionary *returnData = @{
        @"id" : handler,
        @"val" : data,
    };
    NSString *result = nil;
    if ([NSJSONSerialization isValidJSONObject:returnData]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:returnData options:0 error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    [self.jsBridge callHandler:jsCallback data:result];
}

#pragma mark - FUNCTION

- (void)showDialog:(NSString *)json
{
    NSError *error = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    NSString *title = data[@"title"];
    NSString *content = data[@"content"];
    NSArray *actionTitles = data[@"buttons"];
    if (![actionTitles isKindOfClass:[NSArray class]]) {
        actionTitles = @[];
    }
    NSString *cancelTitle = @"取消";
    NSString *confirmTitle = @"确定";
    if (actionTitles.count > 0) {
        cancelTitle = actionTitles[0];
    }
    if (actionTitles.count > 1) {
        confirmTitle = actionTitles[1];
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self callHandler:@"dialogCancel" data:nil];
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self callHandler:@"dialogSuccess" data:nil];
    }];
    [alertController addAction:doneAction];
    [self.context presentViewController:alertController animated:YES completion:nil];
}

- (void)showPhoneSettings
{
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else {
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

- (void)setData:(NSString *)json
{
    /// 设置页面数据
}

- (void)getDeviceId
{
    NSString *deviceId = @"没错这个就是设备号";
    [self callHandler:@"getDeviceId" data:deviceId];
}

- (void)addRefreshComponent
{
    if ([self.context respondsToSelector:@selector(addRefreshComponent)]) {
        [self.context performSelector:@selector(addRefreshComponent)];
    }
}

@end

@implementation JSNativeService (WebLifeCycle)

- (void)pageAppear
{
    [self callHandler:@"pageAppear" data:nil];
}

- (void)pageDisappear
{
    [self callHandler:@"pageDisappear" data:nil];
}

- (void)pageDestroy
{
    [self callHandler:@"pageDestroy" data:nil];
}

@end

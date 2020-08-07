//
//  MAGWebView.m
//  MAGWebView
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import "MAGWebView.h"
#import "Masonry.h"

#ifndef dispatch_safe_async_main_queue
#define dispatch_safe_async_main_queue(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@interface MAGWebViewConfiguration ()

@property (nonatomic, copy, readwrite) WKWebViewConfiguration *wkConfiguration;

@property (nonatomic, copy, readwrite) NSArray<NSString *> *customWhiteSchemes;

@property (nonatomic, copy, readwrite) NSArray<NSString *> *customExternalSchemes;

@property (nonatomic, copy, readwrite) NSArray<NSString *> *customExternalHttpHosts;

@end

@implementation MAGWebViewConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allowsInlineMediaPlayback = YES;
        _allowsUserActionForMediaPlayback = YES;
        _allowsAirPlayForMediaPlayback = YES;
    }
    return self;
}

- (WKWebViewConfiguration *)wkConfiguration
{
    if (!_wkConfiguration) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        configuration.userContentController = userContentController;
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        configuration.processPool = [WKProcessPool mag_processPool];
        configuration.allowsInlineMediaPlayback = YES;
        if (@available(iOS 10.0, *)) {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
        } else {
            configuration.requiresUserActionForMediaPlayback = YES;
        }
        configuration.allowsAirPlayForMediaPlayback = YES;
        if (@available(iOS 13.0, *)) {
            configuration.defaultWebpagePreferences.preferredContentMode = WKContentModeMobile;
        }
        _wkConfiguration = configuration;
    }
    return _wkConfiguration;
}

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback
{
    if (_allowsInlineMediaPlayback == allowsInlineMediaPlayback) return;
    _allowsInlineMediaPlayback = allowsInlineMediaPlayback;
    WKWebViewConfiguration *configuration = self.wkConfiguration;
    configuration.allowsInlineMediaPlayback = _allowsInlineMediaPlayback;
}

- (void)setAllowsUserActionForMediaPlayback:(BOOL)allowsUserActionForMediaPlayback
{
    if (_allowsUserActionForMediaPlayback == allowsUserActionForMediaPlayback) return;
    _allowsUserActionForMediaPlayback = allowsUserActionForMediaPlayback;
    WKWebViewConfiguration *configuration = self.wkConfiguration;
    if (@available(iOS 10.0, *)) {
        if (_allowsUserActionForMediaPlayback) {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
        } else {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        }
    } else {
        configuration.requiresUserActionForMediaPlayback = _allowsUserActionForMediaPlayback;
    }
}

- (void)setAllowsAirPlayForMediaPlayback:(BOOL)allowsAirPlayForMediaPlayback
{
    if (_allowsAirPlayForMediaPlayback == allowsAirPlayForMediaPlayback) return;
    _allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback;
    WKWebViewConfiguration *configuration = self.wkConfiguration;
    configuration.allowsAirPlayForMediaPlayback = _allowsAirPlayForMediaPlayback;
}

- (NSArray<NSString *> *)customWhiteSchemes
{
    if (!_customWhiteSchemes) {
        _customWhiteSchemes = [self internal_customWhiteSchemes];
    }
    return _customWhiteSchemes;
}

- (void)addCustomWhiteSchemes:(NSArray<NSString *> *)schemes
{
    if (![schemes isKindOfClass:[NSArray class]]) return;
    if (schemes.count == 0) return;
    NSMutableArray<NSString *> *mutableList = [self.customWhiteSchemes mutableCopy];
    for (NSString *scheme in schemes) {
        if (scheme.length > 0 && ![mutableList containsObject:scheme]) {
            [mutableList addObject:scheme];
        }
    }
    _customWhiteSchemes = [mutableList copy];
}

- (void)removeCustomWhiteSchemes:(NSArray<NSString *> *)schemes
{
    if (![schemes isKindOfClass:[NSArray class]]) return;
    if (schemes.count == 0) return;
    NSMutableArray<NSString *> *mutableList = [self.customWhiteSchemes mutableCopy];
    for (NSString *scheme in schemes) {
        if (scheme.length > 0 && [mutableList containsObject:scheme]) {
            [mutableList removeObject:scheme];
        }
    }
    _customWhiteSchemes = [mutableList copy];
}

- (NSArray<NSString *> *)customExternalSchemes
{
    if (!_customExternalSchemes) {
        _customExternalSchemes = [self internal_customExternalSchemes];
    }
    return _customExternalSchemes;
}

- (void)addCustomExternalSchemes:(NSArray<NSString *> *)schemes
{
    if (![schemes isKindOfClass:[NSArray class]]) return;
    if (schemes.count == 0) return;
    NSMutableArray<NSString *> *mutableList = [self.customExternalSchemes mutableCopy];
    for (NSString *scheme in schemes) {
        if (scheme.length > 0 && ![mutableList containsObject:scheme]) {
            [mutableList addObject:scheme];
        }
    }
    _customExternalSchemes = [mutableList copy];
}

- (void)removeCustomExternalSchemes:(NSArray<NSString *> *)schemes
{
    if (![schemes isKindOfClass:[NSArray class]]) return;
    if (schemes.count == 0) return;
    NSMutableArray<NSString *> *mutableList = [self.customExternalSchemes mutableCopy];
    for (NSString *scheme in schemes) {
        if (scheme.length > 0 && [mutableList containsObject:scheme]) {
            [mutableList removeObject:scheme];
        }
    }
    _customExternalSchemes = [mutableList copy];
}

- (NSArray<NSString *> *)customExternalHttpHosts
{
    if (!_customExternalHttpHosts) {
        _customExternalHttpHosts = [self internal_customExternalHttpHosts];
    }
    return _customExternalHttpHosts;
}

- (void)addCustomExternalHttpHosts:(NSArray<NSString *> *)httpHosts
{
    if (![httpHosts isKindOfClass:[NSArray class]]) return;
    if (httpHosts.count == 0) return;
    NSMutableArray<NSString *> *mutableList = [self.customExternalHttpHosts mutableCopy];
    for (NSString *host in httpHosts) {
        if (host.length > 0 && ![mutableList containsObject:host]) {
            [mutableList addObject:host];
        }
    }
    _customExternalHttpHosts = [mutableList copy];
}

- (void)removeCustomExternalHttpHosts:(NSArray<NSString *> *)httpHosts
{
    if (![httpHosts isKindOfClass:[NSArray class]]) return;
    if (httpHosts.count == 0) return;
    NSMutableArray<NSString *> *mutableList = [self.customExternalHttpHosts mutableCopy];
    for (NSString *host in httpHosts) {
        if (host.length > 0 && [mutableList containsObject:host]) {
            [mutableList removeObject:host];
        }
    }
    _customExternalHttpHosts = [mutableList copy];
}

- (NSArray<NSString *> *)internal_customWhiteSchemes
{
    return @[
        @"http",
        @"https",
        @"file",
    ];
}

- (NSArray<NSString *> *)internal_customExternalSchemes
{
    return @[
        @"tel",
        @"sms",
        @"mailto",
    ];;
}

- (NSArray<NSString *> *)internal_customExternalHttpHosts
{
    return @[
        @"itunes.apple.com",
        @"itunesconnect.apple.com",
        @"appstoreconnect.apple.com",
    ];
}

@end

@interface MAGWebView ()<WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy, readwrite, nullable) NSString *title;
@property (nonatomic, strong, readwrite, nullable) NSURLRequest *originRequest;
@property (nonatomic, strong, readwrite, nullable) NSURLRequest *currentRequest;
@property (nonatomic, readwrite) double estimatedProgress;

@property (nonatomic, strong, readwrite) WKWebView *webView;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong, readwrite) MAGWebViewConfiguration *configuration;

@end

@implementation MAGWebView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internal_setupConfiguration];
        [self internal_setupWebView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self internal_setupConfiguration];
        [self internal_setupWebView];
    }
    return self;
}

- (instancetype)initWithConfiguration:(MAGWebViewConfiguration *)configuration
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        if (!configuration) {
            [self internal_setupConfiguration];
        } else {
            _configuration = configuration;
        }
        [self internal_setupWebView];
    }
    return self;
}

- (void)internal_setupConfiguration
{
    MAGWebViewConfiguration *configuration = [[MAGWebViewConfiguration alloc] init];
    _configuration = configuration;
}

- (void)internal_setupWebView
{
    [self addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addWebLongPressRecognizer];
}

- (WKWebView *)webView
{
    if (!_webView) {
        WKWebView *webView = [WKWebView mag_webViewWithConfiguration:_configuration];
        [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        if (@available(iOS 11.0, *)) {
            WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
            [WKWebView syncCookies:cookieStore];
        }
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        _webView = webView;
    }
    return _webView;
}

- (void)addWebLongPressRecognizer
{
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(webLongPressRecognized:)];
    recognizer.delegate = self;
    self.longPressGestureRecognizer = recognizer;
    [self.webView addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)webLongPressRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:longPressGestureRecognized:)]) {
        [self.delegate webView:self longPressGestureRecognized:gestureRecognizer];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && gestureRecognizer == self.longPressGestureRecognizer) {
        return YES;
    } else {
        return NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.webView) {
        if ([keyPath isEqualToString:@"title"]) {
            NSString *oldValue = change[NSKeyValueChangeOldKey];
            NSString *newValue = change[NSKeyValueChangeNewKey];
            if (![newValue isEqualToString:oldValue]) {
                NSString *title = [NSString stringWithFormat:@"%@", newValue];
                [self internal_webViewDidUpdateTitle:title];
            }
        } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
            double estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
            self.estimatedProgress = estimatedProgress;
            [self internal_webViewDidUpdateProgress: self.estimatedProgress];
        }
    }
}

#pragma mark ----------- WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    self.currentRequest = navigationAction.request;
    BOOL result = [self internal_webViewCanOpenRequestURL:self.currentRequest.URL];
    if (result) {
        /// internal intercept
        [self internal_webViewOpenRequestURL:self.currentRequest.URL];
    }
    result = [self internal_webViewShouldAllowWithRequest:self.currentRequest navigationType:navigationAction.navigationType];
    if (result) {
        if (!navigationAction.targetFrame) {
            [webView loadRequest:self.currentRequest];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (@available(iOS 12.0, *)) {
        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            [webView insertCookies:cookies];
        }];
    } else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
        [webView insertCookies:cookies];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self internal_webViewDidLoadStarted];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self internal_webViewDidLoadFinished];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self internal_webViewDidLoadFailedWithError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self internal_webViewDidLoadFailedWithError:error];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    [self internal_webViewDidReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [self internal_webViewWebContentProcessDidTerminate];
}

#pragma mark ---------- WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        self.currentRequest = navigationAction.request;
        [webView loadRequest:self.currentRequest];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    [self internal_webViewShowTextInputAlertWithMessage:prompt placeholder:defaultText completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    [self internal_webViewShowConfirmAlertWithMessage:message completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(void))completionHandler
{
    [self internal_webViewShowAlertWithMessage:message completionHandler:completionHandler];
}

#pragma mark ---------- internal MAGWebView Delegate

- (void)internal_webViewDidLoadFinished
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidLoadFinished:)]) {
        [self.delegate webViewDidLoadFinished:self];
    }
}

- (void)internal_webViewDidLoadStarted
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidLoadStarted:)]) {
        [self.delegate webViewDidLoadStarted:self];
    }
}

- (BOOL)internal_webViewCanOpenRequestURL:(NSURL *)requestURL
{
    BOOL result = NO;
    if (requestURL) {
        NSString *requestScheme = requestURL.scheme;
        NSString *requestHost = requestURL.host;
        if (requestScheme.length > 0) {
            if ([requestScheme hasPrefix:@"http"] && requestHost.length > 0) {
                /// requestURL can be validated by internal_canOpenExternalURL, so we intercept requestHost
                NSArray<NSString *> *supportedHosts = [self.configuration customExternalHttpHosts];
                result = [supportedHosts containsObject:requestHost];
            } else {
                /// we also don't want some schemes to be intercepted.
                NSArray *whiteSchemes = [self.configuration customWhiteSchemes];
                if (whiteSchemes.count > 0 && [whiteSchemes containsObject:requestScheme]) {
                    /// don't intercept
                    result = NO;
                } else {
                    /// tel, sms, mailto etc.
                    result = [self internal_canOpenExternalURL:requestURL];
                    if (!result) {
                        /// system canOpenURL failed, it means requestURL contains other untrusted URLScheme
                        NSString *validRequestPrefix = [NSString stringWithFormat:@"%@://", requestScheme];
                        if ([requestURL.absoluteString hasPrefix:validRequestPrefix]) {
                            /// let user choose open URLScheme wether or not if URLScheme not be contained in customExternalSchemes
                            result = YES;
                        } else {
                            /// don't intercepts about:blank、data:xxxx
                            result = NO;
                        }
                    }
                }
            }
        }
    }
    return result;
}

- (void)internal_webViewOpenRequestURL:(NSURL *)requestURL
{
    NSString *requestScheme = requestURL.scheme;
    NSArray *interceptSchemes = [self.configuration customExternalSchemes];
    if (interceptSchemes.count > 0 && [interceptSchemes containsObject:requestScheme]) {
        /// intercept directly
        [self internal_openExternalURL:requestURL];
    } else {
        /// the outside decides whether to intercept or not
        if (self.delegate && [self.delegate respondsToSelector:@selector(webView:openExternalURL:completionHandler:)]) {
            __weak typeof(self)wself = self;
            [self.delegate webView:self openExternalURL:requestURL completionHandler:^(BOOL result) {
                if (result) {
                    [wself internal_openExternalURL:requestURL];
                }
            }];
        }
    }
}

- (BOOL)internal_canOpenExternalURL:(NSURL *)openURL
{
    UIApplication *application = [UIApplication sharedApplication];
    return [application canOpenURL:openURL];
}

- (void)internal_openExternalURL:(NSURL *)openURL
{
    UIApplication *application = [UIApplication sharedApplication];
    if (@available(iOS 10.0, *)) {
        [application openURL:openURL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"MAGWebView openURL success : %@", openURL);
            } else {
                NSLog(@"MAGWebView openURL failure : %@", openURL);
            }
        }];
    } else {
        [application openURL:openURL];
    }
}

- (void)internal_webViewDidLoadFailedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didLoadFailedWithError:)]) {
        [self.delegate webView:self didLoadFailedWithError:error];
    }
}

- (BOOL)internal_webViewShouldAllowWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType
{
    BOOL result = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldAllowWithRequest:navigationType:)]) {
        result = [self.delegate webView:self shouldAllowWithRequest:request navigationType:navigationType];
    }
    return result;
}

- (void)internal_webViewDidReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(internal_webViewDidReceiveAuthenticationChallenge:completionHandler:)]) {
        [self.delegate webView:self didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        NSString *authenticationMethod = challenge.protectionSpace.authenticationMethod;
        /// determine whether the certificate type returned by the server is server trust
        if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            SecTrustRef secTrustRef = challenge.protectionSpace.serverTrust;
            /// secTrustRef is empty or not
            if (secTrustRef != NULL) {
                SecTrustResultType result;
                OSErr er = SecTrustEvaluate(secTrustRef, &result);
                if (er != noErr) {
                    completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace,nil);
                    return;
                } else {
                    if (result == kSecTrustResultRecoverableTrustFailure) {
                        /// the certificate is not trusted
                        /**CFArrayRef secTrustProperties = SecTrustCopyProperties(secTrustRef);
                        NSArray *secTrustArray = CFBridgingRelease(secTrustProperties);
                        NSMutableString *errorStr = [NSMutableString string];
                        for (NSInteger i=0;i<secTrustArray.count;i++){
                            NSDictionary *secTrustData = [secTrustArray objectAtIndex:i];
                            if (i != 0) {
                                [errorStr appendString:@" "];
                            }
                            NSString *secTrustValue = (NSString *)(secTrustData[@"value"]);
                            [errorStr appendString:secTrustValue];
                        }
                        SecCertificateRef certRef = SecTrustGetCertificateAtIndex(secTrustRef, 0);
                        CFStringRef cfCertSummaryRef = SecCertificateCopySubjectSummary(certRef);
                        NSString *certSummary = (NSString *)CFBridgingRelease(cfCertSummaryRef);
                        NSString *message = [NSString stringWithFormat:@"该服务器无法验证，是否通过标识为：%@ 证书为：%@的验证. \n%@" , self.webView.URL.host, certSummary, errorStr];
                        [self internal_webViewShowConfirmAlertWithMessage:message completionHandler:^(BOOL result) {
                            if (result) {
                                NSURLCredential *credential = [NSURLCredential credentialForTrust:secTrustRef];
                                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                            } else {
                                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
                            }
                        }];**/
                        /// 这里不再询问用户，直接主动信任
                        NSURLCredential *credential = [NSURLCredential credentialForTrust:secTrustRef];
                        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                        return;
                    } else {
                        /// certificate is trusted
                        NSURLCredential *credential = [NSURLCredential credentialForTrust:secTrustRef];
                        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                        return;
                    }
                }
            } else {
                /// secTrustRef is empty
                completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
            }
        } else {
            /// non-server trust
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

- (void)internal_webViewWebContentProcessDidTerminate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)]) {
        [self.delegate webViewWebContentProcessDidTerminate:self];
    }
}

- (void)internal_webViewShowTextInputAlertWithMessage:(NSString *)message placeholder:(NSString *)placeholder completionHandler:(void (^)(NSString *result))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:showTextInputAlertWithMessage:placeholder:completionHandler:)]) {
        [self.delegate webView:self showTextInputAlertWithMessage:message placeholder:placeholder completionHandler:completionHandler];
    }
}

- (void)internal_webViewShowConfirmAlertWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:showConfirmAlertWithMessage:completionHandler:)]) {
        [self.delegate webView:self showConfirmAlertWithMessage:message completionHandler:completionHandler];
    }
}

- (void)internal_webViewShowAlertWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:showAlertWithMessage:completionHandler:)]) {
        [self.delegate webView:self showAlertWithMessage:message completionHandler:completionHandler];
    }
}

- (void)internal_webViewDidUpdateTitle:(NSString *)title
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didUpdateTitle:)]) {
        [self.delegate webView:self didUpdateTitle:title];
    }
}

- (void)internal_webViewDidUpdateProgress:(double)progress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didUpdateProgress:)]) {
        [self.delegate webView:self didUpdateProgress:progress];
    }
}

- (void)internal_webViewUserAgentUpdateWithURL:(NSURL *)requestURL completionHandler:(void(^)(void))completionHandler
{
    if ([self internal_shouldUpdateWebViewUserAgent]) {
        __weak typeof(self) weakSelf = self;
        [self.delegate webView:self userAgentUpdateWithURL:requestURL completionHandler:^(NSString * _Nullable userAgent) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf updateUserAgent:userAgent completionHandler:completionHandler];
        }];
    }
}

- (BOOL)internal_shouldUpdateWebViewUserAgent
{
    BOOL shouldUpdateUserAgent = self.delegate && [self.delegate respondsToSelector:@selector(webView:userAgentUpdateWithURL:completionHandler:)];
    return shouldUpdateUserAgent;
}

- (void)updateUserAgent:(NSString *)userAgent completionHandler:(void (^)(void))completionHandler
{
    [self internal_updateUserAgent:userAgent completionHandler:completionHandler];
}

- (void)internal_updateUserAgent:(NSString *)userAgent completionHandler:(void (^)(void))completionHandler
{
    NSString *originUserAgent = self.customUserAgent;
    /// 如果userAgent相较于originUserAgent发生了变化，则使用userAgent覆盖originUserAgent
    if (userAgent.length > 0 && ![userAgent isEqualToString:originUserAgent]) {
#if DEBUG
        NSLog(@"WKWebView UserAgent 旧 %@", originUserAgent);
        NSLog(@"WKWebView UserAgent 新 %@", userAgent);
        if ([originUserAgent containsString:userAgent]) {
            NSLog(@"WKWebView UserAgent 移除 %@", [originUserAgent stringByReplacingOccurrencesOfString:userAgent withString:@""]);
        } else if ([userAgent containsString:originUserAgent]) {
            NSLog(@"WKWebView UserAgent 增加 %@", [userAgent stringByReplacingOccurrencesOfString:originUserAgent withString:@""]);
        } else {
            NSLog(@"WKWebView UserAgent 改变");
        }
#endif
        /// 1.WKWebView的customUserAgent会覆盖WKWebView本身的UserAgent；
        /// 2.configuration.applicationNameForUserAgent设置的UserAgent是拼接在WKWebView本身的userAgent后面，
        /// 但是会覆盖原始UserAgent最后的比如Mobile/15E148
        self.customUserAgent = userAgent;
    }
    if (completionHandler) {
        completionHandler();
    }
}

- (UIScrollView *)scrollView
{
    return self.webView.scrollView;
}

- (WKNavigation *)loadRequest:(NSURLRequest *)request
{
    BOOL shouldUserAgentUpdate = [self internal_shouldUpdateWebViewUserAgent];
    if (shouldUserAgentUpdate) {
        __weak typeof(self)wself = self;
        [self internal_webViewUserAgentUpdateWithURL:request.URL completionHandler:^{
            [wself internal_loadRequest:request];
        }];
        return nil;
    }
    return [self internal_loadRequest:request];
}

- (WKNavigation *)internal_loadRequest:(NSURLRequest *)request
{
    self.originRequest = request;
    self.currentRequest = request;
    return [self.webView loadRequest:request];
}

- (WKNavigation *)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    BOOL shouldUserAgentUpdate = [self internal_shouldUpdateWebViewUserAgent];
    if (shouldUserAgentUpdate && baseURL) {
        __weak typeof(self)wself = self;
        [self internal_webViewUserAgentUpdateWithURL:baseURL completionHandler:^{
            [wself internal_loadHTMLString:string baseURL:baseURL];
        }];
        return nil;
    }
    return [self internal_loadHTMLString:string baseURL:baseURL];
}

- (WKNavigation *)internal_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    return [self.webView loadHTMLString:string baseURL:baseURL];
}

- (WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL
{
    return [self.webView loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];
}

- (WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL
{
    return [self.webView loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

- (NSString *)title
{
    return self.webView.title;
}

- (NSURL *)URL
{
    return self.webView.URL;
}

- (BOOL)canGoBack
{
    return self.webView.canGoBack;
}

- (BOOL)canGoForward
{
    return self.webView.canGoForward;
}

- (BOOL)isLoading
{
    return self.webView.isLoading;
}

- (WKNavigation *)reload
{
    return [self.webView reload];
}

- (WKNavigation *)reloadFromOrigin
{
    return [self.webView reloadFromOrigin];
}

- (void)stopLoading
{
    [self.webView stopLoading];
}

- (WKNavigation *)goBack
{
    return [self.webView goBack];
}

- (WKNavigation *)goForward;
{
    return [self.webView goForward];
}

- (NSInteger)countOfHistory
{
    return self.webView.backForwardList.backList.count;
}

- (WKNavigation *)goBackWithStep:(NSInteger)step
{
    if (self.canGoBack == NO) return nil;
    if (step > 0) {
        NSInteger historyCount = self.countOfHistory;
        if (step >= historyCount) {
            step = historyCount - 1;
        }
        WKBackForwardListItem *backItem = self.webView.backForwardList.backList[step];
        return [self.webView goToBackForwardListItem:backItem];
    } else {
        return [self goBack];
    }
}

- (void)setAllowsLinkPreview:(BOOL)allowsLinkPreview
{
    self.webView.allowsLinkPreview = allowsLinkPreview;
}

- (BOOL)allowsLinkPreview
{
    return self.webView.allowsLinkPreview;
}

- (void)setCustomUserAgent:(NSString *)customUserAgent
{
    self.webView.customUserAgent = customUserAgent;
}

- (NSString *)customUserAgent
{
    return self.webView.customUserAgent;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)dealloc
{
    WKWebView *webView = self.webView;
    webView.UIDelegate = nil;
    webView.navigationDelegate = nil;
    [webView removeObserver:self forKeyPath:@"title"];
    [webView removeObserver:self forKeyPath:@"estimatedProgress"];
    webView.scrollView.delegate = nil;
    [webView stopLoading];
    [webView removeFromSuperview];
}

@end

@implementation WKWebView (MAGWebView)

+ (WKWebView *)mag_webView
{
    MAGWebViewConfiguration *configuration = [[MAGWebViewConfiguration alloc] init];
    return [self mag_webViewWithConfiguration:configuration];
}

+ (WKWebView *)mag_webViewWithConfiguration:(MAGWebViewConfiguration *)configuration
{
    WKWebViewConfiguration *wkConfiguration = configuration.wkConfiguration;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkConfiguration];
    webView.opaque = NO;
    webView.clipsToBounds = NO;
    webView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = webView.scrollView;
    scrollView.clipsToBounds = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    scrollView.scrollsToTop = YES;
    webView.allowsBackForwardNavigationGestures = YES;
    return webView;
}

@end

@implementation WKWebView (MAGWebCookie)

+ (void)syncCookies:(WKHTTPCookieStore *)cookieStore
{
    NSArray *cookies = [self sharedCookieStorage];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStore setCookie:cookie completionHandler:nil];
    }
}

- (void)insertCookie:(NSHTTPCookie *)cookie
{
    @autoreleasepool {
        if (@available(iOS 11.0, *)) {
            WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
            [cookieStore setCookie:cookie completionHandler:nil];
        }
        NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [sharedCookieStorage setCookie:cookie];
    }
}

- (void)insertCookies:(NSArray<NSHTTPCookie *> *)cookies
{
    if (cookies.count == 0) return;
    for (NSHTTPCookie *cookie in cookies) {
        [self insertCookie:cookie];
    }
}

+ (NSArray<NSHTTPCookie *> *)sharedCookieStorage
{
    NSMutableArray<NSHTTPCookie *> *mutableCookies = [NSMutableArray array];
    NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    if (sharedCookieStorage.cookies) {
        [mutableCookies addObjectsFromArray:sharedCookieStorage.cookies];
    }
    return [mutableCookies copy];
}

+ (void)clearCookies
{
    [self clearCookies:nil];
}

+ (void)clearCookies:(void (^)(void))completionHandler
{
    /// must be executed on a main queue
    dispatch_safe_async_main_queue(^{
        [self internal_clearCookies:completionHandler];
    });
}

+ (void)internal_clearCookies:(void (^)(void))completionHandler
{
    [NSHTTPCookieStorage mag_clearCookies];
    NSSet *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        NSLog(@"Cookies清除成功");
        if (completionHandler) {
            completionHandler();
        }
    }];
}

@end

@implementation WKWebView (MAGWebCache)

+ (void)clearCaches
{
    [self clearCaches:nil];
}

+ (void)clearCaches:(void (^)(void))completionHandler
{
    /// must be executed on a main queue
    dispatch_safe_async_main_queue(^{
        [self internal_clearCaches:nil];
    });
}

+ (void)internal_clearCaches:(void (^)(void))completionHandler
{
    NSURLCache *webCache = [NSURLCache sharedURLCache];
    [webCache removeAllCachedResponses];
    NSSet *websiteDataTypes = [NSSet setWithArray:@[
        WKWebsiteDataTypeDiskCache,
        WKWebsiteDataTypeOfflineWebApplicationCache,
        WKWebsiteDataTypeMemoryCache,
        WKWebsiteDataTypeLocalStorage,
        WKWebsiteDataTypeSessionStorage,
        WKWebsiteDataTypeIndexedDBDatabases,
        WKWebsiteDataTypeWebSQLDatabases,
    ]];
    NSDate *sinceDate = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:sinceDate completionHandler:^{
        NSLog(@"WebCache清除成功");
        if (completionHandler) {
            completionHandler();
        }
    }];
}

@end

@implementation WKUserContentController (MAGWebScript)

+ (NSString *)mag_webPageScaleFitScript
{
    NSString *scaleScript =
    @"if(document.getElementsByTagName('head')){var hasViewPort = 0;var metas = document.getElementsByTagName('head')[0].getElementsByTagName('meta');for(var i = metas.length; i>=0 ; i--){var meta = metas[i];if(meta && meta.name == 'viewport'){hasViewPort = 1;break;}};if(hasViewPort == 0){var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);}};";
    return scaleScript;
}

- (void)mag_addScriptAtDocumentStart:(NSString *)script
{
    [self mag_addScript:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
}

- (void)mag_addScriptForMainFrameDocumentStart:(NSString *)script
{
    [self mag_addScript:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
}

- (void)mag_addScriptAtDocumentEnd:(NSString *)script
{
    [self mag_addScript:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
}

- (void)mag_addScriptForMainFrameAtDocumentEnd:(NSString *)script
{
    [self mag_addScript:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
}

- (void)mag_addScript:(NSString *)script injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly
{
    if (script.length == 0) return;
    NSMutableArray<WKUserScript *> *userScripts = [self.userScripts mutableCopy];
    WKUserScript *targetUserScript = nil;
    for (WKUserScript *userScript in userScripts) {
        if ([userScript.source isEqualToString:script]) {
            targetUserScript = userScript;
            break;
        }
    }
    if (!targetUserScript) {
        targetUserScript = [[WKUserScript alloc] initWithSource:script injectionTime:injectionTime forMainFrameOnly:forMainFrameOnly];
        [self addUserScript:targetUserScript];
    }
}

- (void)mag_removeScript:(NSString *)script
{
    if (script.length == 0) return;
    NSMutableArray<WKUserScript *> *userScripts = [self.userScripts mutableCopy];
    WKUserScript *targetUserScript = nil;
    for (WKUserScript *userScript in userScripts) {
        if ([userScript.source isEqualToString:script]) {
            targetUserScript = userScript;
            break;
        }
    }
    if (targetUserScript) {
        [userScripts removeObject:targetUserScript];
    }
    [self removeAllUserScripts];
    for (WKUserScript *aUserScript in userScripts) {
        [self addUserScript:aUserScript];
    }
}

@end

@implementation WKProcessPool (MAGWebView)

+ (WKProcessPool *)mag_processPool
{
    static WKProcessPool *mag_processPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mag_processPool = [[WKProcessPool alloc] init];
    });
    return mag_processPool;
}

@end

@implementation NSHTTPCookie (MAGWebCookie)

- (NSString *)mag_cookieScriptValue
{
    NSString *name = self.name;
    NSString *value = self.value;
    NSString *domain = self.domain;
    NSString *path = self.path ? self.path : @"/";
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@", name, value, domain, path];
    if (self.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    return string;
}

@end

@implementation NSHTTPCookieStorage (MAGWebCookie)

+ (void)mag_clearCookies
{
    NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [sharedCookieStorage removeCookiesSinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
    if (sharedCookieStorage.cookies) {
        NSArray<NSHTTPCookie *> *cookies = [NSArray arrayWithArray:sharedCookieStorage.cookies];
        for (NSHTTPCookie *cookie in cookies) {
            [sharedCookieStorage deleteCookie:cookie];
        }
    }
}

@end

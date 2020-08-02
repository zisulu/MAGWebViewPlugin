//
//  MAGWebView.m
//  MAGWebViewPlugin
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

MAGWebContext MAGWebViewInitialContext(void)
{
    MAGWebContext webContext = MAGWebContextUIKit;
    if (@available(iOS 9.0, *)) {
        if (@available(iOS 12.0, *)) {
            webContext = MAGWebContextWebKit;
        } else {
            webContext = MAGWebContextWebKit;
        }
    } else {
        webContext = MAGWebContextUIKit;
    }
    return webContext;
}

@implementation MAGProcessPool

+ (instancetype)sharedProcessPool
{
    static MAGProcessPool *sharedProcessPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProcessPool = [[MAGProcessPool alloc] init];
    });
    return sharedProcessPool;
}

@end

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
        _mediaPlaybackRequiresUserAction = YES;
        _mediaPlaybackAllowsAirPlay = YES;
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
        configuration.processPool = [MAGProcessPool sharedProcessPool];
        configuration.allowsInlineMediaPlayback = YES;
        if (@available(iOS 10.0, *)) {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
            configuration.allowsAirPlayForMediaPlayback = YES;
        } else if (@available(iOS 9.0, *)) {
            configuration.requiresUserActionForMediaPlayback = YES;
            configuration.allowsAirPlayForMediaPlayback = YES;
        } else {
            configuration.mediaPlaybackRequiresUserAction = YES;
            configuration.mediaPlaybackAllowsAirPlay = YES;
        }
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

- (void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction
{
    if (_mediaPlaybackRequiresUserAction == mediaPlaybackRequiresUserAction) return;
    _mediaPlaybackRequiresUserAction = mediaPlaybackRequiresUserAction;
    WKWebViewConfiguration *configuration = self.wkConfiguration;
    if (@available(iOS 10.0, *)) {
        if (_mediaPlaybackRequiresUserAction) {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
        } else {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        }
    } else if (@available(iOS 9.0, *)) {
        configuration.requiresUserActionForMediaPlayback = _mediaPlaybackRequiresUserAction;
    } else {
        configuration.mediaPlaybackRequiresUserAction = _mediaPlaybackRequiresUserAction;
    }
}

- (void)setMediaPlaybackAllowsAirPlay:(BOOL)mediaPlaybackAllowsAirPlay
{
    if (_mediaPlaybackAllowsAirPlay == mediaPlaybackAllowsAirPlay) return;
    _mediaPlaybackAllowsAirPlay = mediaPlaybackAllowsAirPlay;
    WKWebViewConfiguration *configuration = self.wkConfiguration;
    if (@available(iOS 9.0, *)) {
        configuration.allowsAirPlayForMediaPlayback = _mediaPlaybackAllowsAirPlay;
    } else {
        configuration.mediaPlaybackAllowsAirPlay = _mediaPlaybackAllowsAirPlay;
    }
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

@interface MAGWebView ()<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy, readwrite, nullable) NSString *title;
@property (nonatomic, strong, readwrite, nullable) NSURLRequest *originRequest;
@property (nonatomic, strong, readwrite, nullable) NSURLRequest *currentRequest;
@property (nonatomic, readwrite) double estimatedProgress;
@property (nonatomic, assign) BOOL internal_scalesPageToFit;

@property (nonatomic, strong, readwrite) id webView;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, assign, readwrite) MAGWebContext webContext;
@property (nonatomic, strong, readwrite) MAGWebViewConfiguration *configuration;

@end

@implementation MAGWebView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _webContext = MAGWebViewInitialContext();
        [self internal_setupConfiguration];
        [self internal_setupWebView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _webContext = MAGWebViewInitialContext();
        [self internal_setupConfiguration];
        [self internal_setupWebView];
    }
    return self;
}

- (instancetype)initWithWebContext:(MAGWebContext)webContext
{
    MAGWebViewConfiguration *configuration = [[MAGWebViewConfiguration alloc] init];
    return [self initWithWebContext:webContext configuration:configuration];
}

- (instancetype)initWithConfiguration:(MAGWebViewConfiguration *)configuration
{
    MAGWebContext webContext = MAGWebViewInitialContext();
    return [self initWithWebContext:webContext configuration:configuration];
}

- (instancetype)initWithWebContext:(MAGWebContext)webContext configuration:(MAGWebViewConfiguration *)configuration
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _webContext = webContext;
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
    if ([self isUIWebView]) {
        [self initUIWebView];
    } else {
        [self initWKWebView];
    }
    [self setScalesPageToFit:YES];
    [self addWebLongPressRecognizer];
}

- (void)internal_resetWebView
{
    [self internal_resetWebViewWithURL:nil];
}

- (void)internal_resetWebViewWithURL:(NSURL *)requestURL
{
    if (self.webView) {
        if ([self isWKWebView]) {
            //remove KVO, avoid crash
            [[self wkWebView] removeObserver:self forKeyPath:@"estimatedProgress"];
        }
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
    [self internal_setupWebView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didResetWithURL:)]) {
        [self.delegate webView:self didResetWithURL:requestURL];
    }
}

- (void)initUIWebView
{
    MAGWebViewConfiguration *magConfiguration = _configuration;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.opaque = NO;
    webView.clipsToBounds = NO;
    webView.allowsInlineMediaPlayback = magConfiguration.allowsInlineMediaPlayback;
    webView.mediaPlaybackRequiresUserAction = magConfiguration.mediaPlaybackRequiresUserAction;
    webView.mediaPlaybackAllowsAirPlay = magConfiguration.mediaPlaybackAllowsAirPlay;
    webView.keyboardDisplayRequiresUserAction = NO;
    webView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = webView.scrollView;
    scrollView.clipsToBounds = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    scrollView.scrollsToTop = YES;
    webView.delegate = self;
    [self addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.webView = webView;
}

- (void)initWKWebView
{
    MAGWebViewConfiguration *magConfiguration = _configuration;
    WKWebViewConfiguration *wkConfiguration = magConfiguration.wkConfiguration;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:wkConfiguration];
    webView.opaque = NO;
    webView.clipsToBounds = NO;
    webView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = webView.scrollView;
    scrollView.clipsToBounds = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    scrollView.scrollsToTop = YES;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
        [WKWebView syncCookies:cookieStore];
    }
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [self addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.webView = webView;
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

- (void)internal_syncUserAgent:(NSString *)userAgent
{
    if (![userAgent isKindOfClass:[NSString class]]) return;
    NSDictionary *userAgentValues = @{
                                      @"UserAgent" : userAgent,
                                      };
    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentValues];
}

- (BOOL)isUIWebView
{
    return self.webContext == MAGWebContextUIKit;
}

- (BOOL)isWKWebView
{
    return self.webContext == MAGWebContextWebKit;
}

- (UIWebView *)uiWebView
{
    return (UIWebView *)self.webView;
}

- (WKWebView *)wkWebView
{
    return (WKWebView *)self.webView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.webView) {
            self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
            [self internal_webViewDidUpdateProgress:self.estimatedProgress];
        }
    }
}

#pragma mark ---------- UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self internal_webViewDidStartLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self internal_webViewDidFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self internal_webViewDidFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.currentRequest = request;
    BOOL result = [self internal_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
    return result;
}

#pragma mark ----------- WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    self.currentRequest = navigationAction.request;
    BOOL result = [self internal_webViewCanOpenRequestURL:self.currentRequest.URL];
    if (result) {
        //internal intercept
        [self internal_webViewOpenRequestURL:self.currentRequest.URL];
    }
    result = [self internal_webViewShouldStartLoadWithRequest:self.currentRequest navigationType:navigationAction.navigationType];
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
    [self internal_webViewDidStartLoad];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self internal_webViewDidFinishLoad];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self internal_webViewDidFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self internal_webViewDidFailLoadWithError:error];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [self internal_webViewWebContentProcessDidTerminate];
}

#pragma mark ---------- WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
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

- (void)internal_webViewDidFinishLoad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)internal_webViewDidStartLoad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
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
                //requestURL can be validated by internal_canOpenExternalURL, so we intercept requestHost
                NSArray<NSString *> *supportedHosts = [self.configuration customExternalHttpHosts];
                result = [supportedHosts containsObject:requestHost];
            } else {
                //tel, sms, mailto etc.
                result = [self internal_canOpenExternalURL:requestURL];
                if (result) {
                    //we also don't want some schemes to be intercepted.
                    NSArray *whiteSchemes = [self.configuration customWhiteSchemes];
                    if (whiteSchemes.count > 0 && [whiteSchemes containsObject:requestScheme]) {
                        //don't intercept
                        result = NO;
                    }
                } else {
                    //system canOpenURL failed, it means requestURL contains other untrusted URLScheme
                    NSString *validRequestPrefix = [NSString stringWithFormat:@"%@://", requestScheme];
                    if ([requestURL.absoluteString hasPrefix:validRequestPrefix]) {
                        //let user choose open URLScheme wether or not if URLScheme not be contained in customExternalSchemes
                        result = YES;
                    } else {
                        //don't intercepts about:blank、data:xxxx
                        result = NO;
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
        //intercept directly
        [self internal_openExternalURL:requestURL];
    } else {
        //the outside decides whether to intercept or not
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

- (void)internal_webViewDidFailLoadWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (BOOL)internal_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    BOOL result = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        if (navigationType == -1) {
            navigationType = MAGWebViewNavigationTypeOther;
        }
        result = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return result;
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

- (void)internal_webViewDidUpdateProgress:(double)progress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didUpdateProgress:)]) {
        [self.delegate webView:self didUpdateProgress:progress];
    }
}

- (UIScrollView *)scrollView
{
    UIScrollView *scrollView = nil;
    if ([self isUIWebView]) {
        scrollView = [self uiWebView].scrollView;
    } else {
        scrollView = [self wkWebView].scrollView;
    }
    return scrollView;
}

- (void)loadRequest:(NSURLRequest *)request
{
    BOOL shouldUserAgentUpdate = self.delegate && [self.delegate respondsToSelector:@selector(webView:userAgentUpdateWithURL:completionHandler:)];
    if (shouldUserAgentUpdate) {
        __weak typeof(self)wself = self;
        [self.delegate webView:self userAgentUpdateWithURL:request.URL completionHandler:^(NSString * _Nullable userAgent) {
            if (userAgent.length > 0) {
                [wself internal_syncUserAgent:userAgent];
                //WebView need reset
                [wself internal_resetWebViewWithURL:request.URL];
            }
            [wself internal_loadRequest:request];
        }];
    } else {
        [self internal_loadRequest:request];
    }
}

- (void)internal_loadRequest:(NSURLRequest *)request
{
    if ([self isUIWebView]) {
        UIWebView *webView = [self uiWebView];
        self.originRequest = request;
        self.currentRequest = request;
        [webView loadRequest:request];
    } else {
        WKWebView *webView = [self wkWebView];
        self.originRequest = request;
        self.currentRequest = request;
        [webView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    BOOL shouldUserAgentUpdate = self.delegate && [self.delegate respondsToSelector:@selector(webView:userAgentUpdateWithURL:completionHandler:)];
    if (shouldUserAgentUpdate && baseURL) {
        __weak typeof(self)wself = self;
        [self.delegate webView:self userAgentUpdateWithURL:baseURL completionHandler:^(NSString * _Nullable userAgent) {
            if (userAgent.length > 0) {
                [wself internal_syncUserAgent:userAgent];
                //WebView need reset
                [wself internal_resetWebViewWithURL:baseURL];
            }
            [wself internal_loadHTMLString:string baseURL:baseURL];
        }];
        return;
    }
    [self internal_loadHTMLString:string baseURL:baseURL];
}

- (void)internal_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if ([self isUIWebView]) {
        [[self uiWebView] loadHTMLString:string baseURL:baseURL];
    } else {
        [[self wkWebView] loadHTMLString:string baseURL:baseURL];
    }
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;
{
    if ([self isUIWebView]) {
        [[self uiWebView] loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    } else {
        if (@available(iOS 9.0, *)) {
            [[self wkWebView] loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
        }
    }
}

- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL
{
    if ([self isWKWebView]) {
        if (@available(iOS 9.0, *)) {
            [[self wkWebView] loadFileURL:URL allowingReadAccessToURL:readAccessURL];
        }
    }
}

- (NSString *)title
{
    if ([self isUIWebView]) {
        return [[self uiWebView] stringByEvaluatingJavaScriptFromString:@"document.title"];
    } else {
        return [self wkWebView].title;
    }
}

- (NSURL *)URL
{
    if ([self isUIWebView]) {
        return [self uiWebView].request.URL;
    } else {
        return [self wkWebView].URL;
    }
}

- (BOOL)canGoBack
{
    BOOL canGoBack = NO;
    if ([self isUIWebView]) {
        canGoBack = [self uiWebView].canGoBack;
    } else {
        canGoBack = [self wkWebView].canGoBack;
    }
    return canGoBack;
}

- (BOOL)canGoForward
{
    BOOL canGoForward = NO;
    if ([self isUIWebView]) {
        canGoForward = [self uiWebView].canGoForward;
    } else {
        canGoForward = [self wkWebView].canGoForward;
    }
    return canGoForward;
}

- (BOOL)isLoading
{
    BOOL isLoading = NO;
    if ([self isUIWebView]) {
        isLoading = [self uiWebView].isLoading;
    } else {
        isLoading = [self wkWebView].isLoading;
    }
    return isLoading;
}

- (void)reload
{
    if ([self isUIWebView]) {
        [[self uiWebView] reload];
    } else {
        [[self wkWebView] reload];
    }
}

- (void)reloadFromOrigin
{
    if ([self isUIWebView]) {
        if (self.originRequest) {
            [self evaluateJavaScript:[NSString stringWithFormat:@"window.location.replace('%@')", self.originRequest.URL.absoluteString] completionHandler:nil];
        }
    } else {
        [[self wkWebView] reloadFromOrigin];
    }
}

- (void)stopLoading
{
    if ([self isUIWebView]) {
        [[self uiWebView] stopLoading];
    } else {
        [[self wkWebView] stopLoading];
    }
}

- (void)goBack
{
    if ([self isUIWebView]) {
        [[self uiWebView] goBack];
    } else {
        [[self wkWebView] goBack];
    }
}

- (void)goForward;
{
    if ([self isUIWebView]) {
        [[self uiWebView] goForward];
    } else {
        [[self wkWebView] goForward];
    }
}

- (NSInteger)countOfHistory
{
    if ([self isUIWebView]) {
        int count = [[[self uiWebView] stringByEvaluatingJavaScriptFromString:@"window.history.length"] intValue];
        if (count) {
            return count;
        } else {
            return 1;
        }
    } else {
        return [self wkWebView].backForwardList.backList.count;
    }
}

- (void)gobackWithStep:(NSInteger)step
{
    if (self.canGoBack == NO) return;
    if (step > 0) {
        NSInteger historyCount = self.countOfHistory;
        if (step >= historyCount) {
            step = historyCount - 1;
        }
        if ([self isUIWebView]) {
            [[self uiWebView] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.history.go(-%@)", @(step)]];
        } else {
            WKBackForwardListItem *backItem = [self wkWebView].backForwardList.backList[step];
            [[self wkWebView] goToBackForwardListItem:backItem];
        }
    } else {
        [self goBack];
    }
}

- (BOOL)scalesPageToFit
{
    return _internal_scalesPageToFit;
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if ([self isUIWebView]) {
        [self uiWebView].scalesPageToFit = scalesPageToFit;
    } else {
        if (_internal_scalesPageToFit == scalesPageToFit) return;
        NSString *scaleScript = @"if(document.getElementsByTagName('head')){var hasViewPort = 0;var metas = document.getElementsByTagName('head')[0].getElementsByTagName('meta');for(var i = metas.length; i>=0 ; i--){var meta = metas[i];if(meta && meta.name == 'viewport'){hasViewPort = 1;break;}};if(hasViewPort == 0){var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);}};";
        WKUserContentController *userContentController = [self wkWebView].configuration.userContentController;
        NSMutableArray<WKUserScript *> *userScripts = [userContentController.userScripts mutableCopy];
        WKUserScript *targetUserScript = nil;
        for (WKUserScript *userScript in userScripts) {
            if ([userScript.source isEqualToString:scaleScript]) {
                targetUserScript = userScript;
                break;
            }
        }
        if (scalesPageToFit) {
            if (!targetUserScript) {
                targetUserScript = [[WKUserScript alloc] initWithSource:scaleScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
                [userContentController addUserScript:targetUserScript];
            }
        } else {
            if (targetUserScript) {
                [userScripts removeObject:targetUserScript];
            }
            [userContentController removeAllUserScripts];
            for (WKUserScript *aUserScript in userScripts) {
                [userContentController addUserScript:aUserScript];
            }
        }
    }
    _internal_scalesPageToFit = scalesPageToFit;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler
{
    if ([self isUIWebView]) {
        NSString *result = [[self uiWebView] stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(result, nil);
        }
    } else {
        [[self wkWebView] evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    NSString *result = nil;
    if ([self isUIWebView]) {
        result = [[self uiWebView] stringByEvaluatingJavaScriptFromString:javaScriptString];
    }
    return result;
}

- (void)dealloc
{
    if ([self isUIWebView]) {
        UIWebView *webView = [self uiWebView];
        webView.delegate = nil;
        [webView loadHTMLString:@"" baseURL:nil];
        webView.scrollView.delegate = nil;
        [webView stopLoading];
        [webView removeFromSuperview];
    } else {
        WKWebView *webView = [self wkWebView];
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
        [webView removeObserver:self forKeyPath:@"estimatedProgress"];
        webView.scrollView.delegate = nil;
        [webView stopLoading];
        [webView removeFromSuperview];
    }
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
    //获取NSHTTPCookieStorage的cookies
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
    //must be executed on a main queue
    dispatch_safe_async_main_queue(^{
        [self internal_clearCookies:completionHandler];
    });
}

+ (void)internal_clearCookies:(void (^)(void))completionHandler
{
    [NSHTTPCookieStorage clearCookies];
    if (@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            NSLog(@"Cookies清除成功");
            if (completionHandler) {
                completionHandler();
            }
        }];
    } else {
        NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryDirectory stringByAppendingString:@"/Cookies"];
        NSError *error = nil;;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&error];
        if (error) {
            NSLog(@"Cookies清除成功");
        } else {
            NSLog(@"Cookies清除失败");
        }
        if (completionHandler) {
            completionHandler();
        }
    }
}

@end

@implementation WKWebView (MAGWebCache)

+ (void)clearCaches
{
    [self clearCaches:nil];
}

+ (void)clearCaches:(void (^)(void))completionHandler
{
    //must be executed on a main queue
    dispatch_safe_async_main_queue(^{
        [self internal_clearCaches:nil];
    });
}

+ (void)internal_clearCaches:(void (^)(void))completionHandler
{
    NSURLCache *webCache = [NSURLCache sharedURLCache];
    [webCache removeAllCachedResponses];
    if (@available(iOS 9.0, *)) {
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
    } else {
        NSLog(@"WebCache清除成功");
        if (completionHandler) {
            completionHandler();
        }
    }
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

+ (void)clearCookies
{
    NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [sharedCookieStorage removeCookiesSinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
}

@end

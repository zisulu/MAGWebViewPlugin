//
//  MAGWebView.m
//  MAGWebViewPlugin
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import "MAGWebView.h"
#import <Masonry/Masonry.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

static NSString * const kMAGWebViewProgressKVO                  = @"estimatedProgress";
static NSString * const kMAGWKWebCookies                        = @"com.lyeah.wkwebcookies";

static NSString * const kMAGWebViewTitleJavascript              = @"document.title";
static NSString * const kMAGWebViewHrefJavascript               = @"window.location.href";

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

@interface MAGWebView ()<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy, readwrite, nullable) NSString *title;
@property (nonatomic, strong, readwrite, nullable) NSURLRequest *originRequest;
@property (nonatomic, strong, readwrite, nullable) NSURLRequest *currentRequest;
@property (nonatomic, readwrite) double estimatedProgress;
@property (nonatomic, assign) BOOL internal_scalesPageToFit;

@property (nonatomic, strong, readwrite) id webView;
@property (nullable, nonatomic, strong, readwrite) id javascriptBridge;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, copy, readwrite, nullable) NSString *locationHref;

@end

@implementation MAGWebView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _webContext = [self initialWebContext];
        [self setupWebView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _webContext = [self initialWebContext];
        [self setupWebView];
    }
    return self;
}

- (instancetype)initWithWebContext:(MAGWebContext)webContext
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _webContext = webContext;
        [self setupWebView];
    }
    return self;
}

- (MAGWebContext)initialWebContext
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

- (void)setWebContext:(MAGWebContext)webContext
{
    if (_webContext == webContext) return;
    _webContext = webContext;
    [self setupWebView];
}

- (void)setupWebView
{
    if (self.webView) {
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
    self.javascriptBridge = nil;
    if ([self isUIWebView]) {
        [self initUIWebView];
    } else {
        [self initWKWebView];
    }
    [self setScalesPageToFit:YES];
    [self addWebLongPressRecognizer];
}

- (void)initUIWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.opaque = NO;
    webView.clipsToBounds = NO;
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.keyboardDisplayRequiresUserAction = NO;
    webView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = webView.scrollView;
    scrollView.clipsToBounds = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    scrollView.scrollsToTop = YES;
    [self addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.webView = webView;
}

- (void)initWKWebView
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    configuration.userContentController = userContentController;
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    configuration.processPool = [MAGProcessPool sharedProcessPool];
    configuration.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    } else if (@available(iOS 9.0, *)) {
        configuration.requiresUserActionForMediaPlayback = NO;
    } else {
        configuration.mediaPlaybackRequiresUserAction = NO;
    }
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    webView.opaque = NO;
    webView.clipsToBounds = NO;
    webView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = webView.scrollView;
    scrollView.clipsToBounds = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    scrollView.scrollsToTop = YES;
    [webView addObserver:self forKeyPath:kMAGWebViewProgressKVO options:NSKeyValueObservingOptionNew context:nil];
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
        [WKWebView syncCookies:cookieStore];
    }
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
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)syncUserAgent:(NSString *)userAgent
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
    if ([keyPath isEqualToString:kMAGWebViewProgressKVO]) {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
        [self internal_webViewDidUpdateProgress:self.estimatedProgress];
    }
}

- (void)setDelegate:(id<MAGWebViewDelegate>)delegate
{
    _delegate = delegate;
    if ([self isUIWebView]) {
        UIWebView *webView = [self uiWebView];
        webView.delegate = self;
        [WebViewJavascriptBridge enableLogging];
        WebViewJavascriptBridge *javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:webView];
        [javascriptBridge setWebViewDelegate:self];
        self.javascriptBridge = javascriptBridge;
    } else {
        WKWebView *webView = [self wkWebView];
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        [WKWebViewJavascriptBridge enableLogging];
        WKWebViewJavascriptBridge *javascriptBridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
        [javascriptBridge setWebViewDelegate:self];
        self.javascriptBridge = javascriptBridge;
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
    self.currentRequest = [self internal_fixRequest:navigationAction.request];
    BOOL result = [self internal_webViewShouldStartLoadWithRequest:self.currentRequest navigationType:navigationAction.navigationType];
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
        // iOS 11 也有这种获取方式，但是 iOS 11 可以在response里面直接获取到，只有 iOS 12 获取不到
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
        self.currentRequest = [self internal_fixRequest:navigationAction.request];
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
    __weak typeof(self)wself = self;
    [self evaluateJavaScript:kMAGWebViewHrefJavascript completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        wself.locationHref = response;
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)internal_webViewDidStartLoad
{
    __weak typeof(self)wself = self;
    [self evaluateJavaScript:kMAGWebViewHrefJavascript completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        wself.locationHref = response;
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
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
    BOOL shouldUserAgentUpdate = self.delegate && [self.delegate respondsToSelector:@selector(webView:userAgentUpdateWithRequestURL:completionHandler:)];
    if (shouldUserAgentUpdate) {
        __weak typeof(self)wself = self;
        [self.delegate webView:self userAgentUpdateWithRequestURL:request.URL completionHandler:^(NSString * _Nullable userAgent) {
            if (userAgent.length > 0) {
                [wself syncUserAgent:userAgent];
                //UIWebView只有首次初始化才能更新UserAgent
                if ([wself isUIWebView]) {
                    [wself setupWebView];
                }
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
        NSString *domain = request.URL.host;
        if (domain) {
            WKUserScript *userScript = [WKWebView searchCookieUserScriptWithDomain:domain];
            [webView.configuration.userContentController addUserScript:userScript];
        }
        request = [self internal_fixRequest:request];
        self.originRequest = request;
        self.currentRequest = request;
        [webView loadRequest:request];
    }
}

- (NSURLRequest *)internal_fixRequest:(NSURLRequest *)request
{
    if ([self isUIWebView]) return request;
    NSMutableURLRequest *fixedRequest = nil;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        fixedRequest = (NSMutableURLRequest *)request;
    } else {
        fixedRequest = [request mutableCopy];
    }
    NSDictionary<NSString *, NSString *> *cookieData = [NSHTTPCookie requestHeaderFieldsWithCookies:[WKWebView sharedCookieStorage]];
    if (cookieData.count > 0) {
        NSMutableDictionary<NSString *, NSString *> *mutableFields = [NSMutableDictionary dictionary];
        if (request.allHTTPHeaderFields) {
            mutableFields = [request.allHTTPHeaderFields mutableCopy];
        }
        [mutableFields setValuesForKeysWithDictionary:cookieData];
        fixedRequest.allHTTPHeaderFields = [mutableFields copy];
    }
    return fixedRequest;
}

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    BOOL shouldUserAgentUpdate = self.delegate && [self.delegate respondsToSelector:@selector(webView:userAgentUpdateWithRequestURL:completionHandler:)];
    if (shouldUserAgentUpdate && baseURL) {
        __weak typeof(self)wself = self;
        [self.delegate webView:self userAgentUpdateWithRequestURL:baseURL completionHandler:^(NSString * _Nullable userAgent) {
            if (userAgent.length > 0) {
                [wself syncUserAgent:userAgent];
                //UIWebView只有首次初始化才能更新UserAgent
                if ([wself isUIWebView]) {
                    [wself setupWebView];
                }
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

- (NSString *)title
{
    if ([self isUIWebView]) {
        return [[self uiWebView] stringByEvaluatingJavaScriptFromString:kMAGWebViewTitleJavascript];
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
        NSString *scaleScript =
        @"var head = document.getElementsByTagName('head')[0];\
        var hasViewPort = 0;\
        var metas = head.getElementsByTagName('meta');\
        for (var i = metas.length; i>=0 ; i--) {\
        var m = metas[i];\
        if (m.name == 'viewport') {\
        hasViewPort = 1;\
        break;\
        }\
        }; \
        if(hasViewPort == 0) { \
        var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
        head.appendChild(meta);\
        }";
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
        [webView removeObserver:self forKeyPath:kMAGWebViewProgressKVO];
        webView.scrollView.delegate = nil;
        [webView stopLoading];
        [webView removeFromSuperview];
    }
    self.javascriptBridge = nil;
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
        NSMutableArray<NSHTTPCookie *> *localCookies = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kMAGWKWebCookies]];
        NSMutableArray<NSHTTPCookie *> *latestCookies = [NSMutableArray array];
        for (NSInteger i=0;i<localCookies.count;i++) {
            NSHTTPCookie *tempCookie = localCookies[i];
            if ([cookie.name isEqualToString:tempCookie.name] && [cookie.domain isEqualToString:tempCookie.domain]) {
                continue;
            }
            [latestCookies addObject:tempCookie];
        }
        [latestCookies addObject:cookie];
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:latestCookies];
        [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kMAGWKWebCookies];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    @autoreleasepool {
        NSMutableArray<NSHTTPCookie *> *mutableCookies = [NSMutableArray array];
        //获取NSHTTPCookieStorage的cookies
        NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [mutableCookies addObjectsFromArray:sharedCookieStorage.cookies];
        //获取自定义存储的cookies
        NSMutableArray<NSHTTPCookie *> *localCookies = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kMAGWKWebCookies]];
        NSMutableArray<NSHTTPCookie *> *latestCookies = [NSMutableArray array];
        for (NSInteger i=0;i<localCookies.count;i++) {
            NSHTTPCookie *cookie = localCookies[i];
            if (!cookie.expiresDate) {
                [mutableCookies addObject:cookie];
                [latestCookies addObject:cookie];
                continue;
            }
            //过滤过期的cookies
            if ([cookie.expiresDate compare:[NSDate dateWithTimeIntervalSinceNow:0]]) {
                [mutableCookies addObject:cookie];
                [latestCookies addObject:cookie];
            }
        }
        //存储最新有效的cookies
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:latestCookies];
        [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kMAGWKWebCookies];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return mutableCookies;
    }
}

+ (void)clearCookies
{
    if (@available(iOS 11.0, *)) {
        NSSet *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
    }
    [NSHTTPCookieStorage clearCookies];
    [self clearLocalCookies];
}

+ (void)clearLocalCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kMAGWKWebCookies];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)cookieScriptWithDomain:(NSString *)domain
{
    @autoreleasepool {
        NSMutableString *mutableCookie = [NSMutableString string];
        NSArray *cookies = [self sharedCookieStorage];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.domain containsString:domain]) {
                [mutableCookie appendString:[NSString stringWithFormat:@"document.cookie = '%@';", cookie.mag_cookieScriptValue]];
            }
        }
        return [mutableCookie copy];
    }
}

+ (WKUserScript *)searchCookieUserScriptWithDomain:(NSString *)domain
{
    NSString *cookie = [self cookieScriptWithDomain:domain];
    WKUserScript *cookieUserScript = [[WKUserScript alloc] initWithSource:cookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    return cookieUserScript;
}

@end

@implementation WKWebView (MAGWebCache)

+ (void)clearCaches
{
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
        
    }];
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
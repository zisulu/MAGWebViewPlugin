//
//  MAGWebView.h
//  MAGWebViewPlugin
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MAGWebContext) {
    MAGWebContextUIKit,     //context is UIWebView
    MAGWebContextWebKit,    //context is WKWebView
};

typedef NS_ENUM(NSUInteger, MAGWebViewNavigationType) {
    MAGWebViewNavigationTypeLinkClicked,
    MAGWebViewNavigationTypeFormSubmitted,
    MAGWebViewNavigationTypeBackForward,
    MAGWebViewNavigationTypeReload,
    MAGWebViewNavigationTypeFormResubmitted,
    MAGWebViewNavigationTypeOther
};

@protocol MAGWebView;

@protocol MAGWebViewDelegate <NSObject>

@optional

//General WebView begin
- (BOOL)webView:(id<MAGWebView>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(MAGWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(id<MAGWebView>)webView;
- (void)webViewDidFinishLoad:(id<MAGWebView>)webView;
- (void)webView:(id<MAGWebView>)webView didFailLoadWithError:(NSError *)error;
//General WebView end

//Only WKWebView begin
- (void)webView:(id<MAGWebView>)webView didUpdateProgress:(CGFloat)progress;
- (void)webViewWebContentProcessDidTerminate:(id<MAGWebView>)webView;
- (void)webView:(id<MAGWebView>)webView showAlertWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler;
- (void)webView:(id<MAGWebView>)webView showConfirmAlertWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler;
- (void)webView:(id<MAGWebView>)webView showTextInputAlertWithMessage:(NSString *)message placeholder:(NSString *)placeholder completionHandler:(void (^)(NSString *result))completionHandler;
//Only WKWebView end

/**
 Used for update the whole UserAgent if needed.
 
 @param webView MAGWebView
 @param requestURL requestURL
 @param completionHandler must call this handler, otherwise -loadRequest will not be triggered, UserAgent will not be updated.
 if userAgent.length == 0, only trigger -loadRequest and will not update UserAgent.
 */
- (void)webView:(id<MAGWebView>)webView userAgentUpdateWithRequestURL:(NSURL *)requestURL completionHandler:(void(^)(NSString *_Nullable userAgent))completionHandler;

/**
 longPressGestureRecognizer on webView
 
 @param webView MAGWebView
 @param longPressGestureRecognizer longPressGestureRecognizer
 */
- (void)webView:(id<MAGWebView>)webView longPressGestureRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer;

@end

@protocol MAGWebView <NSObject>

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nullable, nonatomic, copy, readonly) NSString *title;
@property (nullable, nonatomic, strong, readonly) NSURLRequest *originRequest;
@property (nullable, nonatomic, strong, readonly) NSURLRequest *currentRequest;
@property (nullable, nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, assign, readonly) BOOL canGoBack;
@property (nonatomic, assign, readonly) BOOL canGoForward;
@property (nonatomic, readonly) double estimatedProgress;
@property (nonatomic, assign) BOOL scalesPageToFit;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

- (void)reload;
- (void)reloadFromOrigin;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;
- (void)gobackWithStep:(NSInteger)step;

- (NSInteger)countOfHistory;

/**
 UIWebView or WKWebView support both
 For UIWebView is sync
 for WKWebView is async
 */
- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^ _Nullable)(id _Nullable response, NSError *_Nullable error))completionHandler;

/**
 For UIWebView only
 */
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString;

@end

@interface MAGProcessPool : WKProcessPool

+ (instancetype)sharedProcessPool;

@end

/**
 Feature            UIWebView       WKWebView
 JS执行速度             慢               快
 内存占用               大               小
 进度条                无               有
 Cookie             自动存储         需手动存储
 缓存                 有               无
 NSURLProtocol拦截    可以              不可以
 */
@interface MAGWebView : UIView<MAGWebView>

@property (nullable, nonatomic, weak) id<MAGWebViewDelegate> delegate;

/**
 UIWebView or WKWebView
 */
@property (nonatomic, strong, readonly) id webView;

/**
 No delegate, No javascriptBridge;
 Relay on WebViewJavascriptBridge or WKWebViewJavascriptBridge;
 */
@property (nullable, nonatomic, strong, readonly) id javascriptBridge;

@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 window.location.href
 */
@property (nullable, nonatomic, copy, readonly) NSString *locationHref;

/**
 if don't use -initWithWebViewType to initialize, MAGWebView will init default type:
 1.iOS 8.x support UIWebView only
 2.iOS 9.0 - iOS 11.x
 -UIWebView or WKWebView support both，default use WKWebView.
 -You can change webViewType to switch after init, but must before call any methods.
 3.iOS 12.0 ~ support WKWebView only
 */
@property (nonatomic, assign) MAGWebContext webContext;

- (instancetype)initWithWebContext:(MAGWebContext)webContext;

@end

@interface WKWebView (MAGWebCookie)

/**
 sync cookie to WKHTTPCookieStore
 */
+ (void)syncCookies:(WKHTTPCookieStore *)cookieStore API_AVAILABLE(ios(11.0));

/**
 intsert cookies to disk
 */
- (void)insertCookie:(NSHTTPCookie *)cookie;
- (void)insertCookies:(NSArray<NSHTTPCookie *> *)cookies;

/**
 fetch cookies from disk
 */
+ (NSArray<NSHTTPCookie *> *)sharedCookieStorage;

/**
 delete all cookies
 */
+ (void)clearCookies;

+ (NSString *)cookieScriptWithDomain:(NSString *)domain;
+ (WKUserScript *)searchCookieUserScriptWithDomain:(NSString *)domain;

@end

@interface WKWebView (MAGWebCache)

/**
 clear all caches except cookies
 */
+ (void)clearCaches API_AVAILABLE(ios(9.0));

@end

@interface NSHTTPCookie (MAGWebCookie)

- (NSString *)mag_cookieScriptValue;

@end

@interface NSHTTPCookieStorage (MAGWebCookie)

/**
 delete all cookies
 */
+ (void)clearCookies;

@end

NS_ASSUME_NONNULL_END

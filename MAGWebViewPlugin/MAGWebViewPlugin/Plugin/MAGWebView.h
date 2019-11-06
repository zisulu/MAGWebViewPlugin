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

UIKIT_EXTERN MAGWebContext MAGWebViewInitialContext(void);

@protocol MAGWebView;

@protocol MAGWebViewDelegate <NSObject>

@optional

- (BOOL)webView:(id<MAGWebView>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(MAGWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(id<MAGWebView>)webView;
- (void)webViewDidFinishLoad:(id<MAGWebView>)webView;
- (void)webView:(id<MAGWebView>)webView didFailLoadWithError:(NSError *)error;

- (void)webView:(id<MAGWebView>)webView didUpdateProgress:(CGFloat)progress;
- (void)webViewWebContentProcessDidTerminate:(id<MAGWebView>)webView;
- (void)webView:(id<MAGWebView>)webView showAlertWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler;
- (void)webView:(id<MAGWebView>)webView showConfirmAlertWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler;
- (void)webView:(id<MAGWebView>)webView showTextInputAlertWithMessage:(NSString *)message placeholder:(NSString *)placeholder completionHandler:(void (^)(NSString *result))completionHandler;

/**
 Do something after the UIWebView or WKWebView has been recreated.
 
 @param webView MAGWebView
 @param requestURL requestURL
 */
- (void)webView:(id<MAGWebView>)webView didResetWithURL:(NSURL *)requestURL;

/**
 Used for update the whole UserAgent if needed.
 
 @param webView MAGWebView
 @param requestURL requestURL
 @param completionHandler must call this handler, otherwise -loadRequest will not be triggered, UserAgent will not be updated.
 */
- (void)webView:(id<MAGWebView>)webView userAgentUpdateWithURL:(NSURL *)requestURL completionHandler:(void(^)(NSString *_Nullable userAgent))completionHandler;

/**
 longPressGestureRecognizer on webView
 
 @param webView MAGWebView
 @param longPressGestureRecognizer longPressGestureRecognizer
 */
- (void)webView:(id<MAGWebView>)webView longPressGestureRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer;

/**
 Some links like sms, tel, mailto
 
 @param webView MAGWebView
 @param externalURL externalURL
 @param completionHandler completionHandler
 */
- (void)webView:(id<MAGWebView>)webView openExternalURL:(NSURL *)externalURL completionHandler:(void (^)(BOOL result))completionHandler;

@end

@interface MAGProcessPool : WKProcessPool

+ (instancetype)sharedProcessPool;

@end

@interface MAGWebViewConfiguration : NSObject

/*
 A WKWebViewConfiguration object is a collection of properties with
 which to initialize a web view.
 @helps Contains properties used to configure a @link WKWebView @/link.
 
 The preference settings to be used by the WKWebView.
 javaScriptCanOpenWindowsAutomatically is YES by default.
 */
@property (nonatomic, copy, readonly) WKWebViewConfiguration *wkConfiguration;

/**
 The default value is YES.
 */
@property (nonatomic) BOOL allowsInlineMediaPlayback;

/**
 The default value is YES.
 */
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;

/**
 The default value is YES.
 */
@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay;

/**
 An array contains white schemes that does not internally intercept.
 Default contain @"http", @"https"
 customExternalHttpHosts > customWhiteSchemes > customExternalSchemes
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *customWhiteSchemes;
- (void)addCustomWhiteSchemes:(NSArray<NSString *> *)schemes;
- (void)removeCustomWhiteSchemes:(NSArray<NSString *> *)schemes;

/**
 An array contains schemes that that needs needs be opened externally.
 Default contain @"tel", @"sms", @"mailto"
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *customExternalSchemes;
- (void)addCustomExternalSchemes:(NSArray<NSString *> *)schemes;
- (void)removeCustomExternalSchemes:(NSArray<NSString *> *)schemes;

/**
 An array contains http or https hosts that needs be opened externally.
 Default contain @"itunes.apple.com",
 @"itunesconnect.apple.com",
 @"appstoreconnect.apple.com"
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *customExternalHttpHosts;
- (void)addCustomExternalHttpHosts:(NSArray<NSString *> *)httpHosts;
- (void)removeCustomExternalHttpHosts:(NSArray<NSString *> *)httpHosts;

@end

@protocol MAGWebView <NSObject>

/// System

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

/**
 For UIWebView: iOS 8.0 and later
 For WKWebView: iOS 9.0 and later
 */
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

/**
 For WKWebView Only
 */
- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL API_AVAILABLE(ios(9.0));

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

/// Custom

/**
 UIWebView or WKWebView
 */
@property (nonatomic, strong, readonly) id webView;

/**
 if don't use -initWithWebContext to initialize, MAGWebView will init default type:
 1.iOS 8.x support UIWebView only
 2.iOS 9.0 - iOS 11.x
 -UIWebView or WKWebView support both，default use WKWebView.
 -You can change webViewType to switch after init, but must before call any methods.
 3.iOS 12.0 ~ support WKWebView only
 */
@property (nonatomic, assign, readonly) MAGWebContext webContext;

/**
 MAGWebView common configuration
 */
@property (nonatomic, strong, readonly) MAGWebViewConfiguration *configuration;

/**
 longPressGestureRecognizer related to UIWebView or WKWebView
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

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

@property (nonatomic, weak) id<MAGWebViewDelegate> delegate;

- (instancetype)initWithWebContext:(MAGWebContext)webContext;
- (instancetype)initWithConfiguration:(MAGWebViewConfiguration *)configuration;
- (instancetype)initWithWebContext:(MAGWebContext)webContext configuration:(MAGWebViewConfiguration *)configuration;

@end

@interface WKWebView (MAGWebCookie)

/**
 sync cookie to WKHTTPCookieStore
 */
+ (void)syncCookies:(WKHTTPCookieStore *)cookieStore API_AVAILABLE(ios(11.0));
- (void)insertCookie:(NSHTTPCookie *)cookie;
- (void)insertCookies:(NSArray<NSHTTPCookie *> *)cookies;

/**
 fetch cookies
 */
+ (NSArray<NSHTTPCookie *> *)sharedCookieStorage;

/**
 delete all cookies
 */
+ (void)clearCookies;
+ (void)clearCookies:(void (^_Nullable)(void))completionHandler;

@end

@interface WKWebView (MAGWebCache)

/**
 clear all caches except cookies
 */
+ (void)clearCaches;
+ (void)clearCaches:(void (^_Nullable)(void))completionHandler;

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

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

typedef NS_OPTIONS(NSUInteger, MAGWebDataDetectorTypes) {
    MAGWebDataDetectorTypeNone = 0,
    MAGWebDataDetectorTypePhoneNumber = 1 << 0,
    MAGWebDataDetectorTypeLink = 1 << 1,
    MAGWebDataDetectorTypeAddress = 1 << 2,
    MAGWebDataDetectorTypeCalendarEvent = 1 << 3,
    MAGWebDataDetectorTypeTrackingNumber = 1 << 4,
    MAGWebDataDetectorTypeFlightNumber = 1 << 5,
    MAGWebDataDetectorTypeLookupSuggestion = 1 << 6,
    MAGWebDataDetectorTypeAll = NSUIntegerMax,
};

UIKIT_EXTERN MAGWebContext MAGWebViewInitialContext(void);

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
- (void)webView:(id<MAGWebView>)webView userAgentUpdateWithURL:(NSURL *)requestURL completionHandler:(void(^)(NSString *_Nullable userAgent))completionHandler;

/**
 When MAGWebViewDelegate will be reseted, it means UIWebView or WKWebView will be recreated;
 
 @param webView MAGWebView
 @param requestURL requestURL
 */
- (void)webView:(id<MAGWebView>)webView willResetWithURL:(NSURL *)requestURL;

/**
 When MAGWebViewDelegate is reseted, it means UIWebView or WKWebView is recreated;
 
 @param webView MAGWebView
 @param requestURL requestURL
 */
- (void)webView:(id<MAGWebView>)webView didResetWithURL:(NSURL *)requestURL;

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

@interface MAGWebViewConfiguration : NSObject

/**
 The default value is YES.
 */
@property (nonatomic) BOOL allowsInlineMediaPlayback;

/**
 The default value is NO.
 */
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;

/**
 The default value is YES.
 */
@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay;

/**
 An enum value indicating the type of data detection desired.
 @discussion The default value is MAGWebDataDetectorTypePhoneNumber|MAGWebDataDetectorTypeLink.
 */
@property (nonatomic) MAGWebDataDetectorTypes dataDetectorTypes;

/*
 A Boolean value indicating whether the web view suppresses
 content rendering until it is fully loaded into memory.
 @discussion The default value is NO.
 */
@property (nonatomic) BOOL suppressesIncrementalRendering;

/*
 The preference settings to be used by the WKWebView.
 javaScriptCanOpenWindowsAutomatically is YES by default.
 */
@property (nonatomic, strong) WKPreferences *preferences;

/*
 The user content controller to associate with the WKWebView.
 */
@property (nonatomic, strong) WKUserContentController *userContentController;

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

/**
 UIWebView or WKWebView
 */
@property (nonatomic, strong, readonly) id webView;

/**
 longPressGestureRecognizer related to UIWebView or WKWebView
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 if don't use -initWithWebViewType to initialize, MAGWebView will init default type:
 1.iOS 8.x support UIWebView only
 2.iOS 9.0 - iOS 11.x
 -UIWebView or WKWebView support both，default use WKWebView.
 -You can change webViewType to switch after init, but must before call any methods.
 3.iOS 12.0 ~ support WKWebView only
 */
@property (nonatomic, assign) MAGWebContext webContext;

@property (nonatomic, strong) MAGWebViewConfiguration *configuration;

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

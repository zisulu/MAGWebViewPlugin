//
//  MAGWebView.h
//  MAGWebView
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MAGWebView;

@protocol MAGWebViewDelegate <NSObject>

@optional

/// 这里方法命名需要避免和废弃API一样
- (BOOL)webView:(id<MAGWebView>)webView shouldAllowWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType;
- (void)webViewDidLoadStarted:(id<MAGWebView>)webView;
- (void)webViewDidLoadFinished:(id<MAGWebView>)webView;
- (void)webView:(id<MAGWebView>)webView didLoadFailedWithError:(NSError *)error;

- (void)webView:(id<MAGWebView>)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;
- (void)webViewWebContentProcessDidTerminate:(id<MAGWebView>)webView;

- (void)webView:(id<MAGWebView>)webView showAlertWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler;
- (void)webView:(id<MAGWebView>)webView showConfirmAlertWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler;
- (void)webView:(id<MAGWebView>)webView showTextInputAlertWithMessage:(NSString *)message placeholder:(NSString *)placeholder completionHandler:(void (^)(NSString *result))completionHandler;

- (void)webView:(id<MAGWebView>)webView didUpdateTitle:(NSString *)title;
- (void)webView:(id<MAGWebView>)webView didUpdateProgress:(CGFloat)progress;

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
@property (nonatomic) BOOL allowsUserActionForMediaPlayback;

/**
 The default value is YES.
 */
@property (nonatomic) BOOL allowsAirPlayForMediaPlayback;

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
@property (nonatomic, assign) BOOL allowsLinkPreview;

@property (nullable, nonatomic, copy) NSString *customUserAgent;

- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request;
- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

- (nullable WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL;

- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL;

- (nullable WKNavigation *)reload;
- (nullable WKNavigation *)reloadFromOrigin;
- (void)stopLoading;

- (nullable WKNavigation *)goBack;
- (nullable WKNavigation *)goForward;
- (nullable WKNavigation *)goBackWithStep:(NSInteger)step;

- (NSInteger)countOfHistory;

- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^ _Nullable)(id _Nullable response, NSError *_Nullable error))completionHandler;

/// Custom

@property (nonatomic, strong, readonly) WKWebView *webView;

/**
 MAGWebView common configuration
 */
@property (nonatomic, strong, readonly) MAGWebViewConfiguration *configuration;

/**
 longPressGestureRecognizer related to WKWebView
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@interface MAGWebView : UIView<MAGWebView>

@property (nonatomic, weak) id<MAGWebViewDelegate> delegate;

- (instancetype)initWithConfiguration:(MAGWebViewConfiguration *)configuration;

- (void)updateUserAgent:(NSString *)userAgent completionHandler:(void (^ _Nullable)(void))completionHandler;

@end

@interface WKWebView (MAGWebView)

+ (WKWebView *)mag_webView;
+ (WKWebView *)mag_webViewWithConfiguration:(MAGWebViewConfiguration *)configuration;

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

@interface WKUserContentController (MAGWebScript)

+ (NSString *)mag_webPageScaleFitScript;
- (void)mag_addScriptAtDocumentEnd:(NSString *)script;
- (void)mag_addScriptForMainFrameAtDocumentEnd:(NSString *)script;
- (void)mag_addScriptAtDocumentStart:(NSString *)script;
- (void)mag_addScriptForMainFrameDocumentStart:(NSString *)script;
- (void)mag_addScript:(NSString *)script injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly;
- (void)mag_removeScript:(NSString *)script;

@end

@interface WKProcessPool (MAGWebView)

+ (WKProcessPool *)mag_processPool;

@end

@interface NSHTTPCookie (MAGWebCookie)

- (NSString *)mag_cookieScriptValue;

@end

@interface NSHTTPCookieStorage (MAGWebCookie)

/**
 delete all cookies
 */
+ (void)mag_clearCookies;

@end

NS_ASSUME_NONNULL_END

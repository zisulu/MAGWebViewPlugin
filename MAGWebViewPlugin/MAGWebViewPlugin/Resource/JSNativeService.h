//
//  JSNativeService.h
//  MAGWebView
//
//  Created by appl on 2019/5/5.
//  Copyright © 2019 lyeah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface JSNativeService : NSObject <WKScriptMessageHandler>

+ (JSNativeService *)doJSRegistry:(WKWebView *)webView context:(__kindof UIViewController *)context;

@end

@interface JSNativeService (WebLifeCycle)

- (void)pageAppear;
- (void)pageDisappear;
- (void)pageDestroy;

@end
























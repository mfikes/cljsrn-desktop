/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTWebView.h"

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>

#import "RCTAutoInsetsProtocol.h"
#import "RCTEventDispatcher.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTView.h"
#import "NSView+React.h"

NSString *const RCTJSNavigationScheme = @"react-js-navigation";

@interface RCTWebView () <WebResourceLoadDelegate, RCTAutoInsetsProtocol>

@property (nonatomic, copy) RCTDirectEventBlock onLoadingStart;
@property (nonatomic, copy) RCTDirectEventBlock onLoadingFinish;
@property (nonatomic, copy) RCTDirectEventBlock onLoadingError;

@end

@implementation RCTWebView
{
  WebView *_webView;
  NSString *_injectedJavaScript;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:[[NSColor clearColor] CGColor]]; //RGB plus Alpha Channel
    [self setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self setLayer:viewLayer];
    _automaticallyAdjustContentInsets = YES;
    _contentInset = NSEdgeInsetsZero;
    _webView = [[WebView alloc] initWithFrame:self.bounds];
    [_webView setResourceLoadDelegate:self];//_webView.delegate = self;
    [self addSubview:_webView];
  }
  return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (void)goForward
{
  [_webView goForward];
}

- (void)goBack
{
  [_webView goBack];
}

- (void)reload
{
  [_webView reload:self];
}

//- (NSURL *)URL
//{
//  return _webView.re.URL;
//}
//
//- (void)setURL:(NSURL *)URL
//{
//  // Because of the way React works, as pages redirect, we actually end up
//  // passing the redirect urls back here, so we ignore them if trying to load
//  // the same url. We'll expose a call to 'reload' to allow a user to load
//  // the existing page.
//  if ([URL isEqual:_webView.request.URL]) {
//    return;
//  }
//  if (!URL) {
//    // Clear the webview
//    [_webView loadHTMLString:@"" baseURL:nil];
//    return;
//  }
//  [_webView loadRequest:[NSURLRequest requestWithURL:URL]];
//}
//
//- (void)setHTML:(NSString *)HTML
//{
//  [_webView loadHTMLString:HTML baseURL:nil];
//}

- (void)layout
{
  [super layout];
  _webView.frame = self.bounds;
}

- (void)setContentInset:(NSEdgeInsets)contentInset
{
  _contentInset = contentInset;
//  [RCTView autoAdjustInsetsForView:self
//                    withScrollView:_webView.scrollView
//                      updateOffset:NO];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
  CGFloat alpha = CGColorGetAlpha(backgroundColor.CGColor);
  [self.layer setOpaque:(alpha == 1.0)];
  [[_webView layer] setBackgroundColor:[backgroundColor CGColor]];
}

//- (NSColor *)backgroundColor
//{
//  return _webView.layer.backgroundColor;
//}

- (NSMutableDictionary *)baseEvent
{
  NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary: @{
    @"url": @"", // TODO: _webView.request.URL.absoluteString ?:
    @"loading" : @(_webView.loading),
    @"title": [_webView stringByEvaluatingJavaScriptFromString:@"document.title"],
    @"canGoBack": @(_webView.canGoBack),
    @"canGoForward" : @(_webView.canGoForward),
  }];

  return event;
}

- (void)refreshContentInset
{
//  [RCTView autoAdjustInsetsForView:self
//                    withScrollView:_webView.scrollView
//                      updateOffset:YES];
}

#pragma mark - UIWebViewDelegate methods

//- (BOOL)webView:(__unused NSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
// navigationType:(NSWebViewNavigationType)navigationType
//{
//  if (_onLoadingStart) {
//    // We have this check to filter out iframe requests and whatnot
//    BOOL isTopFrame = [request.URL isEqual:request.mainDocumentURL];
//    if (isTopFrame) {
//      NSMutableDictionary *event = [self baseEvent];
//      [event addEntriesFromDictionary: @{
//        @"url": (request.URL).absoluteString,
//        @"navigationType": @(navigationType)
//      }];
//      _onLoadingStart(event);
//    }
//  }
//
//  // JS Navigation handler
//  return ![request.URL.scheme isEqualToString:RCTJSNavigationScheme];
//}

//- (void)webView:(__unused UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//  if (_onLoadingError) {
//
//    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
//      // NSURLErrorCancelled is reported when a page has a redirect OR if you load
//      // a new URL in the WebView before the previous one came back. We can just
//      // ignore these since they aren't real errors.
//      // http://stackoverflow.com/questions/1024748/how-do-i-fix-nsurlerrordomain-error-999-in-iphone-3-0-os
//      return;
//    }
//
//    NSMutableDictionary *event = [self baseEvent];
//    [event addEntriesFromDictionary: @{
//      @"domain": error.domain,
//      @"code": @(error.code),
//      @"description": error.localizedDescription,
//    }];
//    _onLoadingError(event);
//  }
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//  if (_injectedJavaScript != nil) {
//    [webView stringByEvaluatingJavaScriptFromString:_injectedJavaScript];
//  }
//
//  // we only need the final 'finishLoad' call so only fire the event when we're actually done loading.
//  if (_onLoadingFinish && !webView.loading && ![webView.request.URL.absoluteString isEqualToString:@"about:blank"]) {
//    _onLoadingFinish([self baseEvent]);
//  }
//}

@end
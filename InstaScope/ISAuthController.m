//
//  ISAuthController.m
//  InstaScope
//
//  Created by Javier Porras Luraschi on 10/4/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

#include "ISAuthController.h"
#include "ISCommonActions.h"
#include "Flurry.h"

@implementation ISAuthController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadURL];
}

- (void) loadURL {
    NSString *authUrl = @"https://api.instagram.com/oauth/authorize/?client_id=";
    NSString *redirectUrl = @"http://www.instascopeapp.com";
    NSString *clientId = @"c0511d29e7444c1880abd68b4d55a809";
    
    NSString *fullUrl = [NSString stringWithFormat:@"%@%@&redirect_uri=%@&response_type=token", authUrl, clientId,redirectUrl];
    
    NSURL *url = [NSURL URLWithString:fullUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    _webView.delegate = self;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *redirectUrl = @"http://www.instascopeapp.com";
    
    NSString* urlString = [[request URL] absoluteString];

    NSArray *urlParts = [urlString componentsSeparatedByString:[NSString stringWithFormat:@"%@/", redirectUrl]];
    
    if ([urlParts count] > 1) {
        urlString = [urlParts objectAtIndex:1];
        NSRange accessTokenRange = [urlString rangeOfString: @"#access_token="];
        
        if (accessTokenRange.location != NSNotFound) {
            NSString* accessToken = [urlString substringFromIndex: NSMaxRange(accessTokenRange)];

            [Flurry logEvent:@"AuthGotToken"];
            [ISCommonActions updateAccessToken:accessToken];
            
            [[self navigationController] popViewControllerAnimated:YES];
        }
        return NO;
    }
    return YES;
}

@end
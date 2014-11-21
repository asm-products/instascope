//
//  ISAuthController.h
//  InstaScope
//
//  Created by Javier Porras Luraschi on 10/4/14.
//  Copyright (c) 2014 Javier Luraschi. All rights reserved.
//

@interface ISAuthController : UIViewController<UIWebViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void)loadURL;

@end
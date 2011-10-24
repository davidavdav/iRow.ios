//
//  InfoViewController.h
//  iSTI
//
//  Created by David van Leeuwen on 11-02-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController <UIWebViewDelegate> {
	UIWebView * webView;
}

@property (nonatomic,retain) UIWebView * webView;


@end

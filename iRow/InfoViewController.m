    //
//  InfoViewController.m
//  iSTI
//
//  Created by David van Leeuwen on 11-02-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "InfoViewController.h"
#import "Settings.h"

@implementation InfoViewController

@synthesize webView;

// OUR USE OF THIS REAL TIME ROUTE GUIDANCE APPLICATION IS AT YOUR SOLE RISK. LOCATION DATA MAY NOT BE ACCURATE.

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(id)init {
    self = [super init];
    if (self) {
        self.title = @"Info";
        self.tabBarItem.image = [UIImage imageNamed:@"UIButtonBarInfoDark"];
        
    }
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	CGRect frame = self.view.bounds;
    frame.size.height = frame.size.height - self.tabBarController.tabBar.bounds.size.height;
	webView = [[UIWebView alloc] initWithFrame:frame];
	webView.scalesPageToFit = NO;
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	NSURL * textURL = [[NSBundle mainBundle] URLForResource:@"info" withExtension:@"html"];
	NSError * error;
	NSString * text = [NSString stringWithContentsOfURL:textURL encoding:NSUTF8StringEncoding error:&error];
	[webView loadHTMLString:text baseURL:[[NSBundle mainBundle] bundleURL]];
//	NSLog(@"%@", [[NSBundle mainBundle] bundleURL]);
	[self.view addSubview:webView];
	webView.delegate = self;
    // check if a delegate is set, and if so, we're the main viewcontroller so add a back button
    // iSTI lite
}

#pragma mark UIWebViewDelegate

// this does not help us...
-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request vavigationType:(UIWebViewNavigationType)navigationType {
	self.webView.scalesPageToFit = YES;
	return YES;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end

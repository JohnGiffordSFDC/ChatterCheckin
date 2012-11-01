//
//  LoadingViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/31/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "LoadingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoadingViewController ()

@end

@implementation LoadingViewController

static LoadingViewController * _sharedLoadingViewController = nil;

+ (LoadingViewController *)sharedController
{
    @synchronized([LoadingViewController class])
	{
		if (!_sharedLoadingViewController)
			[[self alloc] initWithNibName:@"LoadingViewController" bundle:nil];
        
		return _sharedLoadingViewController;
	}
    
	return nil;
}

+ (id)alloc
{
	@synchronized([LoadingViewController class])
	{
		NSAssert(_sharedLoadingViewController == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedLoadingViewController = [super alloc];
		return _sharedLoadingViewController;
	}
    
	return nil;
}

- (void)addLoadingView:(UIView *)view
{
    [_loadingLabel setText:@"Loading..."];
    [view addSubview:self.view];
}

- (void)addLoadingView:(UIView *)view withLabel:(NSString *)label
{
    [_loadingLabel setText:label];
    [view addSubview:self.view];
}

- (void)removeLoadingView
{
    [self.view removeFromSuperview];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _loadingBox.layer.cornerRadius = 10.0;
    [_loadingIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_loadingBox release];
    [_loadingIndicator release];
    [_loadingLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLoadingBox:nil];
    [self setLoadingIndicator:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
}
@end

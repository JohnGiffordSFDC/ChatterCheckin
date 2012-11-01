//
//  LoadingViewController.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/31/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *loadingBox;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;

+ (LoadingViewController *)sharedController;

- (void)addLoadingView:(UIView *)view;
- (void)addLoadingView:(UIView *)view withLabel:(NSString *)label;
- (void)removeLoadingView;


@end

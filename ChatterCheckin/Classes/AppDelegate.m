/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
#import "MapViewController.h"
#import "FeedTableViewController.h"

/*
 NOTE if you ever need to update these, you can obtain them from your Salesforce org,
 (When you are logged in as an org administrator, go to Setup -> Develop -> Remote Access -> New )
 */


// Fill these in when creating a new Remote Access client on Force.com 
static NSString *const RemoteAccessConsumerKey = @"3MVG9yZ.WNe6byQD50ImMLE0VIUGtc3mIxwt9onVKT9vcJ3A84Xb1EDbZn.xXkq41QChhrO2wkc39.nbvQQQI";
static NSString *const OAuthRedirectURI = @"testsfdc:///mobilesdk/detect/oauth/done";


@implementation AppDelegate


#pragma mark - Remote Access / OAuth configuration


- (NSString*)remoteAccessConsumerKey {
    return RemoteAccessConsumerKey;
}

- (NSString*)oauthRedirectURI {
    return OAuthRedirectURI;
}



#pragma mark - App lifecycle


//NOTE be sure to call all super methods you override.

- (UIViewController*)newRootViewController {
    
    FeedTableViewController *fvc = [[FeedTableViewController alloc]initWithNibName:@"FeedTableViewController" bundle:nil];
    [fvc setTitle:@"Status Updates"];
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:fvc];
    [nav1 setTitle:@"My Chatter"];
    [nav1.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [nav1.tabBarItem setImage:[UIImage imageNamed:@"feed_icon.png"]];
    
    MapViewController *mvc = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    [mvc setTitle:@"Location"];
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:mvc];
    
    [mvc release];
    
    [nav2.tabBarItem setImage:[UIImage imageNamed:@"checkin.png"]];
    [nav2.tabBarItem setTitle:@"Checkin"];
    [nav2.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    UITabBarController *utb = [[UITabBarController alloc] init];
    [utb setViewControllers:[NSArray arrayWithObjects:nav2, nav1, nil]];
    
    [fvc release];
    [nav1 release];
    [nav2 release];
    
    return utb;
}


@end

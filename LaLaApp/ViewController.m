//
//  ViewController.m
//  LaLaApp
//
//  Created by Dejan Krstevski on 4/27/17.
//  Copyright © 2017 sp. All rights reserved.
//

#import "ViewController.h"
#import "FirstViewController.h"
#import "OpenIDConnectLibrary.h"
#import "LaLaAppCurrentSession.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)lalaLoginButtonAction:(id)sender
{
    [self actionSignInButton];
}

- (IBAction)actionSignInButton {
    
    //  - baseUrl / Issuer: The base URL for the authorization endpoint on the AS.  Will have /as/authorization.oauth2 appended.
    // {realm name} is your realm name from portal.acmelogin.com
    NSString *issuer = @"https://portal.acmelogin.com/auth/realms/{realm name}";
    [[LaLaAppCurrentSession session] setIssuer:issuer];
    
    //  - response_type: token and/or id_token (we have a really basic use-case, authentication only, no API security)
    //  - scope: openid profile email (space delimited)
    NSString *scope = @"openid profile email";
    
    // Your client id for this application in your realm from portal.acmelogin.com
    NSString *clientId = @"{client id}";
    [[LaLaAppCurrentSession session] setClientId:clientId];
    
    //  - redirect_uri: the endpoint to rturn the token - this is the app callback url com.pingidentity.OIDCSampleApp://oidc_callback
    // You need to add this callback url to your client's callback url list on portal.acmelogin.com
    NSString *redirectUri = @"com.lalaapp.djobjc://callback";
    
    OAuth2Client *basicProfile = [[OAuth2Client alloc] init];
    [basicProfile setBaseUrl:issuer];
    [basicProfile setAuthorizationEndpoint:@"/protocol/openid-connect/auth"];
    [basicProfile setOAuthRequestParameter:kOAuth2RequestParamClientId value:clientId];
    [basicProfile setOAuthRequestParameter:kOAuth2RequestParamRedirectUri value:redirectUri];
    [basicProfile setOAuthRequestParameter:kOAuth2RequestParamScope value:scope];
    [basicProfile setOAuthRequestParameter:kOAuth2RequestParamResponseType value:@"code"];
    
    [[LaLaAppCurrentSession session] setOIDCBasicProfile:basicProfile];
    
    // Step 1 - Build the token url we need to redirect the user to
    NSString *authorizationUrl = [basicProfile buildAuthorizationRedirectUrl];
    NSLog(@"Calling authorization url: %@", authorizationUrl);
    
    // Step 2 - Redirect the user, the user will return in the AppDelegate.m file
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authorizationUrl] options:@{} completionHandler:^(BOOL success) {
        NSLog(@"++success: %d",success);
    }];
    CFRunLoopRun();
    
    // We have returned from Safari and should have an authenticated user object
    if([[LaLaAppCurrentSession session] inErrorState])
    {
        // Error - handle it
        NSString *errorText = [[[[LaLaAppCurrentSession session] getLastError] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        NSLog(@"An error occurred: %@", errorText);
//        [self.outletMessages setText:errorText];
//        [self.outletMessages setTextColor:[UIColor redColor]];
    }else{
        // Then we call the UserInfo endpoint to get the attributes
        [[LaLaAppCurrentSession session] createSessionFromIDToken:YES];
        NSLog(@"Session created");
    }
    
//    [self.view setNeedsDisplay];
//    [self configureView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

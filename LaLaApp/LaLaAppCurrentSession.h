//
//  LaLaAppCurrentSession.h
//  LaLaApp
//
//  Created by Dejan Krstevski on 4/27/17.
//  Copyright © 2017 sp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuth2Client.h"

@interface LaLaAppCurrentSession : NSObject <NSCoding>
{
    NSString *issuer;
    NSString *client_id;
    NSString *nonce;
    
    NSDictionary *_allAttributes;
}

@property (strong, nonatomic) OAuth2Client *OIDCBasicProfile;

+(LaLaAppCurrentSession *)session;
-(void)logout;
-(NSArray *)getAllAttributes;
-(NSString *)getValueForAttribute:(NSString *)attribute;
-(BOOL)isAuthenticated;
-(BOOL)inErrorState;
-(void)createSessionFromIDToken:(BOOL)retrieveAttributesFromUserInfo;
-(NSString *)getLastError;
-(void)setIssuer:(NSString *)newIssuer;
-(void)setClientId:(NSString *)newClientId;

@end

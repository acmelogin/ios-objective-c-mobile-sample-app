//
//  LaLaAppCurrentSession.m
//  LaLaApp
//
//  Created by Dejan Krstevski on 4/27/17.
//  Copyright © 2017 sp. All rights reserved.
//

#import "LaLaAppCurrentSession.h"
#import "OpenIDConnectLibrary.h"
#import "UserInfoEndpoint.h"

@implementation LaLaAppCurrentSession

+(LaLaAppCurrentSession *)session
{
    static LaLaAppCurrentSession *sess;
    
    if(sess == nil)
    {
        sess = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"myLalaSession"]];
        if (sess == nil) {
            sess = [[LaLaAppCurrentSession alloc] init];
        }
    }
    
    return sess;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

-(NSArray *)getAllAttributes
{
    return [_allAttributes allKeys];
}

-(NSString *)getValueForAttribute:(NSString *)attribute
{
    return [_allAttributes valueForKey:attribute];
}

-(void)createSessionFromIDToken:(BOOL)retrieveAttributesFromUserInfo
{
    if(![self inErrorState])
    {
        NSString *id_token = [_OIDCBasicProfile getOAuthResponseValueForParameter:kOAuth2ResponseParamIdToken];
        if (id_token != nil) {
            
            NSDictionary *idTokenAttributes = [OpenIDConnectLibrary parseIDToken:id_token forClient:_OIDCBasicProfile];
            
            if (retrieveAttributesFromUserInfo) {
                
                UserInfoEndpoint *userInfoEndpoint = [[UserInfoEndpoint alloc] initWithIssuer:issuer andAccessToken:[_OIDCBasicProfile getOAuthResponseValueForParameter:kOAuth2ResponseParamAccessToken]];
                
                
                NSMutableDictionary *userinfoAttributes = [[NSMutableDictionary alloc] initWithDictionary:[userInfoEndpoint getClaims]];
                
                if([[userinfoAttributes objectForKey:@"sub"] isEqualToString:[idTokenAttributes objectForKey:@"sub"]]) {
                    // sub of the id_token MUST match sub of the userinfo endpoint
                    [userinfoAttributes removeObjectForKey:@"sub"];
                    [userinfoAttributes addEntriesFromDictionary:idTokenAttributes];
                    _allAttributes = userinfoAttributes;
                } else {
                    NSLog(@"Subject of the userinfo endpoint doesn't match authenticated user!");
                    NSLog(@"%@ != %@", [userinfoAttributes objectForKey:@"sub"], [idTokenAttributes objectForKey:@"sub"]);
                }
                
            }
            NSLog(@"Created Session: %@", _allAttributes);
        } else {
            NSLog(@"No ID token!");
        }
    }
}

-(BOOL)isAuthenticated
{
    if (_allAttributes != nil) {
        if([_allAttributes count] > 0) {
            return YES;
        }
        else {
            return NO;
        }
    } else {
        return NO;
    }
}

-(void)logout
{
    _allAttributes = nil;
    [_OIDCBasicProfile callEndSessionEndpoint];
}

-(BOOL)inErrorState
{
    if([_OIDCBasicProfile getOAuthResponseValueForParameter:kOAuth2ResponseParamError] != nil)
    {
        return YES;
    }
    
    return NO;
}

-(NSString *)getLastError
{
    if ([self inErrorState]) {
        return [_OIDCBasicProfile getOAuthResponseValueForParameter:kOAuth2ResponseParamErrorDescription];
    } else {
        return @"";
    }
}

-(void)setIssuer:(NSString *)newIssuer {
    
    issuer = newIssuer;
}

-(void)setClientId:(NSString *)newClientId {
    
    client_id = newClientId;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        issuer = [aDecoder decodeObjectForKey:@"issuer"];
        client_id = [aDecoder decodeObjectForKey:@"client_id"];
        nonce = [aDecoder decodeObjectForKey:@"nonce"];
        _allAttributes = [aDecoder decodeObjectForKey:@"_allAttributes"];
        _OIDCBasicProfile = [aDecoder decodeObjectForKey:@"_OIDCBasicProfile"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:issuer forKey:@"issuer"];
    [aCoder encodeObject:client_id forKey:@"client_id"];
    [aCoder encodeObject:nonce forKey:@"nonce"];
    [aCoder encodeObject:_allAttributes forKey:@"_allAttributes"];
    [aCoder encodeObject:_OIDCBasicProfile forKey:@"_OIDCBasicProfile"];
}


@end

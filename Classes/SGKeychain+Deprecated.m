//
//  SGKeychain+Deprecated.m
//  Pods
//
//  Created by Justin Williams on 6/20/14.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@import Foundation;
#import "SGKeychain.h"
#import "SGKeychainItem.h"

@implementation SGKeychain (Deprecated)

+ (BOOL)setPassword:(NSString *)password username:(NSString *)username serviceName:(NSString *)serviceName updateExisting:(BOOL)updateExisting error:(NSError **)error

{
    return [SGKeychain setPassword:password username:username serviceName:serviceName accessGroup:nil updateExisting:updateExisting error:error];
}

+ (BOOL)setPassword:(NSString *)password username:(NSString *)username serviceName:(NSString *)serviceName accessGroup:(NSString *)accessGroup updateExisting:(BOOL)updateExisting error:(NSError **)error
{
    BOOL requiredValueIsNil = ((password == nil) || (username == nil) || (serviceName == nil));
    if (requiredValueIsNil == YES)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:SGKeychainErrorDomain code:SGKeychainRequiredValueNotPresentError userInfo:nil];
        }
        return NO;
    }
    
    NSError *getPasswordError = nil;
    NSString *existingPassword = [SGKeychain passwordForUsername:username serviceName:serviceName accessGroup:accessGroup error:&getPasswordError];
    
    if ([getPasswordError code] == SGKeychainPasswordNotFoundError)
    {
        NSError *deletePasswordError;
        [self deletePasswordForUsername:username serviceName:serviceName accessGroup:accessGroup error:&deletePasswordError];
        if ([deletePasswordError code] != noErr)
        {
            if (error != nil)
            {
                *error = deletePasswordError;
            }
            
            return NO;
        }
        else if ([deletePasswordError code] != noErr)
        {
            if (error != nil)
            {
                *error = deletePasswordError;
            }
            return NO;
        }
    }
    
    OSStatus setPasswordStatus = noErr;
    if (existingPassword != nil)
    {
        if (([existingPassword isEqualToString:password] == NO) && (updateExisting == YES))
        {
            
            NSDictionary *attributes = @{
                                         (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                         (__bridge id)kSecAttrService : serviceName,
                                         (__bridge id)kSecAttrLabel : serviceName,
                                         (__bridge id)kSecAttrAccount : username
                                         };
            
            NSMutableDictionary *attributesQuery = [attributes mutableCopy];
#if !TARGET_IPHONE_SIMULATOR
            if (accessGroup != nil)
            {
                [attributesQuery setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
            }
#endif
            
            NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *newValueDictionary = [NSDictionary dictionaryWithObject:passwordData forKey:(__bridge NSString *) kSecValueData];
            setPasswordStatus = SecItemUpdate((__bridge CFDictionaryRef)attributesQuery, (__bridge CFDictionaryRef)newValueDictionary);
        }
    }
    else
    {
        
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *attributes = @{
                                     (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                     (__bridge id)kSecAttrService : serviceName,
                                     (__bridge id)kSecAttrLabel : serviceName,
                                     (__bridge id)kSecAttrAccount : username,
                                     (__bridge id)kSecValueData : passwordData
                                     };
        
        
        NSMutableDictionary *query = [attributes mutableCopy];
#if !TARGET_IPHONE_SIMULATOR
        if (accessGroup != nil)
        {
            [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
#endif
        
        setPasswordStatus = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
    
    if (setPasswordStatus != noErr)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:SGKeychainErrorDomain code:setPasswordStatus userInfo:nil];
        }
        return NO;
    }
    
    return YES;
}

+ (BOOL)deletePasswordForUsername:(NSString *)username serviceName:(NSString *)serviceName error:(NSError **)error
{
    return [SGKeychain deletePasswordForUsername:username serviceName:serviceName accessGroup:nil error:error];
}

+ (BOOL)deletePasswordForUsername:(NSString *)username serviceName:(NSString *)serviceName accessGroup:(NSString *)accessGroup error:(NSError **)error
{
    BOOL requiredValueIsNil = ((username == nil) || (serviceName == nil));
    if (requiredValueIsNil == YES)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:SGKeychainErrorDomain code:SGKeychainRequiredValueNotPresentError userInfo:nil];
            return NO;
        }
    }
    
    NSArray *keys = [NSArray arrayWithObjects:(__bridge NSString *)kSecClass,
                     kSecAttrService,
                     kSecAttrAccount,
                     kSecReturnAttributes, nil];
    
    NSArray *objects = [NSArray arrayWithObjects:(__bridge NSString *) kSecClassGenericPassword,
                        serviceName,
                        username,
                        kCFBooleanTrue, nil];
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup != nil)
    {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
    
    OSStatus deleteItemStatus = SecItemDelete((__bridge CFDictionaryRef) query);
    
    if ((error != nil) && (deleteItemStatus != noErr))
    {
        *error = [NSError errorWithDomain:SGKeychainErrorDomain code:deleteItemStatus userInfo:nil];
        return NO;
    }
    
    return YES;
}

@end
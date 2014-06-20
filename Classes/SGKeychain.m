//
//  SGKeychain.m
//  SGKeychain
//
//  Created by Justin Williams on 4/6/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
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

#import "SGKeychain.h"
#import "SGKeychainItem.h"

@implementation SGKeychain

#pragma mark -
#pragma mark Store Keychain Item
// +--------------------------------------------------------------------
// | Store Keychain Item
// +--------------------------------------------------------------------

+ (void)storeKeychainItem:(SGKeychainItem *)item completionHandler:(SGKeychainCompletionBlock)handler
{
    if ([item isValid] == NO)
    {
        if (handler != nil)
        {
            handler([self missingDataError]);
        }
        
        return;
    }
    
    NSError *persistError = nil;
    [item saveChanges:&persistError];
    
    if (handler != nil)
    {
        handler(persistError);
    }
}

#pragma mark -
#pragma mark Read Keychain Items
// +--------------------------------------------------------------------
// | Read Keychain Items
// +--------------------------------------------------------------------

+ (void)populatePasswordForItem:(SGKeychainItem *)item completionHandler:(SGKeychainCompletionBlock)handler
{
    NSError *populateError = nil;
    [item populatePasswordField:&populateError];
    
    if (handler != nil)
    {
        handler(populateError);
    }
}


#pragma mark -
#pragma mark Delete Keychain Items
// +--------------------------------------------------------------------
// | Delete Keychain Items
// +--------------------------------------------------------------------

+ (void)deleteKeychainItem:(SGKeychainItem *)item completionHandler:(SGKeychainCompletionBlock)handler
{
    if ([item isValid] == NO)
    {
        if (handler != nil)
        {
            handler([self missingDataError]);
        }
        
        return;
    }

    NSError *deleteError = nil;
    [item removeFromKeychain:&deleteError];
    
    if (handler != nil)
    {
        handler(deleteError);
    }    
}

#pragma mark -
#pragma mark Private/Convenience Methods
// +--------------------------------------------------------------------
// | Private/Convenience Methods
// +--------------------------------------------------------------------

+ (NSString *)passwordForUsername:(NSString *)username serviceName:(NSString *)serviceName error:(NSError **)error
{
    return [SGKeychain passwordForUsername:username serviceName:serviceName accessGroup:nil error:error];
}

+ (NSString *)passwordForUsername:(NSString *)username serviceName:(NSString *)serviceName accessGroup:(NSString *)accessGroup error:(NSError **)error
{
    BOOL requiredValueIsNil = ((username == nil) || (serviceName == nil));
    if (requiredValueIsNil == YES)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:SGKeychainErrorDomain code:SGKeychainRequiredValueNotPresentError userInfo:nil];
        }
        return nil;
    }

    NSError *populateError = nil;
    SGKeychainItem *item = [[SGKeychainItem alloc] init];
    item.account = username;
    item.service = serviceName;
    if ([item populatePasswordField:&populateError] == NO)
    {
        //*error = [populateError copy];
        return nil;
    }
    
    return item.secret;
}

+ (NSError *)missingDataError
{
    return [NSError errorWithDomain:SGKeychainErrorDomain code:SGKeychainRequiredValueNotPresentError userInfo:nil];
}

@end

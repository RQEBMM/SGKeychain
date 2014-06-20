//
//  SGKeychainItem.m
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

#import "SGKeychainItem.h"

NSString * const SGKeychainErrorDomain = @"com.secondgear.sgkeychain";

@implementation SGKeychainItem

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (BOOL)isValid
{
    return ((self.service != nil) && (self.account != nil));
}

- (NSDictionary *)keychainAttributes
{
    if ([self isValid] == NO)
    {
        return @{ };
    }
    
    NSDictionary *attributes = @{
                                 (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                 (__bridge id)kSecAttrService : self.service,
                                 (__bridge id)kSecAttrLabel : self.service,
                                 (__bridge id)kSecAttrAccount : self.account,
                                 (__bridge id)kSecAttrAccessible : (__bridge id)[self accessibilityAttribute]
                                 };
    
    NSMutableDictionary *keychainAttributes = [attributes mutableCopy];
#if !TARGET_IPHONE_SIMULATOR
    if (self.accessGroup != nil)
    {
        [keychainAttributes setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif

    return keychainAttributes;
}

- (void)saveChangesInBackground
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self saveChanges:nil];
    });
}

- (BOOL)saveChanges:(NSError **)error
{
    BOOL saveStatus = NO;
    NSData *secretData = [self.secret dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *changes = @{
                              (__bridge NSString *) kSecValueData : secretData
                              };
    
    
    if ([self isPersistedToKeychain])
    {
        OSStatus updateItemStatus = SecItemUpdate((__bridge CFDictionaryRef)[self keychainAttributes], (__bridge CFDictionaryRef)changes);
        if ((updateItemStatus != noErr) && (error != nil))
        {
            *error = [self handleErrorForStatus:updateItemStatus];
        }
        else
        {
            saveStatus = YES;
        }
    }
    else
    {
        NSMutableDictionary *attributes = [[self keychainAttributes] mutableCopy];
        [attributes addEntriesFromDictionary:changes];
        OSStatus setItemStatus = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        if ((setItemStatus != noErr) && (error != nil))
        {
            *error = [self handleErrorForStatus:setItemStatus];
        }
        else
        {
            saveStatus = YES;
        }
    }
    
    return saveStatus;
}

- (void)populatePasswordFieldInBackground
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self populatePasswordField:nil];
    });

}

- (BOOL)populatePasswordField:(NSError **)error
{
    if ([self isPersistedToKeychain] == NO && (error != nil))
    {
        *error = [self handleErrorForStatus:errSecItemNotFound];
        return NO;
    }
    
    BOOL populateStatus = NO;

    NSMutableDictionary *passwordQuery = [[self keychainAttributes] mutableCopy];
    passwordQuery[(__bridge id)kSecReturnData] = (id)kCFBooleanTrue;
    CFTypeRef passwordResult = NULL;
    OSStatus getPasswordStatus = SecItemCopyMatching((__bridge CFDictionaryRef)passwordQuery, &passwordResult);
    
    if ((getPasswordStatus != noErr) && (error != nil))
    {
        *error = [self handleErrorForStatus:getPasswordStatus];
    }
    else
    {
        NSData *resultData = (__bridge_transfer NSData *)passwordResult;
        NSString *password = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        self.secret = password;
        populateStatus = YES;
    }
    
    return populateStatus;
}

- (void)removeFromKeychainInBackground
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self removeFromKeychain:nil];
    });
}

- (BOOL)removeFromKeychain:(NSError **)error
{
    if ([self isPersistedToKeychain] == NO && (error != nil))
    {
        *error = [self handleErrorForStatus:errSecItemNotFound];
        return YES;
    }
    
    BOOL saveStatus = NO;
    
    OSStatus deleteItemStatus = SecItemDelete((__bridge CFDictionaryRef) [self keychainAttributes]);
    if ((error != nil) && (deleteItemStatus != noErr))
    {
        *error = [self handleErrorForStatus:deleteItemStatus];
    }
    else
    {
        saveStatus = YES;
    }
    
    return saveStatus;
    
}

- (BOOL)isPersistedToKeychain
{
    BOOL persistedStatus = NO;
    
    NSMutableDictionary *attributes = [[self keychainAttributes] mutableCopy];
    attributes[(__bridge id)kSecReturnAttributes] = (id)kCFBooleanTrue;
    
    CFTypeRef result = NULL;
    OSStatus getPasswordStatus = SecItemCopyMatching((__bridge CFDictionaryRef)attributes, &result);
    
    if (getPasswordStatus == noErr)
    {
        persistedStatus = YES;
    }
    
    if (result)
    {
        CFRelease(result);
    }

    return persistedStatus;
}

#pragma mark -
#pragma mark Private/Convenience Methods
// +--------------------------------------------------------------------
// | Private/Convenience Methods
// +--------------------------------------------------------------------

- (CFTypeRef)accessibilityAttribute
{
    CFTypeRef typeRef = NULL;
    switch (self.accessibility)
    {
        case SGKeychainAccessibilityAfterFirstUnlock:
            typeRef = kSecAttrAccessibleAfterFirstUnlock;
            break;
            
        case SGKeychainAccessibilityAlways:
            typeRef = kSecAttrAccessibleAlways;
            break;
            
#if defined(__IPHONE_8_0)
        case SGKeychainAccessibilityPasscodeSetThisDeviceOnly:
        {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
            {
                typeRef = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
                break;
            }
        }
#endif
            
        case SGKeychainAccessibilityWhenUnlockedThisDeviceOnly:
            typeRef = kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
            break;
            
        case SGKeychainAccessibilityAfterFirstUnlockThisDeviceOnly:
            typeRef = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            break;

        case SGKeychainAccessibilityAlwaysThisDeviceOnly:
            typeRef = kSecAttrAccessibleAlwaysThisDeviceOnly;
            break;

        case SGKeychainAccessibilityWhenUnlocked:
        default:
            typeRef = kSecAttrAccessibleWhenUnlocked;
            break;
    }
    
    return typeRef;
}

- (NSString *)keychainErrorToString:(NSInteger)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"%ld",(long)error];
    
    switch (error)
    {
        case errSecSuccess:
            errorMessage = NSLocalizedString(@"SUCCESS", nil);
            break;
        case errSecDuplicateItem:
            errorMessage = NSLocalizedString(@"ERROR_ITEM_ALREADY_EXISTS", nil);
            break;
        case errSecItemNotFound:
            errorMessage = NSLocalizedString(@"ERROR_ITEM_NOT_FOUND", nil);
            break;
        case -26276: // this error will be replaced by errSecAuthFailed
            errorMessage = NSLocalizedString(@"ERROR_ITEM_AUTHENTICATION_FAILED", nil);
        default:
            break;
    }
    
    return errorMessage;
}


- (NSError *)handleErrorForStatus:(OSStatus)status
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : NSLocalizedString(@"Updating keychain item failed.", @""),
                               NSLocalizedFailureReasonErrorKey : [self keychainErrorToString:status],
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try deleting any existing item that may have the same attributes.", nil)
                               };

    return [NSError errorWithDomain:SGKeychainErrorDomain code:status userInfo:userInfo];

}

@end

//
//  SGKeychainItem.h
//  SGKeychain
//
//  Created by Justin Williams on 6/20/14.
//
//

@import Foundation;

typedef NS_ENUM(NSInteger, SGKeychainErrorCode)
{
    SGKeychainNoError = 0,
    SGKeychainRequiredValueNotPresentError = -666,
    SGKeychainPasswordNotFoundError = -777,
};

extern NSString * const SGKeychainErrorDomain;

typedef NS_ENUM(NSUInteger, SGKeychainAccessibility)
{
    // DEFAULT. Item data can only be accessed while the device is unlocked.
    SGKeychainAccessibilityWhenUnlocked,
    
    // Item data can only be accessed once the device has been unlocked after a restart.
    SGKeychainAccessibilityAfterFirstUnlock,
    
    // Item data can always be accessed regardless of the lock state of the device
    SGKeychainAccessibilityAlways,
    
#if defined(__IPHONE_8_0)
    // Item data can only be accessed while the device is unlocked.
    // Only available if a passcode is set on the device.
    //
    // iOS 8+ Only
    //
    // Will default to SGKeychainAccessibilityWhenUnlocked otherwise.
    SGKeychainAccessibilityPasscodeSetThisDeviceOnly,
#endif
    
    // Item data can only be accessed while the device is unlocked.
    SGKeychainAccessibilityWhenUnlockedThisDeviceOnly,
    
    // Item data can only be accessed once the device has been unlocked after a restart
    SGKeychainAccessibilityAfterFirstUnlockThisDeviceOnly,
    
    // Item data can always be accessed regardless of the lock state of the device
    SGKeychainAccessibilityAlwaysThisDeviceOnly
};


// jww: 06/20/14
// SGKeychainItems currently default to kSecClass of kSecClassGenericPassword
// Patches welcomed if you need something else. :)
@interface SGKeychainItem : NSObject

@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *accessGroup;
@property (nonatomic, copy) NSString *secret;

@property (nonatomic, assign) SGKeychainAccessibility accessibility;

- (BOOL)isValid;

- (NSDictionary *)keychainAttributes;

- (void)saveChangesInBackground;
- (BOOL)saveChanges:(NSError **)error;

- (void)populatePasswordFieldInBackground;
- (BOOL)populatePasswordField:(NSError **)error;

- (void)removeFromKeychainInBackground;
- (BOOL)removeFromKeychain:(NSError **)error;

- (BOOL)isPersistedToKeychain;

@end

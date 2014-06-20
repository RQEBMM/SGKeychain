//
//  SGKeychainExampleTests.m
//  SGKeychainExampleTests
//
//  Created by Justin Williams on 4/6/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
//


@import XCTest;

#import <SGKeychain/SGKeychain.h>

@interface SGKeychainExampleTests : XCTestCase

@property (nonatomic, strong) SGKeychainItem *defaultItem;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *expectedPassword;

@end

@implementation SGKeychainExampleTests

// Thanks to David H
// http://stackoverflow.com/questions/11726672/access-app-identifier-prefix-programmatically
- (NSString *)bundleSeedID {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)kSecClassGenericPassword, kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge id)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    return bundleSeedID;
}

- (void)setUp
{
    [super setUp];
    self.username = @"justin";
    self.service = @"com.secondgear.testapp";
    self.expectedPassword = @"testpassword";
    
    self.defaultItem = [[SGKeychainItem alloc] init];
    self.defaultItem.account = self.username;
    self.defaultItem.accessibility = SGKeychainAccessibilityAfterFirstUnlock;
    self.defaultItem.service = self.service;
}

- (void)tearDown
{
    [super tearDown];
    
    // Delete the keychain password before each test.
    [self deleteAllKeysForSecClass:kSecClassGenericPassword];
    [self deleteAllKeysForSecClass:kSecClassInternetPassword];
    [self deleteAllKeysForSecClass:kSecClassCertificate];
    [self deleteAllKeysForSecClass:kSecClassKey];
    [self deleteAllKeysForSecClass:kSecClassIdentity];
    
    self.username = nil;
    self.service = nil;
    self.expectedPassword = nil;
    self.defaultItem = nil;
}

- (void)testPasswordIsSuccessfullyCreated
{
    // Arrange
    __block NSError *savedError = nil;
    self.defaultItem.secret = @"testpassword";
    
    // Act
    [SGKeychain storeKeychainItem:self.defaultItem completionHandler:^(NSError *error) {
        savedError = error;
    }];
    
    // Analyze
    XCTAssertNil(savedError);
}

- (void)testErrorReturnedWhenPassingNilValuesOnCreate
{
    // Arrange
    __block NSError *saveError = nil;
    self.defaultItem.secret = nil;
    self.defaultItem.account = nil;
    
    // Act
    [SGKeychain storeKeychainItem:self.defaultItem completionHandler:^(NSError *error) {
        saveError = error;
    }];

    // Analyze
    XCTAssertNotNil(saveError);
    XCTAssertTrue([saveError code] == -666);
}

- (void)testExistingPasswordRecordSuccessfullyUpdated
{
    // Arrange
    __block NSError *saveError = nil;
    NSString *oldPassword = @"oldpassword";
    NSString *newPassword = @"newpassword";
    self.defaultItem.secret = oldPassword;
    [SGKeychain storeKeychainItem:self.defaultItem completionHandler:nil];
    
    // Act
    self.defaultItem.secret = newPassword;
    [SGKeychain storeKeychainItem:self.defaultItem completionHandler:^(NSError *error) {
        saveError = error;
    }];
    
    // Analyze
    XCTAssertNil(saveError);
    
    NSString *password = [SGKeychain passwordForUsername:self.username serviceName:self.service error:nil];    
    XCTAssertEqualObjects(password, newPassword);
}

- (void)testPasswordIsSuccessfullyFetched
{
    // Arrange
    NSString *testpassword = @"testpassword";
    self.defaultItem.secret = testpassword;
    [SGKeychain storeKeychainItem:self.defaultItem completionHandler:nil];
    
    
    // Act
    NSString *password = [SGKeychain passwordForUsername:self.username serviceName:self.service error:nil];
    
    // Analyze
    XCTAssertEqualObjects(password, self.expectedPassword, @"Expected password not fetched from keychain.");
}

- (void)testPasswordsAreSuccessfullyFetchedFromSameAccessGroup
{
    // Arrange
    NSString *accessGroup = [[self bundleSeedID] stringByAppendingString:@".shared"];

    // Add a password for justin and justinw to the access group
    NSString *firstpassword = @"firstpassword";
    SGKeychainItem *firstItem = [[SGKeychainItem alloc] init];
    firstItem.secret = firstpassword;
    firstItem.account = self.username;
    firstItem.service = self.service;
    firstItem.accessGroup = accessGroup;
    [SGKeychain storeKeychainItem:firstItem completionHandler:nil];
    
    NSString *secondpassword = @"secondpassword";
    NSString *secondUsername = @"justinw";
    SGKeychainItem *secondItem = [[SGKeychainItem alloc] init];
    secondItem.secret = secondpassword;
    secondItem.account = secondUsername;
    secondItem.service = self.service;
    secondItem.accessGroup = accessGroup;
    [SGKeychain storeKeychainItem:secondItem completionHandler:nil];

    // Act
    NSString *password1 = [SGKeychain passwordForUsername:self.username serviceName:self.service accessGroup:accessGroup error:nil];
    NSString *password2 = [SGKeychain passwordForUsername:@"justinw" serviceName:self.service accessGroup:accessGroup error:nil];
    
    // Analyze
    XCTAssertEqualObjects(password1, firstpassword);
    XCTAssertEqualObjects(password2, secondpassword);
    
    // Delete the passwords
    [firstItem removeFromKeychainInBackground];
    [secondItem removeFromKeychainInBackground];
}

- (void)testErrorReturnedWhenPassingNilValuesOnFetch
{
    NSError *error = nil;
    NSString *password = [SGKeychain passwordForUsername:nil serviceName:self.service error:&error];
    XCTAssertNil(password, @"didn't expect to get a password back");    
    
    XCTAssertTrue([error code] == -666, @"Error code received not as expected");
}


- (void)testPasswordIsSuccessfullyDeleted
{
    // Arrange
    NSString *testpassword = @"testpassword";
    self.defaultItem.secret = testpassword;
    [SGKeychain storeKeychainItem:self.defaultItem completionHandler:nil];

    // Act
    __block NSError *deleteError = nil;
    [SGKeychain deleteKeychainItem:self.defaultItem completionHandler:^(NSError *error) {
        deleteError = error;
    }];
    
    // Analyze
    XCTAssertNil(deleteError);
}

- (void)testErrorReturnedWhenPassingNilValuesOnDelete
{
    // Arrange
    self.defaultItem.account = nil;
    
    // Act
    __block NSError *deleteError = nil;
    [SGKeychain deleteKeychainItem:self.defaultItem completionHandler:^(NSError *error) {
        deleteError = error;
    }];
    
    // Analyze
    XCTAssertNotNil(deleteError);
    XCTAssertTrue([deleteError code] == -666, @"Error code received not as expected");
}

- (void)deleteAllKeysForSecClass:(CFTypeRef)secClass
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:(__bridge id)secClass forKey:(__bridge id)kSecClass];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSAssert(result == noErr || result == errSecItemNotFound, @"Error deleting keychain data (%ld)", result);
}

@end

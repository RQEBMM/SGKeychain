//
//  SGKeychainExampleTests.h
//  SGKeychainExampleTests
//
//  Created by Justin Williams on 4/6/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
//

@import XCTest;

@interface SGKeychainExampleTests : XCTestCase

- (void)testPasswordIsSuccessfullyCreated;
- (void)testErrorReturnedWhenPassingNilValuesOnCreate;
- (void)testExistingPasswordRecordSuccessfullyUpdated;
- (void)testPasswordIsSuccessfullyFetched;
- (void)testPasswordsAreSuccessfullyFetchedFromSameAccessGroup;
- (void)testErrorReturnedWhenPassingNilValuesOnFetch;
- (void)testPasswordIsSuccessfullyDeleted;
- (void)testErrorReturnedWhenPassingNilValuesOnDelete;

@end

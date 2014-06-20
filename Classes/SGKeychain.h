//
//  SGKeychain.h
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

@import Foundation;
@import Security;

#import <SGKeychain/SGKeychainItem.h>

typedef void (^SGKeychainCompletionBlock)(NSError *error);

@interface SGKeychain : NSObject

+ (void)storeKeychainItem:(SGKeychainItem *)item completionHandler:(SGKeychainCompletionBlock)handler;

+ (void)populatePasswordForItem:(SGKeychainItem *)item completionHandler:(SGKeychainCompletionBlock)handler;

+ (void)deleteKeychainItem:(SGKeychainItem *)item completionHandler:(SGKeychainCompletionBlock)handler;

+ (NSString *)passwordForUsername:(NSString *)username
                      serviceName:(NSString *)serviceName
                            error:(NSError **)error;

+ (NSString *)passwordForUsername:(NSString *)username
                      serviceName:(NSString *)serviceName
                      accessGroup:(NSString *)accessGroup
                            error:(NSError **)error;
@end

@interface SGKeychain (Deprecated)

+ (BOOL)setPassword:(NSString *)password
           username:(NSString *)username
        serviceName:(NSString *)serviceName
     updateExisting:(BOOL)updateExisting
              error:(NSError **)error __attribute__ ((deprecated));
    
+ (BOOL)setPassword:(NSString *)password
           username:(NSString *)username
        serviceName:(NSString *)serviceName
        accessGroup:(NSString *)accessGroup
     updateExisting:(BOOL)updateExisting
              error:(NSError **)error __attribute__ ((deprecated));

// Delete
+ (BOOL)deletePasswordForUsername:(NSString *)username
                      serviceName:(NSString *)serviceName
                            error:(NSError **)error __attribute__ ((deprecated));

+ (BOOL)deletePasswordForUsername:(NSString *)username
                      serviceName:(NSString *)serviceName
                      accessGroup:(NSString *)accessGroup
                            error:(NSError **)error __attribute__ ((deprecated));

@end

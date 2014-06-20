//
//  SGAppDelegate.m
//  SGKeychainExample
//
//  Created by Justin Williams on 4/6/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
//

#import <SGKeychain/SGKeychain.h>
#import "SGAppDelegate.h"

@implementation SGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Store a password
    NSError *storePasswordError = nil;
    
    SGKeychainItem *item = [[SGKeychainItem alloc] init];
    item.account = @"justin";
    item.service = @"Glassboard";
    item.secret = @"testpassword";
    
    [SGKeychain storeKeychainItem:item completionHandler:^(NSError *error) {
        if (error == nil)
        {
            NSLog(@"Password successfully created");
        }
        else
        {
            NSLog(@"Password failed to be created with error: %@", storePasswordError);
        }    

    }];
    
    // Fetch the password
    item.secret = nil;
    [SGKeychain populatePasswordForItem:item completionHandler:^(NSError *error) {
        if (error == nil)
        {
            NSLog(@"Fetched password = %@", item.secret);
        }
        else
        {
            NSLog(@"Error fetching password = %@", error);
        }
        
    }];
    
    // Delete the password
    NSError *deletePasswordError = nil;
    [SGKeychain deleteKeychainItem:item completionHandler:^(NSError *error) {
        if (error == nil)
        {
            NSLog(@"Password successfully deleted");
        }
        else
        {
            NSLog(@"Failed to delete password: %@", deletePasswordError);
        }
    }];

    return YES;
}


@end

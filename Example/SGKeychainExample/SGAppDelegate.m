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
    BOOL passwordSuccessfullyCreated = [SGKeychain setPassword:@"testpassword" username:@"justin" serviceName:@"Twitter" updateExisting:NO error:&storePasswordError];
    
    if (passwordSuccessfullyCreated == YES)
    {
        NSLog(@"Password successfully created");
    }
    else
    {
        NSLog(@"Password failed to be created with error: %@", storePasswordError);
    }    
    
    // Fetch the password
    NSError *fetchPasswordError = nil;
    NSString *password = [SGKeychain passwordForUsername:@"justin" serviceName:@"Twitter" error:&fetchPasswordError];
    
    if (password != nil)
    {
        NSLog(@"Fetched password = %@", password);    
    }
    else
    {
        NSLog(@"Error fetching password = %@", fetchPasswordError);
    }    
    
    // Delete the password
    NSError *deletePasswordError = nil;
    BOOL passwordSuccessfullyDeleted = [SGKeychain deletePasswordForUsername:@"justin" serviceName:@"Twitter" error:&deletePasswordError];
    if (passwordSuccessfullyDeleted == YES)
    {
        NSLog(@"Password successfully deleted");
    }
    else
    {
        NSLog(@"Failed to delete password: %@", deletePasswordError);
    }
    return YES;
}


@end

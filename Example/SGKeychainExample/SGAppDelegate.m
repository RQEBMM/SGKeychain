//
//  SGAppDelegate.m
//  SGKeychainExample
//
//  Created by Justin Williams on 4/6/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
//

#import "SGAppDelegate.h"
#import "SGKeychain.h"

@implementation SGAppDelegate

@synthesize window = _window;

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
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

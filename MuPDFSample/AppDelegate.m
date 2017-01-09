//
//  AppDelegate.m
//  MuPDFSample
//
//  Created by Calios on 09/01/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#include "common.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    BOOL _isInBackground;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    queue = dispatch_queue_create("com.calios.mupdfsample.queue", NULL);
    screenScale = [UIScreen mainScreen].scale;
    ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
    fz_register_document_handlers(ctx);
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    NSString *filename = [[NSUserDefaults standardUserDefaults] objectForKey:@"OpenDocumentKey"];
    if (filename) {
        [vc openDocument:filename];
    }
    filename = launchOptions[UIApplicationLaunchOptionsURLKey];
    NSLog(@"urlkey = %@\n",filename);
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground \n");
    [[NSUserDefaults standardUserDefaults] synchronize];
    _isInBackground = YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground \n");
    _isInBackground = NO;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate \n");
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"applicationDidReceiveMemoryWarning \n");
    int success = fz_shrink_store(ctx, _isInBackground ? 0 : 50);
    NSLog(@"fz_shrink_store: success = %d", success);
}

@end

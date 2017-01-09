//
//  AppDelegate.h
//  MuPDFSample
//
//  Created by Calios on 09/01/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    ResourceCacheMaxSize = 128<<20	/**< use at most 128M for resource cache */
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


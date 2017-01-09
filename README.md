# MuPDFSample

**[MuPDF][1]** is a lightweight PDF, XPS, and E-book viewer, and this is a sample for how to use it in iOS project.

Thanks so much to Kevin Delord’s answer [here][2] for saving me much time. 

Here’s a summary based on his answer and some trial and error  when I update it to iOS 10.

### CocoaPods

By all means, using `CocoaPods` or `Carthage` is the most handy way to manage third-party libraries in iOS-developing. However, I found the version of `MuPDF` on `CocoaPods` website is not updated(it's **v1.9, 2016-05**). 

As is mentioned in its [updating comments][3], the newest version **v1.10a(2016-11)** has fixed iOS build issues in it.

### Build static fat library

1. `git clone --recursive git://git.ghostscript.com/mupdf.git`
2. Go to `mupdf/platform/ios`
3. Open `MuPDF.xcodeproj` with Xcode.
4. Configure the scheme of the MuPDF target to *Release*.
5. Build and run the app on an iPhone simulator.
- This will generate the library for platforms i386 and x86\_64.
- You can find the .a files by `Product->Show in Finder`, usually it will lead to path `Release-iphonesimulator/`.
- You can also confirm the platforms by `$ lipo -info libmupdf.a` or `$ lipo -info libmupdfthird.a`.
6. Build and Run the app on a real iPhone device - use your own bundle id, certificate and provisioning profile.
- This will generate the library for platforms armv7 and arm64. 
- You can find the .a files the same way, usually it will lead to path `Release-iphoneos/`.
7. Go to `mupdf/build/Product`
- You will find two folders that contains all built librairies: `Release-iphonesimulator` and `Release-iphoneos`.
8. Now you need to create fat libraries with all 4 architectures for the mupdf one and all its dependencies.

```
	$ lipo -create ./*/libmupdf.a -output 'libmupdf.a';
	$ lipo -create ./*/libmupdfthird.a -output 'libmupdfthird.a';
```

### Integrate MuPDF into your project

1. Add/import into your project:
- All header files from `mupdf/include/mupdf`
- All obj-c classes from `mupdf/platform/ios/` classes
- The common.[h,m] files from `mupdf/platform/ios`

2. Add/import the previously generated fat libraries (2 files)
3. Configure the `Library Search Path` by adding the path to your library files.
- For example `$(inherited) $(PROJECT_DIR)/MuPDFSample/Bundles/mupdf/lib`

4. Configure the `User Header Search Paths` by adding the path to your include files.
- For example `$(PROJECT_DIR)/MuPDFSample/Bundles/mupdf/include `

5. Add compile flag `-fno-objc-arc` for all obj-c classes you added at step 1.(`Target->Build Phases->Compile Sourses`) 

Now you should be able to build and run your app with the library included.

Here's folder structure for this sample.

![sample_project_tree](MuPDFSample/mupdf_sample_project_tree.png)

**Attention:** Since the `.a` files are too large to upload, you'll have to add it by yourself.

### Some other things to mention

1. It seems that some configurations are all set when application just finishes launching. So remember to `#include "common.h"` add these lines in your `-application:didFinishLaunchingWithOptions:` of `AppDelegate.m`.

		queue = dispatch_queue_create("com.calios.mupdfsample.queue", NULL);
	    screenScale = [UIScreen mainScreen].scale;
	    ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
	    fz_register_document_handlers(ctx);

2. Background & foreground & memory warning handlers

```
	@implementation AppDelegate
	{
	    BOOL _isInBackground;
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
```

For more detail, please check the samples.



[1]:	http://mupdf.com/
[2]:	http://stackoverflow.com/a/31111924/1594792
[3]:	http://mupdf.com/news


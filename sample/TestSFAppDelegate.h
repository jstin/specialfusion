//
//  TestSFAppDelegate.h
//  TestSF


#import <UIKit/UIKit.h>
#import "SFScene.h"
#import "SF2DContext.h"

@class TestSFViewController;

@interface TestSFAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestSFViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestSFViewController *viewController;

@end


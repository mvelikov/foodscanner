#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

@synthesize imageToProcess;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	imageToProcess = [UIImage imageNamed:@"ingredients.png"];
	
    return YES;
}

@end

#import <UIKit/UIKit.h>

#import "Config.h"

@interface RecognitionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusIndicator;
@property (strong, nonatomic) NSDictionary *preservativesList;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

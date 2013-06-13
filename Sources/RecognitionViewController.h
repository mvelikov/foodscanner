#import <UIKit/UIKit.h>
#import "Client.h"

@interface RecognitionViewController : UIViewController<ClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusIndicator;
@property (strong, nonatomic) NSDictionary *preservativesList;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

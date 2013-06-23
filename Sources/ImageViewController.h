#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)takePhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *recognizeButton;

@end

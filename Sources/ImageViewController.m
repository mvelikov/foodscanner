#import "ImageViewController.h"
#import "AppDelegate.h"

@implementation ImageViewController
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
//    self.recognizeButton.enabled = NO;
	self.imageView.image = [(AppDelegate*)[[UIApplication sharedApplication] delegate] imageToProcess];
    [super viewDidLoad];
    
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0/255.0f green:166/255.0f blue:81/255.0f alpha:1];
}


- (void)viewDidUnload
{
	[self setImageView:nil];
    [self setRecognizeButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)takePhoto:(id)sender 
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

	imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;

	imagePicker.delegate = self;
	
    self.recognizeButton.enabled = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
//	[self presentModalViewController:imagePicker animated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
    [self.recognizeButton setEnabled:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
//    [picker dismissModalViewControllerAnimated:YES];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
	self.imageView.image = image;

	[(AppDelegate*)[[UIApplication sharedApplication] delegate] setImageToProcess:image];
}

@end

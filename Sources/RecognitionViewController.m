#import "RecognitionViewController.h"
#import "AppDelegate.h"

!!!! Important please provide your Cloud OCR SDK credentials and remove this line !!!!

// Name of application you created
static NSString* MyApplicationID = @"xxxx";
// Password should be sent to your e-mail after application was created
static NSString* MyPassword = @"xxxx";

@implementation RecognitionViewController

@synthesize statusLabel;
@synthesize statusIndicator;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
	[self setStatusLabel:nil];
	[self setStatusIndicator:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	statusLabel.hidden = NO;
	statusIndicator. hidden = NO;
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	statusLabel.text = @"Loading image...";
	
	UIImage* image = [(AppDelegate*)[[UIApplication sharedApplication] delegate] imageToProcess];
	
	Client *client = [[Client alloc] initWithApplicationID:MyApplicationID password:MyPassword];
	
	[client setDelegate:self];
	
	ProcessingParams* params = [[ProcessingParams alloc] init];
	
	[client processImage:image withParams:params];
	
	statusLabel.text = @"Uploading image...";
	
    [super viewDidAppear:animated];
    
    if (!self.preservativesList) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"preservatives" ofType:@"plist"];
        
        self.preservativesList = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    
//    NSDictionary *foundPreservatives = [self getPreservativesFromText:@"E300, E102, E904, E300"];
//    
//    [self drawTextElementsForFoundPreservatives:foundPreservatives];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

#pragma mark - ClientDelegate implementation

- (void)clientDidFinishUpload:(Client *)sender
{
	statusLabel.text = @"Processing image...";
}

- (void)clientDidFinishProcessing:(Client *)sender
{
	statusLabel.text = @"Downloading result...";
}

- (void)client:(Client *)sender didFinishDownloadData:(NSData *)downloadedData
{
	statusLabel.hidden = YES;
	statusIndicator.hidden = YES;
	
//	textView.hidden = NO;
	
	NSString* result = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
	
    NSDictionary *foundPreservatives = [self getPreservativesFromText:result];
    [self drawTextElementsForFoundPreservatives:foundPreservatives];
//	textView.text = result;
    
    
}

- (void)client:(Client *)sender didFailedWithError:(NSError *)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:[error localizedDescription]
												   delegate:nil 
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:nil, nil];
	
	[alert show];
	
	statusLabel.text = [error localizedDescription];
	statusIndicator.hidden = YES;
}

-(NSDictionary *) getPreservativesFromText:(NSString *)theText
{

    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((E|e)(\\s)?\\d{3})" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSArray *myArray = [regex matchesInString:theText options:0 range:NSMakeRange(0, [theText length])] ;
    
    NSMutableArray *matches = [NSMutableArray arrayWithCapacity:[myArray count]];
    
    NSMutableDictionary *foundPreservativesList = [NSMutableDictionary dictionary];
    
    for (NSTextCheckingResult *match in myArray) {
        NSRange matchRange = [match rangeAtIndex:1];
        [matches addObject:[theText substringWithRange:matchRange]];

        [foundPreservativesList setObject:[matches lastObject] forKey:[matches lastObject]
         ];
    }
    
    return foundPreservativesList;

}

-(void) drawTextElementsForFoundPreservatives:(NSDictionary *)thePreservativesList
{
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    int y = 10, width = 300, labelHeight = 20, textViewHeight = 100;
    UILabel *groupLabel, *latinLabel, *preservativeLabel;
    UITextView *descriptionTextView;
    UIColor *labelColor;
    
    
    BOOL isPreservativeFound = NO;
    for (NSString *preservative in thePreservativesList) {
        info = [self.preservativesList objectForKey:preservative];
        
        if (info) {
            
            isPreservativeFound = YES;
            if ([info[@"type"] isEqualToString:@"good"]) {
                labelColor = [UIColor greenColor];
            } else if ([info[@"type"] isEqualToString: @"neutral"]) {
                labelColor = [UIColor yellowColor];
            } else if ([info[@"type"] isEqualToString:@"bad"]) {
                labelColor = [UIColor redColor];
            }
            
            preservativeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, labelHeight)];
            [preservativeLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [preservativeLabel setBackgroundColor:labelColor];
            [preservativeLabel setText:preservative];
            [self.scrollView addSubview:preservativeLabel];
            
            y += labelHeight;
            
            latinLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, labelHeight)];
            [latinLabel setBackgroundColor:labelColor];
            [latinLabel setText:info[@"latin"]];
            [self.scrollView addSubview:latinLabel];
            
            y += labelHeight;
            groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, labelHeight)];
            [groupLabel setBackgroundColor:labelColor];
            [groupLabel setText:info[@"group"]];
            
            [self.scrollView addSubview:groupLabel];
            y += labelHeight;
            
            descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, y, width, textViewHeight)];
            [descriptionTextView setEditable:NO];
            [descriptionTextView setBackgroundColor:[UIColor clearColor]];
            [descriptionTextView setFont:[UIFont systemFontOfSize:14]];
            [descriptionTextView setBounces:NO];
            [descriptionTextView setBouncesZoom:NO];
            [descriptionTextView setUserInteractionEnabled:NO];
            
            [descriptionTextView setText:info[@"description"]];
            [self.scrollView addSubview:descriptionTextView];
            
            
            y += textViewHeight;
        }
    }
    
    if (!isPreservativeFound) {
        descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, y, width, textViewHeight)];
        [descriptionTextView setEditable:NO];
        [descriptionTextView setBackgroundColor:[UIColor clearColor]];
        [descriptionTextView setText:@"No preservatives were found in the image you just shot. Please, try another image."];
        [descriptionTextView setFont:[UIFont boldSystemFontOfSize:18]];
        [self.scrollView addSubview:descriptionTextView];
    }
//    CGRect scrollFrame = CGRectMake(0, 0, width, y);
//    self.scrollView.frame = scrollFrame;
//    
    [self.scrollView setContentSize:(CGSizeMake(320, y))];
    
    statusLabel.hidden = YES;
	statusIndicator.hidden = YES;
	
    //	textView.hidden = NO;
	

}

@end
#import "RecognitionViewController.h"
#import "AppDelegate.h"
#import "Tesseract.h"

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

    Tesseract *tesseract = [self getTessaractObject];

    [tesseract setImage:image];
    [tesseract recognize];
    
    [super viewDidAppear:animated];
    
    if (!self.preservativesList) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"additives" ofType:@"plist"];
        
        self.preservativesList = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }

    NSString* readTextFromImage = [tesseract recognizedText];
    NSArray *foundPreservatives = [self getPreservativesFromText:readTextFromImage];

    [tesseract clear];
    readTextFromImage = nil;
    
    
    [self drawTextElementsForFoundPreservatives:foundPreservatives];
}

-(Tesseract *)getTessaractObject
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([documentPaths count] > 0) ? [documentPaths objectAtIndex:0] : nil;
    
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"tessdata"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:dataPath]) {
        // get the path to the app bundle (with the tessdata dir)
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
        if (tessdataPath) {
            [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
        }
    }
    
    setenv("TESSDATA_PREFIX", [[documentPath stringByAppendingString:@"/"] UTF8String], 1);
    
    
    Tesseract *tesseract = [[Tesseract alloc] initWithDataPath:dataPath language:@"eng"];
    
    return tesseract;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

-(NSArray *) getPreservativesFromText:(NSString *)theText
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((E|e)(\\s)?(\\d{3}))" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSArray *myArray = [regex matchesInString:theText options:0 range:NSMakeRange(0, [theText length])] ;
    
    NSMutableArray *matches = [NSMutableArray arrayWithCapacity:[myArray count]];
    
    NSMutableArray *foundPreservativesList = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in myArray) {
        NSRange matchRange = [match rangeAtIndex:1];

        NSString *textMathingAdditivePattern = [theText substringWithRange:matchRange];
        NSString *textWithoutWhitespace = [textMathingAdditivePattern stringByReplacingOccurrencesOfString:@" " withString:@""];

        [matches addObject:[textWithoutWhitespace uppercaseString]];

        [foundPreservativesList addObject:[matches lastObject]];
    }
    
    NSArray *noDuplicatesPreservativesList = [[NSSet setWithArray:foundPreservativesList] allObjects];
    
    NSArray *sortedAdditives = [noDuplicatesPreservativesList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {

        return [a compare:b];
    }];

    return [sortedAdditives copy];

}

-(void) drawTextElementsForFoundPreservatives:(NSArray *)thePreservativesList
{
    NSDictionary *info = [NSDictionary dictionary];
    int y = 10, width = 300, labelHeight = 20, textViewHeight = 100;
    UILabel *groupLabel, *latinLabel, *preservativeLabel;
    UITextView *descriptionTextView;
    UIColor *labelColor = [UIColor whiteColor];
    
    
    BOOL isPreservativeFound = NO;
    for (NSString *preservative in thePreservativesList) {

        info = [self.preservativesList objectForKey:preservative];
        
        if (info) {
            
            isPreservativeFound = YES;
//            if ([info[@"type"] isEqualToString:@"good"]) {
//                labelColor = [UIColor greenColor];
//            } else if ([info[@"type"] isEqualToString: @"neutral"]) {
//                labelColor = [UIColor yellowColor];
//            } else if ([info[@"type"] isEqualToString:@"bad"]) {
//                labelColor = [UIColor redColor];
//            }
            
            preservativeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, labelHeight)];
            [preservativeLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [preservativeLabel setBackgroundColor:labelColor];
            [preservativeLabel setText:preservative];
            [preservativeLabel setTextAlignment:NSTextAlignmentCenter];
            [self.scrollView addSubview:preservativeLabel];
            
            y += labelHeight;
            
            latinLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, labelHeight)];
            [latinLabel setBackgroundColor:labelColor];
            [latinLabel setText:info[@"name"]];
            [self.scrollView addSubview:latinLabel];
            
            y += labelHeight;
            groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, labelHeight)];
            [groupLabel setBackgroundColor:labelColor];
            [groupLabel setText:info[@"function"]];
            
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
            
            CGRect frame;
            frame = descriptionTextView.frame;
            frame.size.height = [descriptionTextView contentSize].height;
            descriptionTextView.frame = frame;
            
            
            y += frame.size.height + 10;
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

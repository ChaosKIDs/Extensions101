//
//  ActionViewController.m
//  PhotoFilterExt
//
//  Created by ChaosKIDs on 6/4/14.
//  Copyright (c) 2014 Hanuman Tech Ltd. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
@import CoreImage;

int tapCount;

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic) UIImage *sourceImage;
@property(nonatomic) NSArray *filterNames;
@property (strong, nonatomic) IBOutlet UILabel *filterNameLabel;

@end

@implementation ActionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Filter array setup
    self.sourceImage = self.imageView.image;
    self.filterNames = @[@"No effects",
                         @"CIPhotoEffectChrome",
                         @"CIPhotoEffectFade",
                         @"CIPhotoEffectInstant",
                         @"CIPhotoEffectMono",
                         @"CIPhotoEffectNoir",
                         @"CIPhotoEffectProcess",
                         @"CIPhotoEffectTonal",
                         @"CIPhotoEffectTransfer",
                         @"CIVignette",];
    self.filterNameLabel.text = [self.filterNames objectAtIndex:tapCount];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak UIImageView *imageView = self.imageView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            self.sourceImage = image;
                            
                            [imageView setImage:self.sourceImage];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)filterImage:(UIImage *)sourceImage
{
    CIImage *processImage = [[CIImage alloc]initWithImage:self.sourceImage];
    CIFilter *filter = [CIFilter filterWithName:[self.filterNames objectAtIndex:tapCount] keysAndValues:kCIInputImageKey,processImage, nil];
    [filter setDefaults];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    
    return resultImage;
}

- (IBAction)imageTap:(id)sender {
    if (tapCount < self.filterNames.count - 1) {
        tapCount ++;
        __weak UIImageView *imageView = self.imageView;
        [imageView setImage:[self filterImage:self.sourceImage]];
    }else{
        tapCount = 0;
        self.imageView.image = self.sourceImage;
    }
    self.filterNameLabel.text = [self.filterNames objectAtIndex:tapCount];
}
- (IBAction)cancelBTNTap:(id)sender {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"User Canceled"
                                                                     code:0
                                                                 userInfo:nil]];
}

- (IBAction)doneBTNTap {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    
    NSLog(@"Operation Done");
    
    NSExtensionItem* extensionItem = [[NSExtensionItem alloc] init];
    [extensionItem setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Photo Filter"]];
    
    [extensionItem setAttachments:@[[[NSItemProvider alloc] initWithItem:self.imageView.image typeIdentifier:(NSString*)kUTTypeImage]]];

    [self.extensionContext completeRequestReturningItems:@[extensionItem] completionHandler:nil];
}

@end

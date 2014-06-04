//
//  ViewController.m
//  Extensions101
//
//  Created by ChaosKIDs on 6/4/14.
//  Copyright (c) 2014 Hanuman Tech Ltd. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *picker;
}
            
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)editSelectedPhoto
{
    NSLog(@"Editing");
    
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:@[self.imageView.image]
                                            applicationActivities:nil];
    
    [activityVC setCompletionWithItemsHandler:^(NSString *activityType,
                                                BOOL completed,
                                                NSArray *returnedObjects,
                                                NSError *error){
        if(returnedObjects.count != 0){
            NSLog(@"Returned Object:%@",[returnedObjects objectAtIndex:0]);
            
            NSExtensionItem* extensionItem = [returnedObjects objectAtIndex:0];
            
            NSItemProvider* itemProvider = [extensionItem.attachments objectAtIndex:0];
            
            if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]){
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    
                    if(image && !error){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //[imageView setImage:item];
                            
                            [self.imageView setImage:image];
                        });
                        
                    }
                }];
                
            }
        }

    }];
    
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        
        UIBarButtonItem *editBTN = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editSelectedPhoto)];
        self.navigationItem.leftBarButtonItem = editBTN;
        
    }];
}
- (IBAction)chooseBTNTap:(id)sender {
    
    NSLog(@"Choose photo from library");
    
    [self presentViewController:picker animated:YES completion:nil];
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ExportSelector.m
//  iRow
//
//  Created by David van Leeuwen on 9/26/12.
//  Copyright (c) 2012 strApps. All rights reserved.
//

#import "ExportSelector.h"
#import "DBExport.h"

@implementation ExportSelector

@synthesize segmentedControl;
@synthesize item;
@synthesize viewController;
@synthesize recipients;

-(id)init {
    self = [super init];
    if (self) {
        segmentedControl = [[MySegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"DB item", @"KML",nil]];
        segmentedControl.momentary = NO;
        [segmentedControl addTarget:self action:@selector(exportSelected:) forControlEvents:UIControlEventTouchUpInside];
        [segmentedControl addTarget:self action:@selector(disableSegments:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

-(void)exportSelected:(id)sender {
    MySegmentedControl * segments = (MySegmentedControl*)sender;
    if (![item respondsToSelector:@selector(name)] || [item name]==nil) return;
    itemType = NSStringFromClass([item class]);
    NSURL * dir = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"tmp" isDirectory:YES];
    // we can't always write in this dir?
    //    NSURL * dir = [NSURL URLWithString:NSTemporaryDirectory()];
    exportFile = [[dir URLByAppendingPathComponent:[item name]] URLByAppendingPathExtension:segments.selectedSegmentIndex ? @"kml" : @"iRow"];
//    NSLog(@"%@", exportFile);
    NSError * error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[exportFile path]]) [[NSFileManager defaultManager] removeItemAtURL:exportFile error:&error];
    BOOL success = NO;
    switch (segments.selectedSegmentIndex) {
        case 0: { // DB item
            DBExport * export = [[DBExport alloc] init];
            [export addItem:item];
            success = [NSKeyedArchiver archiveRootObject:export toFile:[exportFile path]];
            exportType = kExportDBitem;
            break;
        }
        case 1: { // kml
            success = [item writeKML:exportFile];
            exportType = kExportKML;
            break;
        }
        default:
            break;
    }
    if (success) {
        /*
         UIDocumentInteractionController * dic = [UIDocumentInteractionController interactionControllerWithURL:exportFile];
         dic.UTI = @"application/vnd.google-earth.kml+xml";
         */
        UIActionSheet * a = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Export this %@ using", itemType] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"iTunes import",@"email", nil];
        [a showFromTabBar:viewController.tabBarController.tabBar];
    } else {
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, I could not save this %@",itemType] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
        
    }
    segments.selectedSegmentIndex = UISegmentedControlNoSegment;
}

-(void)disableSegments:(id)sender {
    MySegmentedControl * segments = (MySegmentedControl*)sender;
    segments.selectedSegmentIndex = -1;
}

#pragma mark - UIActioSheetDelegate

// these are all the action sheets in this view
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error;
    switch (buttonIndex) {
        case 0: {
            NSURL * dest = [[[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:[exportFile lastPathComponent]];
//            NSLog(@"%@", dest);
            if ([fm fileExistsAtPath:[dest path]]) [fm removeItemAtURL:dest error:&error];
            if ([fm moveItemAtURL:exportFile toURL:dest error:&error]) {
                UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Saved" message:[NSString stringWithFormat:@"The %@ is saved and can be accessed through iTunes File Sharing",itemType] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            } else {
                UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Sorry, I could not save this %@",itemType] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
            break;
        }
        case 1: {
            if (![MFMailComposeViewController canSendMail]) {
                UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, this device has not been set up to send mail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
            MFMailComposeViewController * mcvc = [[MFMailComposeViewController alloc] init];
            mcvc.mailComposeDelegate = self;
            [mcvc setSubject:[NSString stringWithFormat:@"Row %@ %@", itemType, [item name]]];
            [mcvc setToRecipients:recipients];
            NSData * data = [NSData dataWithContentsOfURL:exportFile];
            NSString * mimeType = exportType==kExportDBitem ? @"application/vnd.strapps-irow.db" : @"application/vnd.google-earth.kml+xml";
            [mcvc addAttachmentData:data mimeType:mimeType fileName:[exportFile lastPathComponent]];
            [viewController presentModalViewController:mcvc animated:YES];
            break;
        }
        case 2:
            [fm removeItemAtURL:exportFile error:&error];
            break;
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed)
		[[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"I am sorry, an error occurred in sending the %@",itemType] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	[viewController dismissModalViewControllerAnimated:YES];
}




@end

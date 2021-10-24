/*************************************************************************/
/*  in_app_store.mm                                                      */
/*************************************************************************/
/*                       This file is part of:                           */
/*                           GODOT ENGINE                                */
/*                      https://godotengine.org                          */
/*************************************************************************/
/* Copyright (c) 2007-2021 Juan Linietsky, Ariel Manzur.                 */
/* Copyright (c) 2014-2021 Godot Engine contributors (cf. AUTHORS.md).   */
/*                                                                       */
/* Permission is hereby granted, free of charge, to any person obtaining */
/* a copy of this software and associated documentation files (the       */
/* "Software"), to deal in the Software without restriction, including   */
/* without limitation the rights to use, copy, modify, merge, publish,   */
/* distribute, sublicense, and/or sell copies of the Software, and to    */
/* permit persons to whom the Software is furnished to do so, subject to */
/* the following conditions:                                             */
/*                                                                       */
/* The above copyright notice and this permission notice shall be        */
/* included in all copies or substantial portions of the Software.       */
/*                                                                       */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                */
/*************************************************************************/

#include "app_share_dialog.h"

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "platform/iphone/godot_app_delegate.h"

AppShareDialog *AppShareDialog::instance = NULL;


void AppShareDialog::_bind_methods() {
	ClassDB::bind_method(D_METHOD("share_text"), &AppShareDialog::share_text);
	ClassDB::bind_method(D_METHOD("share_image"), &AppShareDialog::share_image);
}

AppShareDialog *AppShareDialog::get_singleton() {
	return instance;
}

AppShareDialog::AppShareDialog() {
	ERR_FAIL_COND(instance != NULL);
	instance = this;
}


AppShareDialog::~AppShareDialog() {
}

void AppShareDialog::share_text(const String &title, const String &subject, const String &text) {

	UIViewController *root_controller = (UIViewController*)[[(GodotApplicalitionDelegate*)[[UIApplication sharedApplication]delegate] window] rootViewController];
	//UIViewController *root_controller = [UIApplication sharedApplication].keyWindow.rootViewController;

	NSString * message = [NSString stringWithCString:text.utf8().get_data() encoding:NSUTF8StringEncoding];

	NSArray * shareItems = @[message];

	UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
	avc.excludedActivityTypes = @[UIActivityTypePostToTwitter,UIActivityTypePostToFacebook,UIActivityTypeMessage,UIActivityTypeSaveToCameraRoll];
	avc.popoverPresentationController.sourceRect = CGRectMake(
		root_controller.view.frame.size.width/4, 
		root_controller.view.frame.size.height/4, 
		root_controller.view.frame.size.height/2, 
		root_controller.view.frame.size.height/2
	);
	//if iPhone
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[root_controller presentViewController:avc animated:YES completion:nil];
	}
	//if iPad
	else {
	// Change Rect to position Popover
		
		avc.modalPresentationStyle                   = UIModalPresentationPopover;
		avc.popoverPresentationController.sourceView = root_controller.view;
		[root_controller presentViewController:avc animated:YES completion:nil];
		
	}
}

void AppShareDialog::share_image(const String &path, const String &title, const String &subject, const String &text) {
	UIViewController *root_controller = (UIViewController*)[[(GodotApplicalitionDelegate*)[[UIApplication sharedApplication]delegate] window] rootViewController];
	
	NSString * message = [NSString stringWithCString:text.utf8().get_data() encoding:NSUTF8StringEncoding];
	NSString * imagePath = [NSString stringWithCString:path.utf8().get_data() encoding:NSUTF8StringEncoding];

	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

	NSArray * shareItems = @[message, image];

	UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
	avc.excludedActivityTypes = @[UIActivityTypePostToTwitter,UIActivityTypePostToFacebook,UIActivityTypeMessage,UIActivityTypeSaveToCameraRoll];
	avc.popoverPresentationController.sourceRect = CGRectMake(
		root_controller.view.frame.size.width/4, 
		root_controller.view.frame.size.height/4, 
		root_controller.view.frame.size.height/2, 
		root_controller.view.frame.size.height/2
	);
	 //if iPhone
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[root_controller presentViewController:avc animated:YES completion:nil];
	}
	//if iPad
	else {
		// Change Rect to position Popover
		avc.modalPresentationStyle                   = UIModalPresentationPopover;
		avc.popoverPresentationController.sourceView = root_controller.view;
		[root_controller presentViewController:avc animated:YES completion:nil];
	}
}


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

#include "store_review_controller.h"

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


#if defined(OSX_ENABLED)
	//#import "platform/iphone/app_delegate.h"
#else
	#import "platform/iphone/app_delegate.h"
#endif

StoreReviewController *StoreReviewController::instance = NULL;


void StoreReviewController::_bind_methods() {
	ClassDB::bind_method(D_METHOD("request_review"), &StoreReviewController::request_review);
}

void StoreReviewController::request_review() {

#if defined(OSX_ENABLED)
	[SKStoreReviewController requestReview];
#else
	//ios 14+ 
	if (@available(iOS 14.0, *)) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		UIWindow *window = (UIWindow *)[app window];
		if (window != NULL) {
			UIWindowScene *scene = (UIWindowScene *)[window windowScene];
			if (scene != NULL) {
				[SKStoreReviewController requestReviewInScene: scene];
				printf("request reviewed!\n");
				return;
			}
			else {
				printf("request review scene invalid");
			}
		}
		else {
			printf("request review window invalid");
		}
	}
	else {
		printf("request review IOS version < 14.0");
	}

	//deperdicated
	if (@available(iOS 10.3, *)) { 
		[SKStoreReviewController requestReview];
		printf("request reviewed! old variant\n");
	}
#endif
}



StoreReviewController *StoreReviewController::get_singleton() {
	return instance;
}

StoreReviewController::StoreReviewController() {
	ERR_FAIL_COND(instance != NULL);
	instance = this;
}


StoreReviewController::~StoreReviewController() {
}

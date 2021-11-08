/*************************************************************************/
/*  spotlight.mm                                                         */
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

#include "spotlight.h"


#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Foundation/Foundation.h>
#import "platform/iphone/godot_app_delegate.h"

Spotlight* Spotlight::instance = NULL;

Spotlight::Spotlight() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

Spotlight::~Spotlight() {
}

void Spotlight::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_search_item"), &Spotlight::set_search_item);
}

void Spotlight::set_search_item(Dictionary params) {
        String unique_identifier = params.get("unique_identifier", "");
        String domain_identifier = params.get("domain_identifier", "");
        String titile = params.get("title", "");
        String content_description = params.get("content_description", "");
        String image_path = params.get("image_path", "");
        Array keywords = params.get("keywords", Array());

        CSSearchableItemAttributeSet *attributeSet;
        if (image_path.empty()) {
            attributeSet = [[CSSearchableItemAttributeSet alloc]
                                            initWithItemContentType:(NSString *)kUTTypeData];
        }
        else {
            attributeSet = [[CSSearchableItemAttributeSet alloc]
                                            initWithItemContentType:(NSString *)kUTTypeImage];
            NSString *ns_img_path = [[NSString alloc] initWithUTF8String:img_path.utf8().get_data()];
            UIImage *image = [UIImage imageWithContentsOfFile:ns_img_path];
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
            attributeSet.thumbnailData = imageData;
        }


        if (!titile.empty()) {
            NSString *ns_titile = [[NSString alloc] initWithUTF8String:titile.utf8().get_data()];
            attributeSet.title = ns_titile;
        }
        else {
            NSLog(@"SPOTLIGHT: title is empty!");
        }

        if (!content_description.empty()) {
            NSString *ns_content_description = [[NSString alloc] initWithUTF8String:content_description.utf8().get_data()];
            attributeSet.contentDescription = ns_content_description;
        }

        if (!keywords.empty()) {
            NSMutableArray *ns_keys = [[NSMutableArray alloc] initWithCapacity:keywords.size()];
            for (int i = 0; i < keywords.size(); i++) {
                NSString *key = [[NSString alloc] initWithUTF8String:keywords[i].utf8().get_data()];
                [ns_keys addObject:key];
            }
            attributeSet.keywords = ns_keys;
        }
        else {
            NSLog(@"SPOTLIGHT:keywords is empty!");
        }


        NSString *ns_unique_identifier = [[NSString alloc] initWithUTF8String:unique_identifier.utf8().get_data()];
        NSString *ns_domain_identifier = [[NSString alloc] initWithUTF8String:domain_identifier.utf8().get_data()];
        if (domain_identifier.empty()) {
            NSLog(@"SPOTLIGHT: domain_identifier empty!");
        }
        
        if (unique_identifier.empty()) {
            NSLog(@"SPOTLIGHT: unique_id is empty!");
        }

        CSSearchableItem *item = [[CSSearchableItem alloc]
                                            initWithUniqueIdentifier:ns_unique_identifier
                                                    domainIdentifier:ns_domain_identifier
                                                        attributeSet:attributeSet];

        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item]
                                        completionHandler: ^(NSError * __nullable error) {
            if (!error) {
                NSLog(@"SPOTLIGHT: Search item indexed");
            }
            else {
                NSLog(@"SPOTLIGHT: Search item indexed failed!");
            }
        }];

}


Spotlight* Spotlight::get_singleton() {
    return instance;
}


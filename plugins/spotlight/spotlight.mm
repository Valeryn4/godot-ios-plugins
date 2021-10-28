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


Spotlight::Spotlight() {

}

Spotlight::~Spotlight() {

}

void Spotlight::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_search_item"), &InAppStore::set_search_item);
}

void Spotlight::set_search_item(
    const String &unique_id, 
    const String &domain_id, 
    const String &titile, 
    const String &description, 
    const String &img_path,
    const Spotlight::GodotStringArrayT &keys) {

        CSSearchableItemAttributeSet *attributeSet;
        attributeSet = [[CSSearchableItemAttributeSet alloc]
                                        initWithItemContentType:(NSString *)kUTTypeImage];

        if (!titile.empty()) {
            NSString *ns_titile = [[NSString alloc] initWithUTF8String:titile.utf8().get_data()];
            attributeSet.title = ns_titile;
        }
        else {
            WARN_PRINT("title is empty!");
        }

        if (!description.empty()) {
            NSString *ns_description = [[NSString alloc] initWithUTF8String:unique_id.utf8().get_data()];
            attributeSet.contentDescription = ns_description;
        }

        if (!keys.empty()) {
            NSMutableArray *ns_keys = [[NSMutableArray alloc] initWithCapacity:keys.size()];
            for (int i = 0; i < keys.size(); i++) {
                NSString *key = [[NSString alloc] initWithUTF8String:keys[i].utf8().get_data()];
                [ns_keys addObject:key];
            }
            attributeSet.keywords = ns_keys;
        }
        else {
            WARN_PRINT("keywords is empty!");
        }

        if (!img_path.empty()) {
            NSString *ns_img_path = [[NSString alloc] initWithUTF8String:img_path.utf8().get_data()];
            UIImage *image = [UIImage imageWithContentsOfFile:ns_img_path];
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
            attributeSet.thumbnailData = imageData;
        }

        NSString *ns_unique_id = [[NSString alloc] initWithUTF8String:unique_id.utf8().get_data()];
        NSString *ns_domain_id = [[NSString alloc] initWithUTF8String:domain_id.utf8().get_data()];
        
        if (unique_id.empty() || domain_id.empty()) {
            WARN_PRINT("unique_id or domaint_id is empty!");
            return
        }

        CSSearchableItem *item = [[CSSearchableItem alloc]
                                            initWithUniqueIdentifier:ns_unique_id
                                                    domainIdentifier:ns_domain_id
                                                        attributeSet:attributeSet];

        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item]
                                        completionHandler: ^(NSError * __nullable error) {
            if (!error) {
                NSLog(@"Search item indexed");
            }
            else {
                WARN_PRINT("Search item indexed failed!");
            }
        }];

}
//
//  BundleEditorSearch.h
//  BundleEditorSearch
//
//  Created by Ciaran Walsh on 15/10/2007.

#import <Cocoa/Cocoa.h>

@protocol TMPlugInController
- (float)version;
@end

@interface BundleEditorSearch : NSObject
{
}
- (id)initWithPlugInController:(id <TMPlugInController>)aController;
@end

// These prevent warnings from showing for messages we use that aren’t known
// by the compiler
@interface NSObject (BundleManager)
- (NSArray*)languages;
- (id)bundleItemForUUID:(NSString*)uuid;
@end

@interface NSObject (OakBundleEditor)
- (void)showItem:(id)item;
@end

@interface NSObject (BundleItem)
- (NSArray*)bundlePaths;
- (NSArray*)sourcePaths;
@end
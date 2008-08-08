//
//  BundleEditorSearch.mm
//  BundleEditorSearch
//
//  Created by Ciaran Walsh on 15/10/2007.

#import "BundleEditorSearch.h"
#import "MethodSwizzle.h"

// Recursively check each of view’s subviews for an NSTextView
// If one is found it will be made the first responder
NSTextView *findAndFocusFirstTextViewIn(NSView *view) {
	NSArray *subviews         = [view subviews];
	unsigned int subviewCount = [subviews count];
	NSTextView *textView      = nil;

	for (unsigned int index = 0; index < subviewCount; index += 1) {
		NSView *subview = [subviews objectAtIndex:index];
		if ([subview isKindOfClass:[NSTextView class]]) {
			// [[subview window] performSelector:@selector(makeFirstResponder:) withObject:subview afterDelay:0.0];
			// [[subview window] makeFirstResponder:subview];
			return (NSTextView *)subview;
		} else if (textView = findAndFocusFirstTextViewIn(subview)) {
			return textView;
		}
	}
	return nil;
}

@implementation NSWindowController (OakSelectBundleItem)
// Returns YES to indicate that the user is in the bundle editor (and we should use our additions)
- (BOOL)isInBundleEditor
{
	return [[NSApp mainWindow] isKindOfClass:NSClassFromString(@"OakBundleEditorWindow")];
}

// Here we want to make the key equivalent search mode show all results
// (regardless of scope) when inside the bundle editor
- (void)swizzledShowKeyEquivalent:(NSEvent *)keyEquivalent withResults:(NSArray *)results
{
	if ([self isInBundleEditor]) {
		OakSelectBundleItem *controller = (OakSelectBundleItem*)self;
		// First we call the standard method to display the key equivalent in the search field
		// Because the scope filter is empty, this method will only show bundle items
		// which are completely unscoped
		[self swizzledShowKeyEquivalent:keyEquivalent withResults:results];
		[controller->bundleItems release];
		// The results we receive are an array of all the items matching the key equivalent
		// so we can simply replace the internal array of matches with this array,
		// and tell the tableview to reload itself
		controller->bundleItems = [results retain];
		[[controller->bundleItemsTableColumn tableView] reloadData];
	} else {
		[self swizzledShowKeyEquivalent:keyEquivalent withResults:results];
	}
}

// This method is the search field’s action (i.e. it is called when the search text is changed)
// Here we do a basic search for languages matching the search and add them to the results
- (void)swizzledSearch:(id)search
{
	OakSelectBundleItem *controller = (OakSelectBundleItem*)self;
	NSString *searchString          = [search stringValue];
	BOOL isNewSearch                = ![searchString isEqualToString:controller->filterString];

	// Call the standard method to get the normal results
	[self swizzledSearch:search];

	if ([self isInBundleEditor] && searchString && [searchString length] > 0 && isNewSearch) {
		// languages is an array of NSDictionaries with the language plists
		NSArray *languages         = [[NSClassFromString(@"BundleManager") sharedInstance] languages];
		NSPredicate *predicate     = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@",searchString];
		NSArray *matchedLangauges  = [languages filteredArrayUsingPredicate:predicate];
		NSMutableArray *newMatches = [controller->bundleItems mutableCopy]; // newMatches will be our result array
		[controller->bundleItems release]; // Destroy the old array as we don’t need it any more

		// The tableview datasource methods expect an OakBundleItem so here we have to convert all our
		// matches and then add them to the results
		unsigned int languageCount = [matchedLangauges count];
		for (unsigned int index = 0; index < languageCount; index += 1) {
			NSDictionary *languageDictionary = [matchedLangauges objectAtIndex:index];
			id language = [[NSClassFromString(@"BundleManager") sharedInstance] bundleItemForUUID:[languageDictionary objectForKey:@"uuid"]];
			// Add the language to the top of the list, as our search method is more basic than the standard one
			// and language names are likely to be an explicit query
			[newMatches insertObject:language atIndex:0];
		}
		controller->bundleItems = newMatches;
		[[controller->bundleItemsTableColumn tableView] reloadData];
	}
}

// This is the method which is called when a user selects an item
// We have to select the item in the bundle editor
// Fortunately the OakBundleEditor has a method for just that :)
- (void)swizzledAccept:(id)sender
{
	if ([self isInBundleEditor]) {
		OakSelectBundleItem *controller = [[sender window] delegate];
		NSTableColumn *bundleItemsTableColumn = controller->bundleItemsTableColumn;
		int selectedRow = [[[bundleItemsTableColumn tableView] selectedRowIndexes] firstIndex];
		id selectedBundleItem = [controller->bundleItems objectAtIndex:selectedRow];
		
		OakBundleEditor *bundleEditor = [NSClassFromString(@"OakBundleEditor") sharedInstance];
		[bundleEditor showItem:selectedBundleItem];
		
		// Focus the relevant editor view
		NSTextView *textView = findAndFocusFirstTextViewIn(bundleEditor->editorBox);
		// By default the selection will be at the end of the text, so move it to the top
		[textView setSelectedRange:NSMakeRange(0, 0)];
	}
	// We call the standard method even if we are using our custom functionlity
	// to hide the window (it will have no effect if there is no document active)
	[self swizzledAccept:sender];
}
@end

@implementation NSOutlineView (OakBundleOutlineView)
- (int)selectedRowIndex
{
	int rowNumber = [self rowAtPoint:[self convertPoint:[[NSApp currentEvent] locationInWindow] fromView:nil]];
	if (rowNumber == -1)
		rowNumber = [self selectedRow];

	return rowNumber;
}

- (id)BundleEditorSearch_selectedItem
{
	return [self itemAtRow:[self selectedRowIndex]];
}

- (void)revealPathInFinder:(id)sender
{
	NSString *path = [sender title];

	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
}

- (void)revealPathInTerminal:(id)sender
{
	NSString *path = [sender title];

	NSString *source;
	if ([path hasSuffix:@".tmbundle"]) {
		source = @"tell app \"Terminal\"\n"
				 @"	activate\n"
				 @"	do script with command \"ITEM_PATH='%@'\"\n"
				 @"	do script with command \"cd \\\"$ITEM_PATH\\\"\" in front window\n"
				 @"end tell";
	} else {
		source = @"tell app \"Terminal\"\n"
				 @"	activate\n"
				 @"	do script with command \"ITEM_PATH='%@'\"\n"
				 @"	do script with command \"cd \\\"$(dirname \\\"$ITEM_PATH\\\")\\\"\" in front window\n"
				 @"	do script with command \"ls \\\"$(basename \\\"$ITEM_PATH\\\")\\\"\" in front window\n"
				 @"end tell";
	}
	source = [NSString stringWithFormat:source, path];

	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
	[script executeAndReturnError:NULL];
	[script release];
}

// ==================
// = Menu delegates =
// ==================
- (void)menuNeedsUpdate:(NSMenu *)menu
{
	// Remove all items
	int itemCount = [menu numberOfItems];
	for (int index = 0; index < itemCount; index++)
		[menu removeItemAtIndex:0];
	
	id item = [self BundleEditorSearch_selectedItem];
	NSArray *paths = nil;

	if ([item respondsToSelector:@selector(bundlePaths)]) {
		paths = [item bundlePaths];
	} else if ([item respondsToSelector:@selector(sourcePaths)]) {
		paths = [item sourcePaths];
	}

	if (paths) {
		unsigned int pathCount = [paths count];

		for (unsigned int index = 0; index < pathCount; index += 1) {
			NSString *path = [paths objectAtIndex:index];
			NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:path action:@selector(revealPathInFinder:) keyEquivalent:@""];
			{
				if ([[menu title] isEqualToString:@"Terminal"])
					[menuItem setAction:@selector(revealPathInTerminal:)];
				[menu addItem:menuItem];
			}
			[menuItem release];
		}
	}
}

// =========
// = Setup =
// =========
- (void)awakeFromNib
{
	if (! [NSStringFromClass([self class]) isEqualToString:@"OakBundleOutlineView"])
		return;

	NSMenu *menu = [[NSMenu alloc] init];
	{
		NSMenuItem *menuItem;

		menuItem = [[NSMenuItem alloc] initWithTitle:@"Reveal in Finder" action:NULL keyEquivalent:@""];
		{
			NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"Finder"];
			{
				[subMenu setDelegate:self];
				[menuItem setSubmenu:subMenu];
			}
			[subMenu release];

			[menu addItem:menuItem];
		}
		[menuItem release];

		menuItem = [[NSMenuItem alloc] initWithTitle:@"Reveal in Terminal" action:NULL keyEquivalent:@""];
		{
			NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"Terminal"];
			{
				[subMenu setDelegate:self];
				[menuItem setSubmenu:subMenu];
			}
			[subMenu release];

			[menu addItem:menuItem];
		}
		[menuItem release];

		[self setMenu:menu];
	}
	[menu release];
}
@end

@implementation BundleEditorSearch

- (id)initWithPlugInController:(id <TMPlugInController>)aController
{
	self  = [self init];
	NSApp = [NSApplication sharedApplication];

	[NSClassFromString(@"OakSelectBundleItem") swizzleInstanceMethod:@selector(accept:) withMethod:@selector(swizzledAccept:)];
	[NSClassFromString(@"OakSelectBundleItem") swizzleInstanceMethod:@selector(showKeyEquivalent:withResults:) withMethod:@selector(swizzledShowKeyEquivalent:withResults:)];
	[NSClassFromString(@"OakSelectBundleItem") swizzleInstanceMethod:@selector(search:) withMethod:@selector(swizzledSearch:)];

	return self;
}
@end

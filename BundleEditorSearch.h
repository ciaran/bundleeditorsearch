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


// These are taken from a class-dump of TextMate
// (we need them so we can access instance variables)
@interface OakTableViewController : NSWindowController
{
    NSTableView *tableView;
}

- (void)moveUp:(id)fp8;
- (void)moveDown:(id)fp8;
- (void)movePageUp:(id)fp8;
- (void)movePageDown:(id)fp8;
- (void)pageUp:(id)fp8;
- (void)pageDown:(id)fp8;
- (void)scrollPageUp:(id)fp8;
- (void)scrollPageDown:(id)fp8;
- (void)moveToBeginningOfDocument:(id)fp8;
- (void)moveToEndOfDocument:(id)fp8;

@end

@interface OakSelectBundleItem : OakTableViewController
{
@public
    NSSearchField *filterStringTextField;
    NSTableColumn *bundleItemsTableColumn;
    NSMenu *filterCriteriaMenu;
    NSString *filterString;
    NSString *scope;
    NSArray *bundleItems;
    BOOL isSearchingKeyEquivalents;
}

- (void)windowDidLoad;
- (void)setSearchCriterion:(id)fp8;
- (id)shouldInterceptKeyEquvalent:(id)fp8;
- (void)showKeyEquivalent:(id)fp8 withResults:(id)fp12;
- (BOOL)validateMenuItem:(id)fp8;
- (void)refresh;
- (void)search:(id)fp8;
- (void)setScope:(id)fp8;
- (void)accept:(id)fp8;
- (void)cancel:(id)fp8;
- (int)numberOfRowsInTableView:(id)fp8;
- (void)tableView:(id)fp8 willDisplayCell:(id)fp12 forTableColumn:(id)fp16 row:(int)fp20;
- (id)tableView:(id)fp8 objectValueForTableColumn:(id)fp12 row:(int)fp16;

@end

@interface OakBundleEditor : NSObject
{
@public
    NSPanel *bundleEditorPanel;
    NSSplitView *mainSplitView;
    id outlineView;
    NSTextField *boxTitle;
    NSBox *editorBox;
    id keyEquivalentField;
    NSMenu *bundleFilterMenu;
    NSPanel *bundleListEditorSheet;
    NSTableView *bundleListEditorTableView;
    NSView *snippetEditor;
    NSView *commandEditor;
    NSView *dragCommandEditor;
    NSView *macroEditor;
    NSView *languageEditor;
    NSTextView *languageTextView;
    NSView *preferenceEditor;
    NSTextView *preferenceTextView;
    NSView *templateEditor;
    NSView *templateFileEditor;
    NSTextView *templateFileTextView;
    id splitView;
    NSView *noSelection;
    NSImageView *imageView;
    NSOutlineView *menuStructureOutlineview;
    NSTableView *excludedMenuItemsTableView;
    NSView *bundlePropertiesEditor;
    id bundlePropertiesEditorDelegate;
    NSArray *cachedBundles;
    NSMutableDictionary *cachedBundleItems;
    NSUndoManager *undoManager;
    NSString *bundleFilter;
    id selection;
    BOOL canAddBundleItem;
    BOOL canDuplicateBundleItem;
    BOOL canRemoveBundleItem;
    BOOL updateLanguages;
    BOOL updatePreferences;
    NSDate *animationStart;
    NSTimer *animationTimer;
    BOOL pendingShowOutputPatternOptions;
    BOOL showOutputPatternOptions;
    NSMutableArray *editors;
    NSMutableArray *allBundles;
}

+ (id)sharedInstance;
+ (void)initialize;
- (id)windowWillReturnUndoManager:(id)fp8;
- (id)init;
- (void)dealloc;
- (BOOL)validateMenuItem:(id)fp8;
- (void)undo:(id)fp8;
- (void)redo:(id)fp8;
- (void)setFilterLabels;
- (BOOL)loadNib;
- (void)bundlesDidChange:(id)fp8;
- (void)orderFrontBundleEditor:(id)fp8;
- (void)showItem:(id)fp8;
- (id)windowWillReturnFieldEditor:(id)fp8 toObject:(id)fp12;
- (void)outlineView:(id)fp8 willDisplayCell:(id)fp12 forTableColumn:(id)fp16 item:(id)fp20;
- (int)outlineView:(id)fp8 numberOfChildrenOfItem:(id)fp12;
- (id)outlineView:(id)fp8 child:(int)fp12 ofItem:(id)fp16;
- (BOOL)outlineView:(id)fp8 isItemExpandable:(id)fp12;
- (id)outlineView:(id)fp8 objectValueForTableColumn:(id)fp12 byItem:(id)fp16;
- (void)reloadOutlineView:(id)fp8;
- (void)outlineView:(id)fp8 setObjectValue:(id)fp12 forTableColumn:(id)fp16 byItem:(id)fp20;
- (BOOL)outlineView:(id)fp8 writeItems:(id)fp12 toPasteboard:(id)fp16;
- (id)outlineView:(id)fp8 namesOfPromisedFilesDroppedAtDestination:(id)fp12 forDraggedItems:(id)fp16;
- (unsigned int)outlineView:(id)fp8 validateDrop:(id)fp12 proposedItem:(id)fp16 proposedChildIndex:(int)fp20;
- (BOOL)outlineView:(id)fp8 acceptDrop:(id)fp12 item:(id)fp16 childIndex:(int)fp20;
- (BOOL)commitEditing;
- (void)outlineViewSelectionDidChange:(id)fp8;
- (void)reloadOutlineView;
- (void)setBundleFilter:(id)fp8;
- (void)animationTick:(id)fp8;
- (BOOL)showPatternOptions;
- (void)setShowPatternOptions:(BOOL)fp8;
- (float)splitView:(id)fp8 constrainMinCoordinate:(float)fp12 ofSubviewAt:(int)fp16;
- (float)splitView:(id)fp8 constrainMaxCoordinate:(float)fp12 ofSubviewAt:(int)fp16;
- (void)splitView:(id)fp8 resizeSubviewsWithOldSize:(struct _NSSize)fp12;
- (void)editBundleList:(id)fp8;
- (void)orderOutBundleList:(id)fp8;
- (int)numberOfRowsInTableView:(id)fp8;
- (id)tableView:(id)fp8 objectValueForTableColumn:(id)fp12 row:(int)fp16;
- (void)tableView:(id)fp8 setObjectValue:(id)fp12 forTableColumn:(id)fp16 row:(int)fp20;
- (void)testTemplate:(id)fp8;
- (void)newItem:(id)fp8;
- (void)newCommand:(id)fp8;
- (void)newDragCommand:(id)fp8;
- (void)newLanguage:(id)fp8;
- (void)newSnippet:(id)fp8;
- (void)newTemplate:(id)fp8;
- (void)newTemplateFile:(id)fp8;
- (void)newPreference:(id)fp8;
- (void)newBundle:(id)fp8;
- (void)duplicateItem:(id)fp8;
- (void)removeItem:(id)fp8;
- (void)objectDidBeginEditing:(id)fp8;
- (void)objectDidEndEditing:(id)fp8;
- (BOOL)windowShouldClose:(id)fp8;
- (void)windowWillClose:(id)fp8;
- (void)testLanguage:(id)fp8;
- (void)selectCurrentMode;
- (void)orderFrontAndShow:(id)fp8;
- (void)showHelpForCommands:(id)fp8;
- (void)showHelpForDragCommands:(id)fp8;
- (void)showHelpForLanguageGrammars:(id)fp8;
- (void)showHelpForPreferences:(id)fp8;
- (void)showHelpForSnippets:(id)fp8;
- (void)showHelpForTemplates:(id)fp8;
- (void)showHelpForMoreBundles:(id)fp8;

@end

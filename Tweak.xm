#import <objc/runtime.h>

#define kTweakName @"Docker"
#ifdef DEBUG
	#define NSLog(FORMAT, ...) NSLog(@"[%@: %s - %i] %@", kTweakName, __FILE__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])
#else
	#define NSLog(FORMAT, ...) do {} while(0)
#endif

@interface _UIBackdropViewSettings : NSObject
+(id)settingsForStyle:(NSInteger)style graphicsQuality:(NSInteger)quality;
@end
@interface _UIBackdropView : UIView
-(id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)autoresizes settings:(_UIBackdropViewSettings*)settings;
@end
@interface SBDockView : UIView
+(CGFloat)defaultHeight;
@end
@interface SBIconImageView : UIView
+(CGFloat)cornerRadius;
@end
@interface SBIcon : NSObject
@property (nonatomic, retain) NSString* applicationBundleID;
@end
@interface SBIconView : UIView {
	UIView* _iconImageView;
}
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) SBIcon* icon;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) CGRect iconImageFrame;
-(BOOL)isInDock;
//iOS 8
-(id)initWithDefaultSize;
//iOS 9 
-(id)initWithContentType:(int)type;
-(void)_setIcon:(SBIcon*)icon animated:(BOOL)animated;
@end
@interface SBFolderIconView : SBIconView
@end
@interface SBIconViewMap : NSObject
+(id)homescreenMap;
-(SBIconView*)mappedIconViewForIcon:(SBIcon*)icon;
@end
@interface SBIconModel : NSObject
@property (nonatomic, retain) NSArray* icons;
-(SBIcon*)expectedIconForDisplayIdentifier:(NSString*)identifier;
-(NSArray*)leafIcons;
@end
@interface SBIconListView : UIView
@property (nonatomic, retain) SBIconModel* model;
-(void)enumerateIconViewsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
-(NSInteger)indexOfIcon:(SBIcon*)arg1;
-(void)setNeedsLayout;
-(void)layoutIconsIfNeeded:(NSInteger)duration domino:(BOOL)domino;
@end
@interface SBDockListView : SBIconListView
@end
@interface SBIconListPageControl : UIPageControl
@end
@interface SBFolderView : UIView {
	SBIconListPageControl* _pageControl;
}
@end
@interface SBFolderController : NSObject
@property (nonatomic,readonly) NSArray * iconListViews; 
@property (nonatomic,retain,readonly) SBFolderView* contentView;
@end
@interface SBFolder : NSObject
@end
@interface SBIconController : NSObject
+(id)sharedInstance;
@property (nonatomic, retain) SBIconModel* model;
@property (nonatomic, assign) BOOL isEditing;
-(SBIconListView*)currentRootIconList;
-(SBDockListView*)dockListView;
-(SBFolderController*)_rootFolderController;
-(void)clearHighlightedIcon;
-(NSInteger)currentIconListIndex;
-(void)removeIcon:(id)arg1 compactFolder:(BOOL)arg2;
-(id)insertIcon:(id)arg1 intoListView:(id)arg2 iconIndex:(long long)arg3 moveNow:(BOOL)arg4 pop:(BOOL)arg5;
-(SBFolder*)rootFolder;
-(SBIconListView*)iconListViewAtIndex:(NSInteger)index inFolder:(SBFolder*)folder createIfNecessary:(BOOL)create;
-(BOOL)scrollToIconListAtIndex:(long long)arg1 animate:(BOOL)arg2;
-(NSArray*)allApplications;
@end

@interface NSIndexPath (SBIconIndex)
- (NSInteger)sbListIndex;
- (NSInteger)sbIconIndex;
@end

@interface SBDockView (Docker)
@property (nonatomic, assign, setter=docker_setStartingFrame:) CGRect docker_startingFrame;
@property (nonatomic, assign, setter=docker_setPreviousFrame:) CGRect docker_previousFrame;
@property (nonatomic, assign, setter=docker_setExtraIconViews:) NSArray* docker_extraIconViews;
@property (nonatomic, assign, readonly) CGRect docker_originalFrame;
@property (nonatomic, assign, readonly) CGRect docker_expandedFrame;
-(void)docker_handlePan:(UIPanGestureRecognizer*)panGesture;
-(NSArray*)docker_originalIconViews;
-(CGFloat)docker_originalIconOriginY;
-(void)docker_shakeExtraIconViews;
-(void)docker_stopShakingExtraIconViews;
-(void)docker_expandDock;
-(void)docker_collapseDock;
-(void)docker_addPanGestureRecognizer;
-(void)docker_removePanGestureRecognizer;
@end
@interface SBIconController (Docker)
@property (nonatomic, assign, setter=docker_setIsSelectingApp:) BOOL docker_isSelectingApp;
-(void)docker_beginAddApp;
-(void)docker_endAddApp;
-(SBIconView*)docker_sampleIconView;
@end
@interface SBIconView (Docker)
@property (nonatomic, assign, setter=docker_setIsShaking:) BOOL docker_isShaking;
-(void)docker__shakeBegin;
-(void)docker__shakeEnd;
@end
@interface UIApplication (Docker)
-(BOOL)launchApplicationWithIdentifier:(NSString*)ident suspended:(BOOL)suspended;
@end

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define kSerializedBundleIdentifiersPath @"/var/mobile/Library/Preferences/com.phillip.docker~icons.plist"
#define kSerializedPositionsPath 		 @"/var/mobile/Library/Preferences/com.phillip.docker~positions.plist"
#define kAddButtonImagePath 			 @"/Library/Application Support/Docker/add.png"
#define kRemoveButtonImagePath 			 @"/Library/Application Support/Docker/remove.png"
#define kStatusBarHeight 		20
#define kSelectLabelTag 		133742069
#define kGeneralDockerViewTag 	19980918
#define kRemoveButtonImageTag	9111337

static CGFloat originalIconOriginY;

SBIconView* iconViewForIcon(SBIcon* icon) {
	SBIconViewMap *iconMap = [%c(SBIconViewMap) homescreenMap];
	return [iconMap mappedIconViewForIcon:icon];
}
SBIconView* newIconViewForIcon(SBIcon* icon) {
	SBIconView* iconView = nil;
	if ([iconView respondsToSelector:@selector(initWithDefaultSize)]) {
		iconView = [[%c(SBIconView) alloc] initWithDefaultSize];
	}
	else {
		iconView = [[%c(SBIconView) alloc] initWithContentType:0];
	}

	[iconView _setIcon:icon animated:YES];
	iconView.delegate = [%c(SBIconController) sharedInstance];
	return iconView;
}

@interface DCRAddAppButton : UIButton
-(id)initWithDefaultSize;
@end
@implementation DCRAddAppButton 
-(id)initWithDefaultSize {
	CGRect sampleIconViewFrame = [[%c(SBIconController) sharedInstance] docker_sampleIconView].frame;
	CGRect adjustedFrame = CGRectMake(0, 0, sampleIconViewFrame.size.width*0.8, sampleIconViewFrame.size.width*0.8);
	NSLog(@"sampleIconViewFrame: %@", NSStringFromCGRect(sampleIconViewFrame));
	NSLog(@"adjustedFrame: %@", NSStringFromCGRect(adjustedFrame));
	if ((self = [super initWithFrame:adjustedFrame])) {
		UIImage* addIcon = [UIImage imageWithContentsOfFile:kAddButtonImagePath];
		[self setImage:addIcon forState:UIControlStateNormal];

		[self addTarget:[%c(SBIconController) sharedInstance] action:@selector(docker_beginAddApp) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}
@end

%hook SBDockView
-(id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2 {
	if ((self = %orig)) {
		[self docker_addPanGestureRecognizer];
	}
	return self;
}
-(void)setFrame:(CGRect)frame {
	CGRect previousFrame = self.frame;
	if (!CGRectEqualToRect(previousFrame, CGRectZero)) self.docker_previousFrame = previousFrame;

	//adjust the docks frame so it doesn't show wallpaper off the bottom of the screen
	//CGFloat frameDifference = frame.size.height - self.docker_startingFrame.size.height;
	//NSLog(@"frameDifference: %f", frameDifference);
	//NSLog(@"BEFOR frame: %@", NSStringFromCGRect(frame));
	//frame.size.height += frameDifference;
	//NSLog(@"AFTER frame: %@", NSStringFromCGRect(frame));
	//frame.origin.y -= frameDifference;

	%orig;

	//move up every icon view up by the change in frame
	CGFloat difference = previousFrame.origin.y - frame.origin.y;
	NSArray* iconListViews = [[%c(SBIconController) sharedInstance] _rootFolderController].iconListViews;
	for (SBIconListView* iconListView in iconListViews) {
		CGRect adjustedFrame = iconListView.frame;
		adjustedFrame.origin.y -= difference;
		iconListView.frame = adjustedFrame;
	}

	//move the page control by the change in frame
	SBFolderView* folderView = [[%c(SBIconController) sharedInstance] _rootFolderController].contentView;
	NSLog(@"folderView: %@", folderView);
	if (!folderView) return;
	SBIconListPageControl* pageControl = MSHookIvar<SBIconListPageControl*>(folderView, "_pageControl");
	NSLog(@"page control: %@", pageControl);
	CGRect adjustedFrame = pageControl.frame;
	adjustedFrame.origin.y -= difference;	
	pageControl.frame = adjustedFrame;
}
%new
-(void)docker_expandDock {
	//set frame to expanded frame
	CGFloat longestPossibleAnimationDuration = 0.4;
	CGFloat closenessFactor = (self.docker_originalFrame.size.height*1.5) / self.frame.size.height;
	CGFloat adjustedAnimationDuration = longestPossibleAnimationDuration * closenessFactor;
	[UIView animateWithDuration:adjustedAnimationDuration delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		self.frame = self.docker_expandedFrame;
	} completion:nil];
}
%new 
-(void)docker_collapseDock {
	//set frame to collapsed frame
	CGFloat longestPossibleAnimationDuration = 0.45;
	CGFloat closenessFactor = self.frame.size.height / (self.docker_originalFrame.size.height*1.5);
	CGFloat adjustedAnimationDuration = longestPossibleAnimationDuration * closenessFactor;
	[UIView animateWithDuration:adjustedAnimationDuration delay:0.0 usingSpringWithDamping:0.525 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		self.frame = self.docker_originalFrame;
	} completion:nil];
}
%new
-(void)docker_handlePan:(UIPanGestureRecognizer*)panGesture {

	if (panGesture.state == UIGestureRecognizerStateBegan) {
		[[%c(SBIconController) sharedInstance] docker_endAddApp];

		[self docker_stopShakingExtraIconViews];

		self.docker_startingFrame = self.frame;

		if (originalIconOriginY == 0) originalIconOriginY = [self docker_originalIconOriginY];
		NSLog(@"originalIconOriginY: %f", originalIconOriginY);
	}
	else if (panGesture.state == UIGestureRecognizerStateChanged) {
		CGFloat adjustedTranslation = [panGesture translationInView:self].y;
		NSLog(@"adjustedTranslation: %f", adjustedTranslation);
		CGRect newFrame = self.docker_startingFrame;

		CGFloat totalScreenHeight = [UIScreen mainScreen].bounds.size.height;
		CGFloat projectedDockHeight = totalScreenHeight - (newFrame.origin.y + adjustedTranslation);
		CGFloat maximumFinalDockHeight = totalScreenHeight - (self.docker_expandedFrame.origin.y);
		if (projectedDockHeight > maximumFinalDockHeight) {
			//make the dock move exponentially less
			adjustedTranslation = adjustedTranslation * (maximumFinalDockHeight / projectedDockHeight);
		}

		newFrame.size.height -= adjustedTranslation;
		newFrame.origin.y += adjustedTranslation;
		if (newFrame.size.height < self.docker_originalFrame.size.height) {
			newFrame = self.docker_originalFrame;
		}
		self.frame = newFrame;
	
		//adjust the extra icon views to grow
		for (UIView* view in self.docker_extraIconViews) {
			CGFloat oldMin = self.docker_originalFrame.size.height;
			//we use a height slightly larger than the actual 'max' size since we support dragging past the max value
			CGFloat oldMax = self.docker_expandedFrame.size.height*1.4;
			CGFloat newMin = 0.13;
			CGFloat newMax = 1.3;

			//TODO if this view will intersect with other views, set it to the original transform

			CGFloat actualValue = self.frame.size.height;
			CGFloat mappedTransformValue = (((actualValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin;
			//extra check to make sure it isn't too big
			if (mappedTransformValue > 1.2) mappedTransformValue = 1.2;
			view.transform = CGAffineTransformScale(CGAffineTransformIdentity, mappedTransformValue, mappedTransformValue);
		}
	}
	else {
		//spring back to proper frame
		if (self.frame.size.height > self.docker_expandedFrame.size.height) {
			NSLog(@"Springing back to proper expanded frame");

			[UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.45 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
				self.frame = self.docker_expandedFrame;
			} completion:nil];
		}
		else {
			//decide whether to reclose or expand
			//the original frame * 1.5 is half of the expanded height
			if (self.frame.size.height > self.docker_originalFrame.size.height*1.5) {
				[self docker_expandDock];
			}
			else {
				[self docker_collapseDock];
			}
		}

		//set the extra icon views to their proper size
		for (UIView* view in self.docker_extraIconViews) {
			[UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
				view.transform = CGAffineTransformIdentity;
			} completion:nil];
		}
	}
}
%new
-(void)docker_setStartingFrame:(CGRect)orig {
	 objc_setAssociatedObject(self, @selector(docker_startingFrame), [NSValue valueWithCGRect:orig], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
-(CGRect)docker_startingFrame {
	return [(NSValue*)objc_getAssociatedObject(self, @selector(docker_startingFrame)) CGRectValue];
}
%new
-(void)docker_setPreviousFrame:(CGRect)orig {
	 objc_setAssociatedObject(self, @selector(docker_previousFrame), [NSValue valueWithCGRect:orig], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
-(CGRect)docker_previousFrame {
	return [(NSValue*)objc_getAssociatedObject(self, @selector(docker_previousFrame)) CGRectValue];
}
%new
-(void)docker_setExtraIconViews:(NSArray*)buttons {
	objc_setAssociatedObject(self, @selector(docker_extraIconViews), buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
-(NSArray*)docker_extraIconViews {
	//if the iconButtons already exist, return them
	id iconButtons = objc_getAssociatedObject(self, @selector(docker_extraIconViews));
	if (iconButtons) return iconButtons;

	//else, create them

	//Array of already placed bundle identifiers (which we turn into SBIconViews)
	NSArray* inUseBundleIdentifiers = [[NSArray alloc] initWithContentsOfFile:kSerializedBundleIdentifiersPath];
	NSLog(@"inUseBundleIdentifiers: %@", inUseBundleIdentifiers);

	NSMutableArray* addIconButtons = [[NSMutableArray alloc] init];
	NSArray* originalIconViews = self.docker_originalIconViews;
	if (!originalIconViews || originalIconViews.count == 0) return nil;
	for (int i = 0; i < originalIconViews.count; i++) {
		if (i+1 <= inUseBundleIdentifiers.count && inUseBundleIdentifiers[i]) {
			//the user already has an app for this placement
			SBIconModel* model = ((SBIconController*)[%c(SBIconController) sharedInstance]).model;

			SBIcon* icon = [model expectedIconForDisplayIdentifier:inUseBundleIdentifiers[i]];
			SBIconView* iconView = newIconViewForIcon(icon);
			NSLog(@"icon: %@", icon);
			NSLog(@"iconView: %@", iconView);
			CGRect adjustedFrame = ((UIView*)originalIconViews[i]).frame;
			adjustedFrame.origin.y += self.docker_originalFrame.size.height;
			iconView.frame = adjustedFrame;

			//add shake recognizer to button
			UILongPressGestureRecognizer* holdRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(docker_shakeExtraIconViews)];
			[iconView addGestureRecognizer:holdRecognizer];

			//for removal later
			iconView.tag = kGeneralDockerViewTag;

			[addIconButtons addObject:iconView];
		}
		else {
			//the user does not have an app for this placement
			
			DCRAddAppButton* addAppButton = [[DCRAddAppButton alloc] initWithDefaultSize];

			//if this is not the first one, lower the opacity
			if (!(i == inUseBundleIdentifiers.count)) {
				addAppButton.alpha = 0.5;
			}

			SBIconView* mappedView = originalIconViews[i];
			CGRect mappedFrame = mappedView.frame;
			//move it down the height of the dock so it's on the second row
			mappedFrame.origin.y += self.docker_originalFrame.size.height;

			//center the app by subtracting label height of the icon view
			//CGFloat labelHeight = mappedView.frame.size.height - mappedView.iconImageFrame.size.height;
			//mappedFrame.origin.y -= labelHeight;

			//addAppButton.frame = CGRectMake(mappedFrame.origin.x, mappedFrame.origin.y, addAppButton.frame.size.width, addAppButton.frame.size.height);

			addAppButton.center = CGPointMake(mappedView.center.x, mappedView.center.y + self.docker_originalFrame.size.height);

			//for removal later 
			addAppButton.tag = kGeneralDockerViewTag;
			
			[addIconButtons addObject:addAppButton];
		}
	}
	[self docker_setExtraIconViews:addIconButtons];
	return [self docker_extraIconViews];
	//return addIconButtons;
}
%new
-(void)docker_shakeExtraIconViews {
	NSMutableArray* affectedViews = [[NSMutableArray alloc] initWithArray:self.docker_extraIconViews];
	for (id view in self.docker_extraIconViews) {
		if ([view isKindOfClass:%c(DCRAddAppButton)]) {
			[affectedViews removeObject:view];
		}
	}

	for (SBIconView* iconView in affectedViews) {
		iconView.docker_isShaking = YES;
	}
}
%new
-(void)docker_stopShakingExtraIconViews {
	NSMutableArray* affectedViews = [[NSMutableArray alloc] initWithArray:self.docker_extraIconViews];
	for (id view in self.docker_extraIconViews) {
		if ([view isKindOfClass:%c(DCRAddAppButton)]) {
			[affectedViews removeObject:view];
		}
	}

	for (SBIconView* iconView in affectedViews) {
		iconView.docker_isShaking = NO;
	}
}
%new
-(CGRect)docker_originalFrame {
	return CGRectMake(0, [UIScreen mainScreen].bounds.size.height - [self.class defaultHeight], [UIScreen mainScreen].bounds.size.width, [self.class defaultHeight]);
}
%new
-(CGRect)docker_expandedFrame {
	CGRect originalFrame = self.docker_originalFrame;
	return CGRectMake(0, originalFrame.origin.y - originalFrame.size.height, originalFrame.size.width, originalFrame.size.height*2);
}
%new
-(NSArray*)docker_originalIconViews {
	SBIconListView* iconListView = MSHookIvar<SBIconListView*>(self, "_iconListView");
	SBIconModel* model = [iconListView model];

	NSMutableArray* iconViews = [[NSMutableArray alloc] init];
	for (SBIcon* icon in model.icons) {
		[iconViews addObject:iconViewForIcon(icon)];
	}
	return iconViews;
}
%new
-(CGFloat)docker_originalIconOriginY {
	SBIconView* sampleIconView = [[self docker_originalIconViews] objectAtIndex:0];
	CGRect adjustedFrame = [sampleIconView.superview convertRect:sampleIconView.frame toView:[[UIApplication sharedApplication] keyWindow]];
	return adjustedFrame.origin.y;
}
%new
-(void)docker_removeIconViewFromRecognizer:(UIGestureRecognizer*)rec {
	%log;
	SBIconView* iconView = (SBIconView*)rec.view;

	//first, stop icons from shaking
/*
	for (SBIconView* shakingIconView in self.docker_extraIconViews) {
		if (![shakingIconView isKindOfClass:%c(DCRAddAppButton)]) {
			shakingIconView.docker_isShaking = NO;
		}
	}
*/

	//then, remove this icon from the array

	//load existing array into mem
	NSMutableArray* newInUseBundleIdentifiers = [[NSMutableArray alloc] initWithContentsOfFile:kSerializedBundleIdentifiersPath];
	//if array doesn't exist, create it
	if (!newInUseBundleIdentifiers) {
		newInUseBundleIdentifiers = [[NSMutableArray alloc] init];
	}
	NSLog(@"newInUseBundleIdentifiers: %@", newInUseBundleIdentifiers);
	NSString* tappedAppIdentifier = iconView.icon.applicationBundleID;
	NSLog(@"tappedAppIdentifier: %@", tappedAppIdentifier);
	NSInteger indexInDictionaryForIconReplacement = NSNotFound;
	if ([newInUseBundleIdentifiers containsObject:tappedAppIdentifier]) {
		indexInDictionaryForIconReplacement = [newInUseBundleIdentifiers indexOfObject:tappedAppIdentifier];
		[newInUseBundleIdentifiers removeObject:tappedAppIdentifier];
	}

	//rewrite the new array back to the disk plist
	[newInUseBundleIdentifiers writeToFile:kSerializedBundleIdentifiersPath atomically:YES];

	//remove the existing (old) views
	for (UIView* view in self.docker_extraIconViews) {
		[view removeFromSuperview];
	}

	//force the extra views to be recreated next time they're accessed
	self.docker_extraIconViews = nil;

	//force the views to be re-added
	for (UIView* view in self.docker_extraIconViews) {
		[self addSubview:view];
	}

	//begin shaking again
	[self docker_shakeExtraIconViews];

	//we assume the index of the icon in the above array will be the correct position
	//this is a bad assumption and i should feel bad
	//to be a little safer, if it wasn't found, quit
	if (indexInDictionaryForIconReplacement == NSNotFound) {
		NSLog(@"indexInDictionaryForIconReplacement was %i, quitting", (int)indexInDictionaryForIconReplacement);
		return;
	}

	//get info about this icon placement
	NSMutableDictionary* newPositionsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:kSerializedPositionsPath];
	//if the dict doesn't exist, create it
	if (!newPositionsDictionary) {
		newPositionsDictionary = [[NSMutableDictionary alloc] initWithObjects:@[@[], @[]] forKeys:@[@"listViewIndexes", @"iconIndexes"]];
	}
	NSLog(@"newPositionsDictionary: %@", newPositionsDictionary);
	NSMutableArray* listViewIndexes = [NSMutableArray arrayWithArray:(NSArray*)[newPositionsDictionary objectForKey:@"listViewIndexes"]];
	NSMutableArray* iconIndexes = [NSMutableArray arrayWithArray:(NSArray*)[newPositionsDictionary objectForKey:@"iconIndexes"]];

	NSLog(@"indexInDictionaryForIconReplacement: %i", (int)indexInDictionaryForIconReplacement);

	NSNumber* listViewIndex = (NSNumber*)[listViewIndexes objectAtIndex:indexInDictionaryForIconReplacement];
	NSNumber* iconIndex = (NSNumber*)[iconIndexes objectAtIndex:indexInDictionaryForIconReplacement];

	NSLog(@"listViewIndex: %@", listViewIndex);
	NSLog(@"iconIndex: %@", iconIndex);

	[listViewIndexes removeObjectAtIndex:indexInDictionaryForIconReplacement];
	[iconIndexes removeObjectAtIndex:indexInDictionaryForIconReplacement];

	//set these back to the array
	[newPositionsDictionary setObject:listViewIndexes forKey:@"listViewIndexes"];
	[newPositionsDictionary setObject:iconIndexes forKey:@"iconIndexes"];

	//write the new dict back to disk
	[newPositionsDictionary writeToFile:kSerializedPositionsPath atomically:YES];

	//now that we've figured out the proper positioning, place the icon view again
	//scroll to the icon list view
	[[%c(SBIconController) sharedInstance] scrollToIconListAtIndex:listViewIndex.intValue animate:YES];

	//wait for scrolling to finish
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		//insert icon
		[[%c(SBIconController) sharedInstance] insertIcon:iconView.icon intoListView:[[%c(SBIconController) sharedInstance] iconListViewAtIndex:listViewIndex.intValue inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:NO] iconIndex:iconIndex.intValue moveNow:YES pop:YES];
	});
}
%new
-(UIPanGestureRecognizer*)docker__associatedGestureRecognizer {
	UIPanGestureRecognizer* panRec = objc_getAssociatedObject(self, _cmd);
	//if the pan rec. hasn't been created yet, create it
	if (!panRec) {
		panRec =  [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(docker_handlePan:)];
		objc_setAssociatedObject(self, _cmd, panRec, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return panRec;
}
%new
-(void)docker_addPanGestureRecognizer {
	UIPanGestureRecognizer* panGesture = [self performSelector:@selector(docker__associatedGestureRecognizer)];
	//add the recognizer to the dock view
	[self addGestureRecognizer:panGesture];
}
%new
-(void)docker_removePanGestureRecognizer {
	//retreive gesture recognizer
	UIPanGestureRecognizer* panGesture = [self performSelector:@selector(docker__associatedGestureRecognizer)];
	//remove recognizer from dock view
	[self removeGestureRecognizer:panGesture];
}
%end

%hook SBIconView
%new
-(void)docker__shakeBegin {
	//if we're already shaking, quit
	if (self.docker_isShaking) return;

	SBIconImageView* iconView = MSHookIvar<SBIconImageView*>(self, "_iconImageView");
	//add 'X' blur and image
	_UIBackdropView *blurView = [[_UIBackdropView alloc] initWithFrame:CGRectMake(0, 0, iconView.frame.size.width*0.75, iconView.frame.size.height*0.75) autosizesToFitSuperview:NO settings:[_UIBackdropViewSettings settingsForStyle:2070 graphicsQuality:100]];
	iconView.layer.masksToBounds = YES;
	blurView.layer.masksToBounds = YES;
	blurView.layer.allowsEdgeAntialiasing = YES;
	blurView.layer.cornerRadius = blurView.frame.size.width/2;
	blurView.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor;
	blurView.layer.borderWidth = 1.0;
	blurView.tag = kRemoveButtonImageTag;
	blurView.alpha = 0.0;
	
	UIImageView* xImage = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:kRemoveButtonImagePath]];
	xImage.frame = CGRectMake(0, 0, blurView.frame.size.width*0.5, blurView.frame.size.height*0.5);
	xImage.layer.allowsEdgeAntialiasing = YES;
	xImage.layer.masksToBounds = YES;
	[blurView addSubview:xImage];

	[iconView addSubview:blurView];
	blurView.center = CGPointMake(iconView.center.x + 1, iconView.center.y + 1);

	[UIView animateWithDuration:0.25 animations:^{
		blurView.alpha = 1.0;
	}];

	self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-5));
	[UIView animateWithDuration:0.1 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^ {
		self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(5));
		blurView.transform = self.transform;
	} completion:nil];

	//add double tap to remove
	SBDockView* dockView = (SBDockView*)([[%c(SBIconController) sharedInstance] dockListView].superview);

	UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:dockView action:@selector(docker_removeIconViewFromRecognizer:)];
	[self addGestureRecognizer:tapRec];
}
%new
-(void)docker__shakeEnd {
	//if we weren't already shaking, quit
	if (!self.docker_isShaking) return;

	//find and remove tap gesture recognizer
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		if ([recognizer isKindOfClass:UITapGestureRecognizer.class]) {
			[self removeGestureRecognizer:recognizer];
			NSLog(@"found tap recognizer, removing");
		}
	}

	//remove 'x' image
	UIView* iconView = MSHookIvar<UIView*>(self, "_iconImageView");
	UIView* blurView = [iconView viewWithTag:kRemoveButtonImageTag];

	[UIView animateWithDuration:0.1 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear) animations:^{
	   self.transform = CGAffineTransformIdentity;
	   blurView.transform = self.transform;

	   blurView.alpha = 0.0;
	} completion:^(BOOL finished){
		[blurView removeFromSuperview];
	}];
}
%new
-(void)docker_setIsShaking:(BOOL)shaking {
	if (shaking) {
		[self docker__shakeBegin];
	}
	else [self docker__shakeEnd];

	objc_setAssociatedObject(self, @selector(docker_isShaking), [NSNumber numberWithBool:shaking], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
-(BOOL)docker_isShaking {
	return [(NSNumber*)objc_getAssociatedObject(self, @selector(docker_isShaking)) boolValue];
}
%end

%hook SBIconController
-(void)iconTapped:(SBIconView*)iconView {
	SBDockView* dockView = (SBDockView*)([self dockListView].superview);

	if (iconView.docker_isShaking) {
		NSLog(@"single tapped shaking icon");
		//just undim it, don't do anything special

		//undim icon
		[iconView setHighlighted:NO];
		NSLog(@"clearHighlightedIcon: %@", MSHookIvar<SBIcon*>(self, "_highlightedIcon"));
		[self clearHighlightedIcon];

		//don't stop shaking
		return;
	}

	[dockView docker_stopShakingExtraIconViews];

	if (self.docker_isSelectingApp && ![iconView isKindOfClass:%c(SBFolderIconView)]) {
		//undim icon
		[iconView setHighlighted:NO];
		NSLog(@"clearHighlightedIcon: %@", MSHookIvar<SBIcon*>(self, "_highlightedIcon"));
		[self clearHighlightedIcon];

		//get info about this app's position
		NSNumber* iconListViewIndex = [NSNumber numberWithInt:[[%c(SBIconController) sharedInstance] currentIconListIndex]];
		NSInteger iconIndexInt = [[[%c(SBIconController) sharedInstance] currentRootIconList] indexOfIcon:iconView.icon];
		//the above method returns NSNotFound if the icon is not on the current page
		//if it does, just use 0 as this is non-critical code
		if (iconIndexInt == NSNotFound) iconIndexInt = 0;
		NSNumber* iconIndex = [NSNumber numberWithInt:iconIndexInt];

		NSLog(@"iconListViewIndex: %@", iconListViewIndex);
		NSLog(@"iconIndex: %@", iconIndex);

		//write info about this to our dict
		NSMutableDictionary* newPositionsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:kSerializedPositionsPath];
		//if the dict doesn't exist, create it
		if (!newPositionsDictionary) {
			newPositionsDictionary = [[NSMutableDictionary alloc] initWithObjects:@[@[], @[]] forKeys:@[@"listViewIndexes", @"iconIndexes"]];
		}
		NSLog(@"newPositionsDictionary: %@", newPositionsDictionary);
		NSMutableArray* listViewIndexes = [NSMutableArray arrayWithArray:(NSArray*)[newPositionsDictionary objectForKey:@"listViewIndexes"]];
		NSMutableArray* iconIndexes = [NSMutableArray arrayWithArray:(NSArray*)[newPositionsDictionary objectForKey:@"iconIndexes"]];
		[listViewIndexes addObject:iconListViewIndex];
		[iconIndexes addObject:iconIndex];

		NSLog(@"listViewIndexes: %@", listViewIndexes);
		NSLog(@"iconIndexes: %@", iconIndexes);

		//set these back to the array
		[newPositionsDictionary setObject:listViewIndexes forKey:@"listViewIndexes"];
		[newPositionsDictionary setObject:iconIndexes forKey:@"iconIndexes"];

		//write the new dict back to disk
		[newPositionsDictionary writeToFile:kSerializedPositionsPath atomically:YES];

		//add this app to the array of extra apps

		//load existing array into mem
		NSMutableArray* newInUseBundleIdentifiers = [[NSMutableArray alloc] initWithContentsOfFile:kSerializedBundleIdentifiersPath];
		//if array doesn't exist, create it
		if (!newInUseBundleIdentifiers) {
			newInUseBundleIdentifiers = [[NSMutableArray alloc] init];
		}
		NSLog(@"newInUseBundleIdentifiers: %@", newInUseBundleIdentifiers);
		NSString* tappedAppIdentifier = iconView.icon.applicationBundleID;
		NSLog(@"iconView: %@", iconView);
		NSLog(@"icon: %@", iconView.icon);
		NSLog(@"tappedAppIdentifier: %@", tappedAppIdentifier);
		if (![newInUseBundleIdentifiers containsObject:tappedAppIdentifier]) {
			[newInUseBundleIdentifiers addObject:tappedAppIdentifier];
		}

		//rewrite the new array back to the disk plist
		[newInUseBundleIdentifiers writeToFile:kSerializedBundleIdentifiersPath atomically:YES];

		[self docker_endAddApp];

		//now that we've saved the positioning, remove the icon view
		[[%c(SBIconController) sharedInstance] removeIcon:iconView.icon compactFolder:YES];
	}

	else {
		if (self.docker_isSelectingApp) {
			[dockView docker_collapseDock];
		}
		else {
			dockView.frame = dockView.docker_originalFrame;
		}
		//if launching from a Docker app, force launch
		if ([dockView.docker_extraIconViews containsObject:iconView]) {
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:iconView.icon.applicationBundleID suspended:NO];
		}
		else %orig;
	}

	[iconView setHighlighted:NO];
}
-(void)setIsEditing:(BOOL)editing {
	%orig;

	SBDockView* dockView = (SBDockView*)([self dockListView].superview);
	//if editing, remove our recognizer so the user can drag around their icon views
	if (editing) {
		[dockView docker_removePanGestureRecognizer];
	}
	//else, re-add it
	else {
		[dockView docker_addPanGestureRecognizer];
	}

	for (UIView* view in dockView.docker_extraIconViews) {
		[dockView addSubview:view];
	}
}
%new
-(void)docker_endAddApp {
	//quit if we're not selecting an app
	if (!self.docker_isSelectingApp) return;

	SBDockView* dockView = (SBDockView*)([self dockListView].superview);

	//remove label
	UIView* selectLabel = [[[UIApplication sharedApplication] keyWindow] viewWithTag:kSelectLabelTag];
	[UIView animateWithDuration:0.1 animations:^{
		selectLabel.frame = CGRectMake(0, -dockView.frame.size.height, selectLabel.frame.size.width, selectLabel.frame.size.height);
	} completion:^(BOOL finished){
		[selectLabel removeFromSuperview];
	}];

	//move dock view back to original position
	[dockView docker_collapseDock];

	//remove the existing (old) views
	for (UIView* view in dockView.docker_extraIconViews) {
		[view removeFromSuperview];
	}

	//force the extra views to be recreated next time they're accessed
	dockView.docker_extraIconViews = nil;

	//force the views to be re-added
	for (UIView* view in dockView.docker_extraIconViews) {
		[dockView addSubview:view];
	}

	self.docker_isSelectingApp = NO;
}
%new
-(void)docker_beginAddApp {
	//if already selecting app, quit
	if (self.docker_isSelectingApp) return;

	//we are now selecting an app
	self.docker_isSelectingApp = YES;

	SBDockView* dockView = (SBDockView*)([self dockListView].superview);
	CGRect originalFrame = dockView.docker_originalFrame;

	//remove select label if its still there
	[[[[UIApplication sharedApplication] keyWindow] viewWithTag:kSelectLabelTag] removeFromSuperview];

	//if the label is already there, don't add it again
	if ([[[UIApplication sharedApplication] keyWindow] viewWithTag:kSelectLabelTag]) return;

	//set move dock off screen and move all icon list views down
	[UIView animateWithDuration:0.25 animations:^{
		dockView.frame = CGRectMake(originalFrame.origin.x, [UIScreen mainScreen].bounds.size.height, originalFrame.size.width, originalFrame.size.height);
	} completion:^(BOOL finished){
		//fade in label at top of screen
		UILabel* selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, originalFrame.size.width, originalFrame.size.height)];
		selectLabel.text = @"Select an App";
		selectLabel.textAlignment = NSTextAlignmentCenter;
		selectLabel.alpha = 0.0;
		selectLabel.tag = kSelectLabelTag;
		selectLabel.textColor = [UIColor whiteColor];
		selectLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
		[[[UIApplication sharedApplication] keyWindow] addSubview:selectLabel];
		[UIView animateWithDuration:0.25 animations:^{
			selectLabel.alpha = 1.0;
		}];
	}];
}

%new
-(void)docker_setIsSelectingApp:(BOOL)selecting {
	 objc_setAssociatedObject(self, @selector(docker_isSelectingApp), [NSNumber numberWithBool:selecting], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
-(BOOL)docker_isSelectingApp {
	return [(NSNumber*)objc_getAssociatedObject(self, @selector(docker_isSelectingApp)) boolValue];
}
%new
-(SBIconView*)docker_sampleIconView {
	SBIconModel* model = ((SBIconController*)[%c(SBIconController) sharedInstance]).model;
	NSArray* icons = model.leafIcons;
	for (SBIcon* icon in icons) {
		SBIconView* iconView = iconViewForIcon(icon);
		if (iconView && !(CGRectEqualToRect(iconView.frame, CGRectZero))) return iconView;
	}
	return nil;
}
%end

%hook SBUIController
-(BOOL)clickedMenuButton {
	[[%c(SBIconController) sharedInstance] docker_endAddApp];

	SBDockView* dockView = (SBDockView*)([[%c(SBIconController) sharedInstance] dockListView].superview);
	SBIconView* sampleIconView = dockView.docker_extraIconViews[0];

	//only do custom behavior if at homescreen
	if (![[UIApplication sharedApplication] performSelector:@selector(_accessibilityFrontMostApplication)]) {
		if ([sampleIconView isKindOfClass:%c(SBIconView)] && sampleIconView.docker_isShaking) {
			//stop shaking
			[dockView docker_stopShakingExtraIconViews];

			return YES;
		}
		//if dock is currently expanded
		else if (CGRectEqualToRect(dockView.frame, dockView.docker_expandedFrame)) {
			//collapse dock
			[dockView docker_collapseDock];

			return YES;
		}
		//if currently selecting app, stop selecting
		else if ([[%c(SBIconController) sharedInstance] docker_isSelectingApp]) {
			[[%c(SBIconController) sharedInstance] docker_endAddApp];

			return YES;
		}
	}

	return %orig;
}
- (BOOL)handleMenuDoubleTap {
	[[%c(SBIconController) sharedInstance] docker_endAddApp];

	return %orig;
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
	%orig;

	//remove all apps which are in the extra dock
	NSMutableArray* inUseBundleIdentifiers = [[NSMutableArray alloc] initWithContentsOfFile:kSerializedBundleIdentifiersPath];

	//get the icon list view index info
	NSMutableDictionary* positionsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:kSerializedPositionsPath];
	NSMutableArray* listViewIndexes = [NSMutableArray arrayWithArray:(NSArray*)[positionsDictionary objectForKey:@"listViewIndexes"]];

	for (NSString* ident in inUseBundleIdentifiers) {
		SBIconModel* model = ((SBIconController*)[%c(SBIconController) sharedInstance]).model;
		SBIcon* icon = [model expectedIconForDisplayIdentifier:ident];
		[[%c(SBIconController) sharedInstance] removeIcon:icon compactFolder:YES];

		SBIconListView* listView = [[%c(SBIconController) sharedInstance] iconListViewAtIndex:[(NSNumber*)listViewIndexes[[inUseBundleIdentifiers indexOfObject:ident]] intValue] inFolder:[%c(SBIconController) sharedInstance] createIfNecessary:NO];
		[listView setNeedsLayout];
		[listView layoutIconsIfNeeded:1.0 domino:YES];
	}
}
%end

//Hooks to remove Select App mode when necessary
%hook SBSearchViewController
- (void)searchGesture:(id)fp8 completedShowing:(BOOL)fp12 {
	%orig;

	if (fp12) {
		[[%c(SBIconController) sharedInstance] docker_endAddApp];
	}
}
- (void)searchGesture:(id)fp8 changedPercentComplete:(CGFloat)fp12 {
	%orig;

	if (fp12 > 0.1) {
		[[%c(SBIconController) sharedInstance] docker_endAddApp];
	}
}
%end
%hook SBLockScreenManager
-(void)_finishUIUnlockFromSource:(int)source withOptions:(id)options {
    %orig;

    [[%c(SBIconController) sharedInstance] docker_endAddApp];
} 

-(void)_sendUILockStateChangedNotification {
    %orig;

    [[%c(SBIconController) sharedInstance] docker_endAddApp];
}
-(void)_deviceLockedChanged:(id)arg1 {
    %orig;

    [[%c(SBIconController) sharedInstance] docker_endAddApp];
}
%end

static void loadPreferences() {
	CFPreferencesAppSynchronize(CFSTR("com.phillipt.docker"));

	//enabled = [(id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.phillipt.docker")) boolValue];
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
								NULL,
								(CFNotificationCallback)loadPreferences,
								CFSTR("com.phillipt.docker/prefsChanged"),
								NULL,
								CFNotificationSuspensionBehaviorDeliverImmediately);
	loadPreferences();

	if (![[NSFileManager defaultManager] fileExistsAtPath:kSerializedBundleIdentifiersPath]) {
		[[NSFileManager defaultManager] createFileAtPath:kSerializedBundleIdentifiersPath contents:nil attributes:nil];
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:kSerializedPositionsPath]) {
		[[NSFileManager defaultManager] createFileAtPath:kSerializedPositionsPath contents:nil attributes:nil];
	}
}

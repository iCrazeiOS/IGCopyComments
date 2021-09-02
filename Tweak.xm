/* Headers */
#import <AudioToolbox/AudioToolbox.h>

@interface IGStyledString : NSObject
@property (nonatomic, strong, readwrite) NSMutableAttributedString *attributedString;
@end

@interface IGCoreTextView : UIView
@property (nonatomic, copy, readwrite) IGStyledString *styledString;
-(UIViewController *)_viewControllerForAncestor;
@end


/* Main Code */
// Hook Instagram's custom text view class, used in parts of the app
%hook IGCoreTextView
-(void)setFrame:(CGRect)arg1 {
	%orig;
	// Determine if we are in the comments view controller
	if ([[self _viewControllerForAncestor] isKindOfClass:%c(IGCommentThreadV2ViewController)]) {
		// Add long press recogniser
		UILongPressGestureRecognizer *copyCommentLongPressRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyCommentTextForTweak)];
		copyCommentLongPressRecogniser.minimumPressDuration = 0.5;
		[self addGestureRecognizer:copyCommentLongPressRecogniser];
	}
}

// Create new method
%new
// When our long press recogniser is triggered
-(void)copyCommentTextForTweak {
	// Get the text view's content
	NSString *commentTextWithUsername = [NSString stringWithFormat:@"%@", MSHookIvar<NSMutableString *>(self.styledString.attributedString, "mutableString")];
	// Remove the profile username from the string
	NSUInteger index = [commentTextWithUsername rangeOfString:@" "].location;
	NSString *commentText = [commentTextWithUsername substringFromIndex:index+1];
	// Copy commentText to clipboard
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = commentText;
	// Haptic feedback
	AudioServicesPlaySystemSound(1519);
}
%end


// Many Instagram tweaks need this in the constructor, else the app will crash
// due to some of Instagram's frameworks not yet being fully loaded
static id observer;

%ctor {
	// Create observer to detect when the app has fully loaded
	observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		// Initialise the hooks
		%init;
		// Remove observer
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
	}];
}

#import <AudioToolbox/AudioToolbox.h>

@interface IGStyledString : NSObject
@property (nonatomic, strong, readwrite) NSMutableAttributedString *attributedString;
@end

@interface IGCoreTextView : UIView
@property (nonatomic, copy, readwrite) IGStyledString *styledString;
-(id)_viewControllerForAncestor;
@end

%hook IGCoreTextView
-(void)setFrame:(CGRect)arg1 {
	%orig;
	UIViewController *ancestorVC = [self _viewControllerForAncestor];
	if ([ancestorVC isKindOfClass:%c(IGCommentThreadV2ViewController)]) {
		UILongPressGestureRecognizer *copyCommentLongPressRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyCommentTextForTweak)];
		copyCommentLongPressRecogniser.minimumPressDuration = 0.5;
		[self addGestureRecognizer:copyCommentLongPressRecogniser];
	}
}
%new
-(void)copyCommentTextForTweak {
	NSString *commentTextWithUsername = [NSString stringWithFormat:@"%@", MSHookIvar<NSMutableString *>(self.styledString.attributedString, "mutableString")];
	NSUInteger index = [commentTextWithUsername rangeOfString:@" "].location;
	NSString *commentText = [commentTextWithUsername substringFromIndex:index+1];
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = commentText;
	AudioServicesPlaySystemSound(1519);
}
%end

static id observer;

%ctor {
	observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
		object:nil queue:[NSOperationQueue mainQueue]
		usingBlock:^(NSNotification *notification) {
			%init;
			[[NSNotificationCenter defaultCenter] removeObserver:observer];
		}
	];
}

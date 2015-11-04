#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface NSObject ()
@property (assign,nonatomic) UIEdgeInsets clippingInsets;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *subtitle;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *sectionID;
@property (copy, nonatomic) id defaultAction;
+ (id)action;
+ (id)sharedInstance;
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(NSInteger)arg3;
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(NSInteger)arg3 playLightsAndSirens:(BOOL)arg4 withReply:(id)arg5;
- (void)_replaceIntervalElapsed;
- (void)_dismissIntervalElapsed;
- (BOOL)containsAttachments;
- (void)setSecondaryText:(id)arg1 italicized:(BOOL)arg2;
- (int)_ui_resolvedTextAlignment;

- (UILabel *)tb_titleLabel;
- (void)tb_setTitleLabel:(UILabel *)label;
- (void)tb_setSecondaryLabel:(UILabel *)label;

@end

@interface UIStatusBarItemView : UIView
@end

@interface UIStatusBarTimeItemView : UIStatusBarItemView{
	NSString *_timeString;
}

-(int)textStyle;
-(BOOL)cachesImage;
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
@end

@interface SBAwayController : NSObject
+ (id)sharedAwayController;
- (BOOL)isLocked;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (BOOL)isBatteryCharging;
- (BOOL)isOnAC;
- (void)ACPowerChanged;
- (int)batteryCapacityAsPercentage;
- (float)batteryCapacity;
- (int)displayBatteryCapacityAsPercentage;
- (int)curvedBatteryCapacityAsPercentage;
@end

@interface SBBannerController : NSObject
+ (id)sharedInstance;
- (void)_presentBannerView:(id)view;
-(void)dismissBannerWithAnimation:(BOOL)val reason:(NSInteger)val2;
@end

@interface BBAction : NSObject
+(BBAction*)actionWithIdentifier:(NSString*)identifier;
-(void)setActionType:(NSInteger)val;
-(void)setShouldDismissBulletin:(BOOL)val;
-(void)setAuthenticationRequired:(BOOL)val;
@end

@interface BBButton
+(BBButton*)buttonWithTitle:(NSString*)str action:(BBAction*)action identifier:(NSString*)str;
@end

@interface BBBulletinRequest : NSObject
-(NSString*)sectionID;
-(void)setButtons:(NSMutableArray*)val;
-(void)setSupplementaryActionsByLayout:(NSMutableDictionary*)supplementaryActions;
@end

@interface SBBulletinBannerItem : NSObject
-(BBBulletinRequest*)seedBulletin;
@end

@interface SBUIBannerContext : NSObject
-(SBBulletinBannerItem*)item;
@end

@interface SBBannerContextView : NSObject
-(SBUIBannerContext*)bannerContext;
@end

@interface SBBannerContainerViewController : NSObject
-(BBBulletinRequest*)_bulletin;
-(BOOL)canPullDown;
-(SBBannerContextView*)bannerContextView;
@end

@interface SBLockScreenManager : NSObject // iOS 7
+ (id)sharedInstance;
- (BOOL)isUILocked;
- (void)unlockUIFromSource:(NSInteger)source withOptions:(id)options;
- (void)_finishUIUnlockFromSource:(NSInteger)source withOptions:(id)options;
@end

@interface SBAwayView
-(void)lockBarUnlocked:(id)unlocked;
@end

@interface SBAwayBulletinCell
-(void)lockBarUnlocked:(id)unlocked;
@end

@interface SBAlertItemsController
-(void)displayBanner;
@end

@interface _CDBatterySaver : NSObject
+(id)batterySaver;
-(int)setMode:(int)arg;
@end

static BOOL enableTweak = YES;
static BOOL vibrateSwitch = YES;
static NSInteger battery_level=100;
static BOOL respringSwitch = YES;
static NSString* customTitleText = @"Low Battery";
static NSString* customMessageText = @"low battery remaining";
static BOOL useCustomTitle = NO;
static BOOL useCustomMessage = NO;
static BOOL displayBanner = NO;
static SBBulletinBannerItem * bi = nil;

%hook SBAlertItemsController

- (void)activateAlertItem:(id)item
{	
	if(enableTweak)
	{
		if ([item isKindOfClass:%c(SBLowPowerAlertItem)])
		{
			SBLockScreenManager *lockscreenManager = (SBLockScreenManager *)[objc_getClass("SBLockScreenManager") sharedInstance];

			if (!lockscreenManager.isUILocked)
			{
				[self displayBanner];
			}
			
			return;	
		}
		else
			%orig;
	}
	else
		%orig;
}

%new - (void)displayBanner {

	if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
	{
		battery_level = (int)[[objc_getClass("SBUIController") sharedInstance] curvedBatteryCapacityAsPercentage];
	}
	else
		battery_level = (int)[[objc_getClass("SBUIController") sharedInstance] batteryCapacityAsPercentage];

	id request = [[[%c(BBBulletinRequest) alloc] init] autorelease];
	if(!useCustomTitle)
		[request setTitle: @"Low Battery"];
	else
		[request setTitle: customTitleText];

	NSString * str;
	if(!useCustomMessage) {
		str = [NSString stringWithFormat:@"%ld%% of battery remaining",(long)battery_level];

	} else {
		NSString * battery = [NSString stringWithFormat:@"%ld%",(long)battery_level];
		str = [customMessageText stringByReplacingOccurrencesOfString:@"%batt" withString:battery];
	}
	[request setMessage:str];
	[request setSectionID: @"com.apple.Preferences"];
	[request setDefaultAction: [%c(BBAction) action]];

	id ctrl = [%c(SBBulletinBannerController) sharedInstance];

	if([ctrl respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
		[ctrl observer:nil addBulletin:request forFeed:2 playLightsAndSirens:YES withReply:nil];
	} else {
		[ctrl observer:nil addBulletin:request forFeed:2];
	}

	if(vibrateSwitch)
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

%end

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {

	%orig;
	displayBanner = YES;
}

%end

%hook SBLockScreenViewController

-(void)finishUIUnlockFromSource:(int)source {
	%orig;

	if(!displayBanner)
		return;

	if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
	{
		battery_level = (int)[[objc_getClass("SBUIController") sharedInstance] curvedBatteryCapacityAsPercentage];
	}
	else
		battery_level = (int)[[objc_getClass("SBUIController") sharedInstance] batteryCapacityAsPercentage];

	if(respringSwitch && battery_level <=20.0 && enableTweak)
	{
		[self displayBanner];
	}

	displayBanner = NO;
}

%new - (void)displayBanner {

	id request = [[[%c(BBBulletinRequest) alloc] init] autorelease];

	if(!useCustomTitle)
		[request setTitle: @"Low Battery"];
	else
		[request setTitle: customTitleText];

	NSString * str;
	if(!useCustomMessage) {
		str = [NSString stringWithFormat:@"%ld%% of battery remaining",(long)battery_level];

	} else {
		NSString * battery = [NSString stringWithFormat:@"%ld%",(long)battery_level];
		str = [customMessageText stringByReplacingOccurrencesOfString:@"%batt" withString:battery];
	}

	[request setMessage:str];
	[request setSectionID: @"com.apple.Preferences"];
	[request setDefaultAction: [%c(BBAction) action]];

	id ctrl = [%c(SBBulletinBannerController) sharedInstance];

	if([ctrl respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
		[ctrl observer:nil addBulletin:request forFeed:2 playLightsAndSirens:YES withReply:nil];
	} else {
		[ctrl observer:nil addBulletin:request forFeed:2];
	}

	if(vibrateSwitch)
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

%end

%hook SBBannerButtonViewController

-(void)setButtonTitles:(id)arg {

	if(!enableTweak)
	{
		%orig;
		return;
	}

	BBBulletinRequest * br = [bi seedBulletin];

	if( [[br sectionID] isEqualToString:@"com.apple.Preferences"] )
	{
		NSLog(@"[PowerBanners]Setting custom buttons.");
		NSArray * titles = [NSArray arrayWithObjects:@"Low Power Mode", nil];
		%orig(titles);
	}
	else
	{
		%orig;
	}
}

%end

%hook SBBannerContainerViewController

-(id)_bannerItem {
	id orig = %orig;

	if( orig )
		bi = orig;

	return orig;
}

-(void)_handleBannerTapGesture:(id)gesture withActionContext:(id)context {

	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
	{
		if( [[[self _bulletin] sectionID] isEqualToString:@"com.apple.Preferences"] )
			return;
		else
			%orig;
	}
	else
		%orig;
}

-(void)buttonViewController:(id)ctrl didSelectButtonAtIndex:(NSInteger)index {
	
	if(!enableTweak)
	{
		%orig;
		return;
	}

	BBBulletinRequest * br = [bi seedBulletin];

	if( [[br sectionID] isEqualToString:@"com.apple.Preferences"] )
	{
		[[%c(_CDBatterySaver) batterySaver] setMode:1];
		[[%c(SBBannerController) sharedInstance] dismissBannerWithAnimation:YES reason:0];
	}
	else
		%orig;
}

%end

static void loadPrefs() 
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.joshdoctors.powerbanners.plist"];

    if(prefs)
    {
        enableTweak = ([prefs objectForKey:@"enableTweak"] ? [[prefs objectForKey:@"enableTweak"] boolValue] : enableTweak);
    	vibrateSwitch= ([prefs objectForKey:@"vibrateSwitch"] ? [[prefs objectForKey:@"vibrateSwitch"] boolValue] : vibrateSwitch);
		respringSwitch= ([prefs objectForKey:@"respringSwitch"] ? [[prefs objectForKey:@"respringSwitch"] boolValue] : respringSwitch);
		useCustomMessage = ([prefs objectForKey:@"useCustomMessage"] ? [[prefs objectForKey:@"useCustomMessage"] boolValue] : useCustomMessage);
		useCustomTitle = ([prefs objectForKey:@"useCustomTitle"] ? [[prefs objectForKey:@"useCustomTitle"] boolValue] : useCustomTitle);
		customTitleText = (NSString*)CFPreferencesCopyAppValue(CFSTR("customTitleText"), CFSTR("com.joshdoctors.powerbanners")) ?: @"Low Battery";
		customMessageText = (NSString*)CFPreferencesCopyAppValue(CFSTR("customMessageText"), CFSTR("com.joshdoctors.powerbanners")) ?: @"low battery remaining.";
    }
    [prefs release];
}

%ctor 
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.joshdoctors.powerbanners/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
}

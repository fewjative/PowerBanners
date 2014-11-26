#import <Preferences/Preferences.h>

@interface PowerBannersListController: PSListController {
}
@end

@implementation PowerBannersListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PowerBanners" target:self] retain];
	}
	return _specifiers;

}



-(void)twitter {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/Fewjative"]];

}

@end


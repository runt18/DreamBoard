#import "prefix.h"
#import "DreamBoard.h"

%hook SBApplicationIcon
-(void)launch{
    [[DreamBoard sharedInstance] showAllExcept:nil];
	if(![[[self application] bundleIdentifier] isEqualToString:@"com.wynd.dreamboard"]){
		%orig;
		return;
	}
	[[DreamBoard sharedInstance] show];
}
-(id)initWithApplication:(id)application{
	self = %orig(application);
    if(!self)return self;
    NSLog(@"%@", DreamBoard.sharedInstance.appsArray);
	if([DreamBoard.sharedInstance.hiddenSet containsObject:[self leafIdentifier]]) return self;
	int i = 0;
	for(; i<(int)DreamBoard.sharedInstance.appsArray.count; i++)
		if([[[DreamBoard.sharedInstance.appsArray objectAtIndex:i] leafIdentifier] isEqualToString:[self leafIdentifier]]){
			[DreamBoard.sharedInstance.appsArray replaceObjectAtIndex:i withObject:self];
			return self;
		}else if([[[DreamBoard.sharedInstance.appsArray objectAtIndex:i] displayName] caseInsensitiveCompare:[self displayName]]==NSOrderedDescending)
			break;
	[DreamBoard.sharedInstance.appsArray insertObject:self atIndex:i];
	return self;
}

-(void)setBadge:(NSString*)badge{
	%orig(badge);
    [DreamBoard.sharedInstance updateBadgeForApp:[self leafIdentifier]];
}

%end

%hook SBUIController
-(id)init{
    %orig;
    [DreamBoard sharedInstance].cachePath = [NSString stringWithFormat:@"/DreamBoard/_library/Cache/Previews"];
    //[[NSFileManager defaultManager] removeItemAtPath:[DreamBoard sharedInstance].cachePath error:nil];
    [DreamBoard sharedInstance].scanPath  = [NSString stringWithFormat:@"/DreamBoard"];
    [DreamBoard sharedInstance].backgroundPath = [NSString stringWithFormat:@"/DreamBoard/_library/Images/Background.png"];
    [DreamBoard sharedInstance].shadowPath = [NSString stringWithFormat:@"/DreamBoard/_library/Images/BackgroundShadow.png"];
    [DreamBoard sharedInstance].shadowImagePath = [NSString stringWithFormat:@"/DreamBoard/_library/Images/Shadow.png"];
    [DreamBoard sharedInstance].window = [self window];
    [[DreamBoard sharedInstance] preLoadTheme];
    return self;
}
-(BOOL)clickedMenuButton{
	if(DreamBoard.sharedInstance.isEditing){
		[DreamBoard.sharedInstance stopEditing];
		return YES;
	}else{
		[DreamBoard.sharedInstance hideSwitcher];
		return %orig;
	}
}
- (void)_toggleSwitcher{
	[DreamBoard.sharedInstance toggleSwitcher];
	%orig;
}

- (void)activateApplicationAnimated:(SBApplication *)application{
	[DreamBoard.sharedInstance hideSwitcher];
	%orig(application);
}
- (void)activateApplicationFromSwitcher:(SBApplication *)application{
	[DreamBoard.sharedInstance hideSwitcher];
	%orig(application);
}
%end

%hook SBAppSwitcherBarView
-(void)viewWillDisappear{
	[DreamBoard.sharedInstance hideSwitcher];
	%orig;
}
%end


%hook NSURL
-(BOOL)isSpringboardHandledURL{
    if ([[self absoluteString] hasPrefix:@"http://"] || [[self absoluteString] hasPrefix:@"https://"] || [[self absoluteString] hasPrefix:@"file://"])
        return NO;
    return %orig;
}
%end


%hook SBAwayController
-(void)undimScreen{
    %orig;
    if([[DreamBoard sharedInstance] dbtheme])
        [[DreamBoard sharedInstance].dbtheme didUndim:[self awayView]];
}
-(void)dimScreen:(BOOL)screen{
    %orig(screen);
    if([[DreamBoard sharedInstance] dbtheme])
        [[DreamBoard sharedInstance].dbtheme didDim];
}
%end

%hook SBAwayView
-(void)setDimmed:(BOOL)dimmed{
    %orig(dimmed);
    if( dimmed){
        if([[DreamBoard sharedInstance] dbtheme])
            [[DreamBoard sharedInstance].dbtheme didDim];
    }else{
        if([[DreamBoard sharedInstance] dbtheme])
            [[DreamBoard sharedInstance].dbtheme didUndim:self];
    }
}
%end
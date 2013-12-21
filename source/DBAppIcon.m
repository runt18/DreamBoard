#import "DBAppIcon.h"

@implementation DBAppIcon
@synthesize dict, badgeImage, editImage, maskImage, overlayImage, shadowImage, application, labelStyle, loaded, cacheWidth, cacheHeight, grid;
static NSString *cache;
-(id)init{
    [super init];
    if([DreamBoard sharedInstance].dbtheme && [DreamBoard sharedInstance].dbtheme->allAppIcons)
        [[DreamBoard sharedInstance].dbtheme->allAppIcons addObject:self];
    return self;
}
+(void)setCacheLocation:(NSString*)_cache{
    [cache release];
    [_cache retain];
    cache = _cache;
}

+(NSString*)cacheLocation{
    return cache;
}

-(void)loadIcon:(BOOL)isEditing shouldCache:(BOOL)shouldCache{
    if(loaded)return;
    loaded = YES;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@-%dx%d.png", cache, [application leafIdentifier], cacheWidth, cacheHeight];
    hasCache = [[NSFileManager defaultManager] fileExistsAtPath:cachePath];
    
    if(application && !hasCache){
        UIImage *iconImage = nil;
        BOOL isCustom = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Icons/%@.png", MAINPATH, [DreamBoard sharedInstance].currentTheme, [application displayName]]];
        if (isCustom)
            iconImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Icons/%@.png", MAINPATH, [DreamBoard sharedInstance].currentTheme, [application displayName]]];
        else
            iconImage = [application getIconImage:2];
        if(maskImage!=nil && !isCustom) iconImage = [DBAppIcon maskImage:iconImage withMask:maskImage];
        if(shadowImage) shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
        if(overlayImage!=nil && !isCustom) overlayImageView = [[UIImageView alloc] initWithImage:overlayImage];
        iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        
        if(shadowImageView) [self addSubview:shadowImageView];
        [self addSubview:iconImageView];
        if(overlayImage) [self addSubview:overlayImageView];
    }else if(application && hasCache){
        iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:cachePath]];
        [self addSubview:iconImageView];
    }
    
    if(application !=nil || isEditing){
        iconButton = [[UIButton alloc] init];
        [iconButton addTarget:self action:@selector(launch) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:iconButton];
    }
    
    if(application && !hasCache){
        if(labelStyle){
            CGRect rect = CGRectMake([[labelStyle objectForKey:@"labelX"] intValue],
                                     [[labelStyle objectForKey:@"labelY"] intValue],
                                     [[labelStyle objectForKey:@"labelWidth"] intValue],
                                     [[labelStyle objectForKey:@"labelHeight"] intValue]);
            iconLabel = [[UILabel alloc] initWithFrame:rect];
            iconLabel.font = [UIFont boldSystemFontOfSize:
                              [[labelStyle objectForKey:@"labelFontSize"] intValue]];
            
        }else{
            iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,70,60,12)];
            iconLabel.font = [UIFont boldSystemFontOfSize:11];
        }
        
        iconLabel.textColor = [UIColor whiteColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.backgroundColor = [UIColor clearColor];
        iconLabel.text = [application displayName];
        iconLabel.userInteractionEnabled = NO;
        
        [self addSubview:iconLabel];
    }
    
    if(isEditing){
        editImageView = [[UIImageView alloc] initWithImage:editImage];
        [self addSubview:editImageView];
    }
    
    [self updateFrame];
    
    if (!hasCache && application && shouldCache) 
        [DBAppIcon cacheIconForBundle:[application leafIdentifier] view:self];
    
    if(application)[self updateBadge];
}
-(void)unloadIcon{
    loaded = NO;
    if(overlayImageView){
        [overlayImageView removeFromSuperview];
        [overlayImageView release];
        overlayImageView = nil;
    }
    if(shadowImageView){
        [shadowImageView removeFromSuperview];
        [shadowImageView release];
        shadowImageView = nil;
    }
    if(iconImageView){
        [iconImageView removeFromSuperview];
        [iconImageView release];
        iconImageView = nil;
    }
    if(iconButton){
        [iconButton removeFromSuperview];
        [iconButton release];
        iconButton = nil;
    }
    if(editImageView){
        [editImageView removeFromSuperview];
        [editImageView release];
        editImageView = nil;
    }
    if(iconLabel){
        [iconLabel removeFromSuperview];
        [iconLabel release];
        iconLabel = nil;
    }
    if(badge){
        [badge removeFromSuperview];
        badge = nil;
    }
}
-(void)updateBadge{
    SBIcon *ap = (SBIcon*) application;
    int val = [ap badgeValue];
    if(val == 0 && badge)
        [badge removeFromSuperview];
    else if(val != 0){
        if(badge)[badge removeFromSuperview];
        badge = [[UIView alloc] initWithFrame:CGRectMake(0,0,60,14)];
        UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,10,60,14)];
        badgeLabel.font = [UIFont boldSystemFontOfSize:13];
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.textAlignment = NSTextAlignmentRight;
        badgeLabel.text = [NSString stringWithFormat:@"%d", val];
        badgeLabel.backgroundColor = [UIColor clearColor];
        badgeLabel.opaque = NO;
        UIImageView *stretch = [[UIImageView alloc] initWithFrame:CGRectMake(60-(badgeLabel.text.length*5+15),5,badgeLabel.text.length*5+25,30)];
        stretch.image = [badgeImage stretchableImageWithLeftCapWidth:14 topCapHeight:0];
        [badge addSubview:stretch];
        [stretch release];
        [badge addSubview:badgeLabel];
        [badgeLabel release];
        [self addSubview:badge];
        [badge release];
    }
}

-(void)updateFrame{
    [self setFrame:theFrame];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    theFrame = frame;
    if(iconButton)iconButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if(hasCache){
        iconImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        return;
    }
    if(shadowImageView)shadowImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if(editImageView)editImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    float width, height;
    if([dict objectForKey:@"IconWidth"] && [dict objectForKey:@"IconHeight"])
    {
        width = [[dict objectForKey:@"IconWidth"] floatValue];
        height = [[dict objectForKey:@"IconHeight"] floatValue];
    }else{
        width = 59; height = 59;
    }
    iconImageView.frame = CGRectMake((frame.size.width-width)/2, (frame.size.height-height)/2, width, height);
    if(overlayImageView)overlayImageView.frame = CGRectMake((frame.size.width-width)/2, (frame.size.height-height)/2, width, height);
}

-(void)launch{
    if(editImageView){
        CGRect bounds = [[UIScreen mainScreen] bounds];
        DBAppSelectionTable *table = [[DBAppSelectionTable alloc] initWithFrame:CGRectMake(bounds.origin.x, bounds.origin.y+20, bounds.size.width, bounds.size.height-20) data:[DreamBoard sharedInstance].appsArray delegate:self title:(application==nil?@"No Icon":[application displayName])];
        [[DreamBoard sharedInstance].window addSubview:table];
        [table release];
    }
    else{
        if(grid)[grid doActions];
        [application launch];
    }
}

-(void)addTo:(NSString *)bundle{
    if(dict)
        [dict setObject:bundle forKey:@"BundleID"];
    self.application = [DBGrid find:bundle];
    if(loaded){
        [self unloadIcon];
        [self loadIcon:[DreamBoard sharedInstance].dbtheme.isEditing shouldCache:NO];
    }
    if(grid)
        [grid addTo:bundle sender:self];
}

-(void)removeFromSuperview{
    if([DreamBoard sharedInstance].dbtheme && ![DreamBoard sharedInstance].dbtheme->isDealloc && [DreamBoard sharedInstance].dbtheme->allAppIcons)
        [[DreamBoard sharedInstance].dbtheme->allAppIcons removeObject:self];
}

- (void)dealloc
{
    [self unloadIcon];
    [dict release];
    [badgeImage release];
    [editImage release];
    [maskImage release];
    [overlayImage release];
    [shadowImage release];
    [application release];
    [labelStyle release];
    [super dealloc];
}

+(UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage2{
	CGImageRef imageRef = image.CGImage; 
	CGContextRef mainViewContentContext;
	CGColorSpaceRef colorSpace;
	colorSpace = CGColorSpaceCreateDeviceRGB();
	mainViewContentContext = CGBitmapContextCreate (NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);    
	if (mainViewContentContext==NULL)
        return NULL;
	CGImageRef maskImage = [maskImage2 CGImage];
	CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, CGImageGetWidth(imageRef),CGImageGetHeight(imageRef)), maskImage);
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetWidth(imageRef)), imageRef);
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
	CGImageRelease(mainViewContentBitmapContext);
	return theImage;
}

+(void)cacheIconForBundle:(NSString*)bundle view:(UIView *)view{
    if(![[NSFileManager defaultManager] fileExistsAtPath:cache])
        [[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
    for(int i = 1; i<=2; i++){
        UIGraphicsBeginImageContext( CGSizeMake( view.bounds.size.width*i, view.bounds.size.height*i ) );
        CGContextScaleCTM( UIGraphicsGetCurrentContext(), i, i);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [UIImagePNGRepresentation(viewImage) writeToFile:[NSString stringWithFormat:@"%@/%@-%dx%d%@.png", cache, bundle, ((DBAppIcon*)view).cacheWidth, ((DBAppIcon*)view).cacheHeight, i==1?@"":@"@2x"] atomically:YES]; 
    }
}
@end
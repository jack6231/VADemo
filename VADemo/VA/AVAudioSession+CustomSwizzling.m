#import "AVAudioSession+CustomSwizzling.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

static char kIsActiveKey;
static char kShouldIgnoreConfigLoggingKey;

@implementation AVAudioSession (CustomSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleOriginalSelector:@selector(setCategory:withOptions:error:) withSwizzledSelector:@selector(swizzled_setCategory:withOptions:error:)];
        [self swizzleOriginalSelector:@selector(setMode:) withSwizzledSelector:@selector(swizzled_setMode:)];
        [self swizzleOriginalSelector:@selector(setActive:error:) withSwizzledSelector:@selector(swizzled_setActive:error:)];
        [self swizzleOriginalSelector:@selector(setActive:withOptions:error:) withSwizzledSelector:@selector(swizzled_setActive:withOptions:error:)];
    });
}

+ (void)swizzleOriginalSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (BOOL)swizzled_setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)error {
    BOOL result = [self swizzled_setCategory:category withOptions:options error:error];
    if (!result) {
        NSLog(@"123=====setCategory: %@, options: %lu, error: %@", category, (unsigned long)options, *error);
    }
    [self logAudioSession];
    return result;
}

- (void)swizzled_setMode:(AVAudioSessionMode)mode {
    [self swizzled_setMode:mode];
    [self logAudioSession];
}

- (BOOL)swizzled_setActive:(BOOL)active error:(NSError **)error {
    BOOL result = [self swizzled_setActive:active error:error];
    if (result) {
        NSLog(@"123=====2setActive: %@, isActive: %@", active ? @"YES" : @"NO", self.isActive ? @"YES" : @"NO" );
    } else {
        NSLog(@"123=====2setActive failed: %d, error: %@", active, *error);
    }
    [self logAudioSession];
    return result;
}

- (BOOL)swizzled_setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError **)error {
    BOOL result = [self swizzled_setActive:active withOptions:options error:error];
    if (result) {
        objc_setAssociatedObject(self, &kIsActiveKey, @(active), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        NSLog(@"123=====3setActive: %@, isActive: %@", active ? @"YES" : @"NO", self.isActive ? @"YES" : @"NO" );
    } else {
        NSLog(@"123=====3setActive failed: %d, options: %lu, error: %@", active, (unsigned long)options, *error);
    }
    [self logAudioSession];
    return result;
}

- (void)logAudioSession {
    AVAudioSessionCategoryOptions options = self.categoryOptions;
    NSString *str = [self stringFromAudioSessionCategoryOptions:options];
    NSLog(@"123=====setCategory: %@, mode: %@, options: %@", self.category, self.mode, str);
}

- (NSString *)stringFromAudioSessionCategoryOptions:(AVAudioSessionCategoryOptions)options {
    NSMutableString *optionsDescription = [[NSMutableString alloc] init];
    
    if (options & AVAudioSessionCategoryOptionDuckOthers) {
        [optionsDescription appendString:@"DuckOthers, "];
    }
    if (options & AVAudioSessionCategoryOptionAllowBluetooth) {
        [optionsDescription appendString:@"AllowBluetooth, "];
    }
    if (options & AVAudioSessionCategoryOptionDefaultToSpeaker) {
        [optionsDescription appendString:@"DefaultToSpeaker, "];
    }
    if (options & AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers) {
        [optionsDescription appendString:@"InterruptSpokenAudioAndMixWithOthers, "];
    }
    if (options & AVAudioSessionCategoryOptionAllowBluetoothA2DP) {
        [optionsDescription appendString:@"AllowBluetoothA2DP, "];
    }
    if (options & AVAudioSessionCategoryOptionAllowAirPlay) {
        [optionsDescription appendString:@"AllowAirPlay, "];
    }
    if (options & AVAudioSessionCategoryOptionMixWithOthers) {
        [optionsDescription appendString:@"MixWithOthers"];
    }
    
    if ([optionsDescription hasSuffix:@", "]) {
        [optionsDescription deleteCharactersInRange:NSMakeRange(optionsDescription.length - 2, 2)];
    }
    return [optionsDescription copy];
}

- (BOOL)isActive {
    return [objc_getAssociatedObject(self, &kIsActiveKey) boolValue];
}

- (void)setShouldIgnoreConfigLogging:(BOOL)shouldIgnore {
    objc_setAssociatedObject(self, &kShouldIgnoreConfigLoggingKey, @(shouldIgnore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldIgnoreConfigLogging {
    return [objc_getAssociatedObject(self, &kShouldIgnoreConfigLoggingKey) boolValue];
}

@end

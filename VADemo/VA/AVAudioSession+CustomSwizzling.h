//
//  AVAudioSession+CustomSwizzling.h
//  VADemo
//
//  Created by Jack on 2024/11/11.
//

#import <AVFAudio/AVFAudio.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioSession (CustomSwizzling)

@property (nonatomic, readonly) BOOL isActive;
@property (nonatomic, assign) BOOL shouldIgnoreConfigLogging;

@end

NS_ASSUME_NONNULL_END

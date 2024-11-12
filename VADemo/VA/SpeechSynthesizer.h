#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SpeechSynthesisEventHandler)(void);

@interface SpeechSynthesizer : NSObject

@property (nonatomic, copy, nullable) NSString *authorizationToken;

// 初始化方法
- (instancetype)init;

// 语音合成方法
- (void)speakText:(NSString *)text;
- (void)speakSsml:(NSString *)ssml;
- (void)startSpeakingText:(NSString *)text;
- (void)startSpeakingSsml:(NSString *)ssml;
- (void)stopSpeaking;

// 事件处理器添加方法
- (void)addSynthesisStartedEventHandler:(SpeechSynthesisEventHandler)handler;
- (void)addSynthesizingEventHandler:(SpeechSynthesisEventHandler)handler;
- (void)addSynthesisCompletedEventHandler:(SpeechSynthesisEventHandler)handler;
- (void)addSynthesisCanceledEventHandler:(SpeechSynthesisEventHandler)handler;

@end

NS_ASSUME_NONNULL_END

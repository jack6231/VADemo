#import "SpeechSynthesizer.h"

@interface SpeechSynthesizer () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

// 事件处理器属性
@property (nonatomic, copy) SpeechSynthesisEventHandler synthesisStartedHandler;
@property (nonatomic, copy) SpeechSynthesisEventHandler synthesizingHandler;
@property (nonatomic, copy) SpeechSynthesisEventHandler synthesisCompletedHandler;
@property (nonatomic, copy) SpeechSynthesisEventHandler synthesisCanceledHandler;

@end

@implementation SpeechSynthesizer

- (instancetype)init {
    self = [super init];
    if (self) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return self;
}

- (void)speakText:(NSString *)text {
    [self startSpeakingText:text];
}

- (void)speakSsml:(NSString *)ssml {
    NSString *parsedText = [self parseSsml:ssml];
    [self startSpeakingText:parsedText];
}

- (void)startSpeakingText:(NSString *)text {
    if (text.length == 0) return;
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    // 配置语音属性，例如语言、语速等
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    [_synthesizer speakUtterance:utterance];
}

- (void)startSpeakingSsml:(NSString *)ssml {
    NSString *parsedText = [self parseSsml:ssml];
    [self startSpeakingText:parsedText];
}

- (void)stopSpeaking {
    if (_synthesizer.isSpeaking) {
        [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (NSString *)parseSsml:(NSString *)ssml {
    // 简单移除 SSML 标签，实际应用中需要更复杂的解析
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:nil];
    NSString *plainText = [regex stringByReplacingMatchesInString:ssml options:0 range:NSMakeRange(0, ssml.length) withTemplate:@""];
    return plainText;
}

// 添加事件处理器方法
- (void)addSynthesisStartedEventHandler:(SpeechSynthesisEventHandler)handler {
    self.synthesisStartedHandler = handler;
}

- (void)addSynthesizingEventHandler:(SpeechSynthesisEventHandler)handler {
    self.synthesizingHandler = handler;
}

- (void)addSynthesisCompletedEventHandler:(SpeechSynthesisEventHandler)handler {
    self.synthesisCompletedHandler = handler;
}

- (void)addSynthesisCanceledEventHandler:(SpeechSynthesisEventHandler)handler {
    self.synthesisCanceledHandler = handler;
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (self.synthesisStartedHandler) {
        self.synthesisStartedHandler();
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (self.synthesisCompletedHandler) {
        self.synthesisCompletedHandler();
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (self.synthesisCanceledHandler) {
        self.synthesisCanceledHandler();
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    if (self.synthesizingHandler) {
        self.synthesizingHandler();
    }
}

@end

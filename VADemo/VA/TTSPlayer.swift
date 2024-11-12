import AVFoundation

class TTSPlayer: NSObject {
    private var synthesizer: AVSpeechSynthesizer
    private var completion: (() -> Void)?
    
    override init() {
        self.synthesizer = AVSpeechSynthesizer()
        super.init()
        self.synthesizer.delegate = self
    }
    
    // 播放文本
    func playText(_ text: String, completion: (() -> Void)? = nil) {
        self.completion = completion
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        configureAudioSession()
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        synthesizer.speak(utterance)
    }
    
    // 停止播放
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        deactivateAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话配置失败: \(error.localizedDescription)")
        }
    }
    
    private func deactivateAudioSession() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                print("音频会话已停用并通知其他应用")
            } catch {
                print("停用音频会话失败: \(error.localizedDescription)")
            }
        }
    }
}

extension TTSPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("TTS 播放完成")
        deactivateAudioSession()
        completion?()
        completion = nil
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("TTS 播放取消")
        deactivateAudioSession()
        completion = nil
    }
}

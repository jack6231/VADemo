import Foundation
import AVFoundation

// 定义代理协议
protocol TextToSpeechPlayerDelegate: AnyObject {
    /// 开始播报
    func textToSpeechPlayerDidStartPlaying(_ player: TextToSpeechPlayer)
    
    /// 播报完成
    func textToSpeechPlayerDidFinishPlaying(_ player: TextToSpeechPlayer)
    
    /// 播报被暂停
    func textToSpeechPlayerDidPausePlaying(_ player: TextToSpeechPlayer)
    
    /// 播报失败
    func textToSpeechPlayer(_ player: TextToSpeechPlayer, didFailWithError error: TextToSpeechPlayerError)
}

// 定义错误类型
enum TextToSpeechPlayerError: Error {
    case audioSessionInitializationFailed(error: Error)
    case audioEngineStartFailed(error: Error)
    case speechSynthesizerError(error: Error)
    case playbackFailed(error: Error)
    case interruptionCannotResume
    case unknown
}

extension TextToSpeechPlayerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .audioSessionInitializationFailed(let error):
            return "Audio session initialization failed: \(error.localizedDescription)"
        case .audioEngineStartFailed(let error):
            return "Audio engine failed to start: \(error.localizedDescription)"
        case .speechSynthesizerError(let error):
            return "Speech synthesis failed: \(error.localizedDescription)"
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        case .interruptionCannotResume:
            return "Interruption ended, but playback cannot resume"
        case .unknown:
            return "Unknown error"
        }
    }
}

class TextToSpeechPlayer: NSObject {
    
    public weak var delegate: TextToSpeechPlayerDelegate?
    public var isPlaying: Bool {
        playerNode.isPlaying
    }
    
    private var speechSynthesizer: AVSpeechSynthesizer
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    
    // 调度组，用于跟踪缓冲区的播放状态
    private let dispatchGroup = DispatchGroup()
    
    override init() {
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.audioEngine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()
        super.init()
        
        // 添加音频会话中断通知的监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    public func speak(text: String, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 根据需要设置语言
        utterance.volume = 1
        utterance.rate = rate // 使用传入的 rate
        speak(utterance: utterance)
    }
    
    public func speak(utterance: AVSpeechUtterance) {
        // 确保播放器节点已准备好
        playerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        // 重置调度组
        dispatchGroup.notify(queue: .main) { }
        speechSynthesizer.write(utterance) { [weak self] buffer in
            guard let self = self else { return }
            
            if let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 {
                // 获取 playerNode 的输出格式
                let playerFormat = self.playerNode.outputFormat(forBus: 0)
                let pcmFormat = pcmBuffer.format
                if  pcmFormat != playerFormat {
                    self.dispatchGroup.enter()
                    let format = AVAudioFormat(commonFormat: playerFormat.commonFormat, sampleRate:pcmFormat.sampleRate, channels: playerFormat.channelCount, interleaved: false) ?? playerFormat
                    if !audioEngine.isRunning {
                        self.setupAudioEngine(format: format)
                    }
                    guard let convertedBuffer = pcmBuffer.convert(to: format) else {
                        print("345======== 采样率转换失败")
                        self.delegate?.textToSpeechPlayer(self, didFailWithError: .playbackFailed(error: NSError(domain: "转换失败", code: -1, userInfo: nil)))
                        return
                    }
                    
                    self.playerNode.scheduleBuffer(convertedBuffer) {
                        // 缓冲区播放完成，离开调度组
                        self.dispatchGroup.leave()
                    }
                } else {
                    self.dispatchGroup.enter()
                    if !audioEngine.isRunning {
                        self.setupAudioEngine(format: pcmFormat)
                    }
                    self.playerNode.scheduleBuffer(pcmBuffer) {
                        self.dispatchGroup.leave()
                    }
                }
            } else {
                // 所有缓冲区都已提供，开始监听调度组的完成状态
                self.dispatchGroup.notify(queue: .main) {
                    // 播放完成
                    print("345======== 播放完成")
                    self.stop()
                    self.delegate?.textToSpeechPlayerDidFinishPlaying(self)
                }
            }
        }
    }
    
    public func stop() {
        playerNode.stop()
        audioEngine.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    private func setupAudioEngine(format: AVAudioFormat? = nil) {
        // 配置音频会话
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        do {
            try audioEngine.start()
            print("345======== 音频引擎启动成功")
            // 启动播放器节点
            playerNode.play()
            // 通知代理开始播报
            delegate?.textToSpeechPlayerDidStartPlaying(self)
        } catch {
            print("345======== 无法启动音频引擎: \(error)")
            delegate?.textToSpeechPlayer(self, didFailWithError: .audioEngineStartFailed(error: error))
        }
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        switch type {
        case .began:
            // 中断开始，暂停播放
            print("345======== 音频中断开始")
            if playerNode.isPlaying {
                playerNode.pause()
                // 通知代理播报被暂停
                delegate?.textToSpeechPlayerDidPausePlaying(self)
            }
        case .ended:
            /*
            print("音频中断结束")
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // 恢复音频会话
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                        // 恢复音频引擎和播放器节点
                        if !self.audioEngine.isRunning {
                            try self.audioEngine.start()
                        }
                        self.playerNode.play()
                        print("恢复播放")
                        // 通知代理开始播报
                        delegate?.textToSpeechPlayerDidStartPlaying(self)
                    } catch {
                        print("无法恢复音频会话: \(error)")
                        delegate?.textToSpeechPlayer(self, didFailWithError: .audioEngineStartFailed(error: error))
                    }
                } else {
                    // 中断结束，但不应恢复播放
                    print("中断结束，但不应恢复播放")
                    self.delegate?.textToSpeechPlayer(self, didFailWithError: .interruptionCannotResume)
                    self.stop()
                }
            }*/
            break
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// AVAudioPCMBuffer 的扩展，用于采样率转换
extension AVAudioPCMBuffer {
    /// 将当前 AVAudioPCMBuffer 转换为指定采样率和格式的新的 AVAudioPCMBuffer
    /// - Parameters:
    ///   - targetFormat: 目标音频格式，包含目标采样率和通道数等信息
    /// - Returns: 转换后的 AVAudioPCMBuffer，如果转换失败则返回 nil
    func convert(to targetFormat: AVAudioFormat) -> AVAudioPCMBuffer? {
        // 创建转换器，从当前格式转换到目标格式
        guard let converter = AVAudioConverter(from: self.format, to: targetFormat) else {
            print("345======== 无法创建 AVAudioConverter")
            return nil
        }
        
        // 计算转换后的帧数
        let ratio = targetFormat.sampleRate / self.format.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(Double(self.frameLength) * ratio)
        
        // 创建输出缓冲区
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: outputFrameCapacity) else {
            print("345======== 无法创建输出 AVAudioPCMBuffer")
            return nil
        }
        
        // 创建输入输出缓冲区的 AudioBufferList
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return self
        }
        
        converter.convert(to: outputBuffer, error: nil, withInputFrom: inputBlock)
        return outputBuffer
    }
}

import Foundation
import AVFoundation

class TextToSpeechPlayer2: NSObject {
    private var speechSynthesizer: AVSpeechSynthesizer
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    private var completion: (() -> Void)?
    
    // 调度组，用于跟踪缓冲区的播放状态
    private let dispatchGroup = DispatchGroup()
    
    override init() {
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.audioEngine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()
        super.init()
        
        // 添加音频路由变化通知的监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        
        // 初始化音频引擎
        setupAudioEngine()
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        // 停止音频引擎
        audioEngine.stop()
        playerNode.stop()
        
        // 重置音频引擎
        audioEngine.reset()
        
        // 重新配置音频引擎
        setupAudioEngine()
        
        print("音频路由发生变化，已重新配置音频引擎")
    }
    
    func speak(text: String, completion: (() -> Void)? = nil) {
        self.completion = completion
        
        // 停止之前的播放
        stop()
        
        // 重置调度组
        dispatchGroup.notify(queue: .main) { }
        
        // 配置音频会话
        configureAudioSession()
        
        // 设置语音合成参数
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 根据需要设置语言
        utterance.volume = 1.0
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        // 启动音频引擎
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                print("音频引擎启动成功")
            } catch {
                print("无法启动音频引擎: \(error)")
                return
            }
        }
        
        // 启动播放器节点
        playerNode.play()
        
        speechSynthesizer.write(utterance) { [weak self] buffer in
            guard let self = self else { return }
            
            if let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 {
                // 获取 playerNode 的输出格式
                let playerFormat = self.playerNode.outputFormat(forBus: 0)
                
                // 如果缓冲区的格式与 playerNode 的输出格式不一致，进行格式转换
                if pcmBuffer.format != playerFormat {
                    guard let converter = AVAudioConverter(from: pcmBuffer.format, to: playerFormat) else {
                        print("无法创建格式转换器")
                        return
                    }
                    
                    let convertedBuffer = AVAudioPCMBuffer(pcmFormat: playerFormat, frameCapacity: pcmBuffer.frameCapacity)!
                    var error: NSError?
                    converter.convert(to: convertedBuffer, error: &error) { (_, outStatus) -> AVAudioBuffer? in
                        outStatus.pointee = .haveData
                        return pcmBuffer
                    }
                    
                    if let error = error {
                        print("格式转换失败：\(error.localizedDescription)")
                        return
                    }
                    
                    // 调度转换后的缓冲区
                    self.dispatchGroup.enter()
                    self.playerNode.scheduleBuffer(convertedBuffer) {
                        self.dispatchGroup.leave()
                    }
                } else {
                    // 格式一致，直接调度缓冲区
                    self.dispatchGroup.enter()
                    self.playerNode.scheduleBuffer(pcmBuffer) {
                        self.dispatchGroup.leave()
                    }
                }
            } else {
                // 所有缓冲区已提供，等待播放完成
                self.dispatchGroup.notify(queue: .main) {
                    print("播放完成")
                    self.stop()
                    self.completion?()
                }
            }
        }
    }
    
    private func setupAudioEngine() {
        // 获取当前音频会话的输出音频格式
        let audioSession = AVAudioSession.sharedInstance()
        let hardwareSampleRate = audioSession.sampleRate
        let outputChannelCount = audioSession.outputNumberOfChannels
        
        // 创建适当的音频格式
        guard let format = AVAudioFormat(standardFormatWithSampleRate: hardwareSampleRate, channels: AVAudioChannelCount(outputChannelCount)) else {
            print("无法创建适当的音频格式")
            return
        }
        
        // 配置音频引擎和节点连接
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            print("音频会话配置成功")
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }
    
    func stop() {
        playerNode.stop()
        audioEngine.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

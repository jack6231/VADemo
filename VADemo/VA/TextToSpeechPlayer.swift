import Foundation
import AVFoundation

class TextToSpeechPlayer: NSObject {
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
        addNotifications()
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioEngineConfigChanged(noti:)), name: Notification.Name.AVAudioEngineConfigurationChange, object: audioEngine)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruption(noti:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChanged(noti:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConfigurationChange), name: .AVAudioEngineConfigurationChange, object: nil)
    }
    
    
    @objc func handleConfigurationChange() {
        print("345======== audio engine configeuration change")
    }
    
    // 插拔耳机 断开/链接 蓝牙等
    @objc private func audioEngineConfigChanged(noti: NSNotification) {
        print("345======== audio engine 被打断1")
    }
    
    // 被打断 闹钟 电话等
    @objc private func audioSessionInterruption(noti: NSNotification) {
        print("345======== audio engine 被打断2")
        
    }
    //audio route 更换
    @objc private func audioSessionRouteChanged(noti: Notification) {
        print("345======== audio engine route change")
        let outputs =  AVAudioSession.sharedInstance().currentRoute.outputs
        for output in outputs {
            print("345======== output type: \(output.portType.rawValue), name: \(output.portName)")
        }
    }
    
    deinit {
        print("345======== TextToSpeechPlayer deinit ==")
    }
    
    
    func speak(text: String, completion: (() -> Void)? = nil) {
        self.completion = completion
        
        // 确保播放器节点已准备好
        playerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        // 重置调度组
        dispatchGroup.notify(queue: .main) { }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 根据需要设置语言
        utterance.volume = 1
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        speechSynthesizer.write(utterance) { [weak self] buffer in
            guard let self = self else { return }
            
            if let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 {
                // 第一次收到缓冲区时，设置音频引擎
                if !self.audioEngine.isRunning {
                    self.setupAudioEngine(with: pcmBuffer.format)
                }
                
                // 进入调度组
                self.dispatchGroup.enter()
                
                self.playerNode.scheduleBuffer(pcmBuffer) {
                    // 缓冲区播放完成，离开调度组
                    self.dispatchGroup.leave()
                }
            } else {
                // 所有缓冲区都已提供，开始监听调度组的完成状态
                self.dispatchGroup.notify(queue: .main) {
                    // 所有缓冲区都已播放完成，调用播放完成回调
                    print("345======== 播放完成")
                    self.stop()
                    self.completion?()
                }
            }
        }
    }
    
    private func setupAudioEngine(with format: AVAudioFormat) {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        do {
            try audioEngine.start()
            print("345======== 音频引擎启动成功")
            // 启动播放器节点
            playerNode.play()
        } catch {
            print("345======== 无法启动音频引擎: \(error)")
        }
    }
    
    func stop() {
        playerNode.stop()
        audioEngine.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

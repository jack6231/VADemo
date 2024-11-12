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
    }
   
    func speak(text: String, rate: Float = AVSpeechUtteranceDefaultSpeechRate, completion: (() -> Void)? = nil) {
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
        self.setupAudioEngine()
        
        speechSynthesizer.write(utterance) { [weak self] buffer in
            guard let self = self else { return }
            
            if let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 {
                // 获取 playerNode 的输出格式
                let playerFormat = self.playerNode.outputFormat(forBus: 0)
                
                if pcmBuffer.format != playerFormat {
                    self.dispatchGroup.enter()
                    guard let convertedBuffer = pcmBuffer.convert(to: playerFormat) else {
                        print("345======== 采样率转换失败")
                        return
                    }
                    
                    self.playerNode.scheduleBuffer(convertedBuffer) {
                        // 缓冲区播放完成，离开调度组
                        self.dispatchGroup.leave()
                    }
                }
                else {
                    // 格式一致，直接调度缓冲区
                    self.dispatchGroup.enter()
                    self.playerNode.scheduleBuffer(pcmBuffer) {
                        self.dispatchGroup.leave()
                    }
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
    
    private func setupAudioEngine() {
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
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

extension AVAudioPCMBuffer {
    /// 将当前 AVAudioPCMBuffer 转换为指定采样率和格式的新的 AVAudioPCMBuffer
    /// - Parameters:
    ///   - targetFormat: 目标音频格式，包含目标采样率和通道数等信息
    /// - Returns: 转换后的 AVAudioPCMBuffer，如果转换失败则返回 nil
    func convert(to targetFormat: AVAudioFormat) -> AVAudioPCMBuffer? {
        // 创建转换器，从当前格式转换到目标格式
        guard let converter = AVAudioConverter(from: self.format, to: targetFormat) else {
            print("无法创建 AVAudioConverter")
            return nil
        }
        
        // 计算转换后的帧数
        let ratio = Double(targetFormat.sampleRate) / self.format.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(Double(self.frameLength) * ratio)
        
        // 创建输出缓冲区
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: outputFrameCapacity) else {
            print("无法创建输出 AVAudioPCMBuffer")
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

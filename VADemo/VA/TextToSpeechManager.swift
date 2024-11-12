import Foundation
import AVFoundation

class TextToSpeechManager: NSObject, AVAudioPlayerDelegate {
    
    static let shared = TextToSpeechManager()
    
    private var speechSynthesizer: AVSpeechSynthesizer
    private var audioFile: AVAudioFile?
    private var completionHandler: ((URL?, Error?) -> Void)?
    private var playCompletionHandler: (() -> Void)?
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {
        self.speechSynthesizer = AVSpeechSynthesizer()
        super.init()
    }
    
    /// 将文本转换为音频文件，返回音频文件的 URL
    func textToSpeech(text: String, language: String = "en-US", completion: @escaping (URL?, Error?) -> Void) {
        self.completionHandler = completion
        
        // 设置输出文件路径
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "tts_\(timestamp).caf"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsURL.appendingPathComponent(fileName)
        
        let utterance = AVSpeechUtterance(string: text)
        
        // 使用传入的 language 参数
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        // 设置适当的语速
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate  // 或根据需要调整
        
        // 配置音频格式（将在回调中设置）
        // 初始化音频文件将在回调中进行
        
        // 开始写入音频数据
        speechSynthesizer.write(utterance) { [weak self] buffer in
            guard let self = self else { return }
            
            if let audioBuffer = buffer as? AVAudioPCMBuffer, audioBuffer.frameLength > 0 {
                do {
                    // 在第一次收到缓冲区时，初始化音频文件
                    if self.audioFile == nil {
                        let audioFormat = audioBuffer.format
                        self.audioFile = try AVAudioFile(forWriting: outputURL, settings: audioFormat.settings)
                        print("音频文件初始化成功，保存路径：\(outputURL.path)")
                    }
                    try self.audioFile?.write(from: audioBuffer)
                } catch {
                    self.speechSynthesizer.stopSpeaking(at: .immediate)
                    DispatchQueue.main.async {
                        print("写入音频文件时出错：\(error.localizedDescription)")
                        self.completionHandler?(nil, error)
                    }
                }
            } else {
                // 合成完成
                DispatchQueue.main.async {
                    let fileExists = FileManager.default.fileExists(atPath: outputURL.path)
                    print("合成完成，文件是否存在：\(fileExists)")
                    if fileExists {
                        print("合成的音频文件路径：\(outputURL.path)")
                        self.completionHandler?(outputURL, nil)
                    } else {
                        print("合成完成，但文件未生成。")
                        self.completionHandler?(nil, NSError(domain: "TextToSpeechError", code: -1, userInfo: [NSLocalizedDescriptionKey: "音频文件未生成"]))
                    }
                }
            }
        }
    }
    
    /// 播放指定 URL 的音频文件
    func playAudioFile(at url: URL, completion: (() -> Void)? = nil) {
        self.playCompletionHandler = completion
        
        // 配置音频会话
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置出错：\(error.localizedDescription)")
            return
        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.volume = 1.0
            self.audioPlayer?.prepareToPlay()
            if self.audioPlayer?.play() == true {
                print("音频开始播放")
            } else {
                print("音频播放失败")
            }
        } catch {
            print("播放音频文件时出错：\(error.localizedDescription)")
        }
    }
    
    /// AVAudioPlayerDelegate 方法：音频播放完成
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("音频播放完成")
        playCompletionHandler?()
    }
}

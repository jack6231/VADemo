import UIKit
import SnapKit
import AVFoundation
import AVFAudio
import CallKit
import MicrosoftCognitiveServicesSpeech

class ViewController: UIViewController {
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setTitle("录音", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickRecordButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setTitle("播放", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickPlayButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopRecordButton: UIButton = {
        let button = UIButton()
        button.setTitle("停止录音", for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        return button
    }()
 
    private var audioEngine: AudioEngine?
    private var audioPlayer = AudioPlayer()
    private var speechService = SpeechService()
    private var ttsPlayer = TTSPlayer()
    private var synthesizer = SpeechSynthesizer()
    private let speechPlayer = TextToSpeechPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        AVAudioSession.printAudioSessionProperties()
        
        synthesizer.addSynthesisStartedEventHandler {
            print("语音合成开始")
        }

        synthesizer.addSynthesizingEventHandler {
            print("语音合成进行中")
        }

        synthesizer.addSynthesisCompletedEventHandler {
            print("语音合成完成")
            do {
                print("345======== set active false")
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("345======== set active false 失败: \(error)")
            }
        }

        synthesizer.addSynthesisCanceledEventHandler {
            print("语音合成取消")
        }

    }
    
    private func setupUI() {
        view.addSubview(recordButton)
        view.addSubview(playButton)
        view.addSubview(stopRecordButton)
        
        recordButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        playButton.snp.makeConstraints { make in
            make.top.equalTo(recordButton)
            make.left.equalTo(recordButton.snp.right).offset(20)
            make.width.height.equalTo(recordButton)
        }
        
        stopRecordButton.snp.makeConstraints { make in
            make.top.equalTo(recordButton.snp.bottom).offset(20)
            make.left.equalTo(recordButton)
            make.width.equalTo(recordButton)
            make.height.equalTo(recordButton)
        }
    }
    
    @objc private func clickRecordButton() {
        AVAudioSession.printAudioSessionProperties()
        do {
            print("345======== set category playAndRecord")
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        } catch {
            print("345======== set category playAndRecord error: \(error)")
        }
        do {
            print("345======== set active true")
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("345======== set active true 失败: \(error)")
        }
        do {
            print("345======== 开始录音")
            audioEngine = AudioEngine()
            try audioEngine?.start()
        } catch {
            print("345======== 开始录音 失败: \(error)")
        }
        AVAudioSession.printAudioSessionProperties()
    }
    
    @objc private func stopRecording() {
        print("345======== 停止录音")
        audioEngine?.stop()
//        do {
//            print("345======== set category soloAmbient")
//            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options:[])
//        } catch {
//            print("345======== set category soloAmbient error: \(error)")
//        }
//        do {
//            print("345======== set active false")
//            try AVAudioSession.sharedInstance().setActive(false)
//        } catch {
//            print("345======== set active false 失败: \(error)")
//        }
    }
    
    @objc private func clickPlayButton(sender: UIButton) {
        audioEngine?.stop()
        audioEngine = nil
        AVAudioSession.printAudioSessionProperties()
//        do {
//            print("345======== set category playback")
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.mixWithOthers])
//        } catch {
//            print("345======== set category playback error: \(error)")
//        }
//        do {
//            print("345======== set active true")
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("345======== set active true 失败: \(error)")
//        }
        let text = "What separates the winners from the losers is how a person reacts to each new twist of fate."
//        let manager = TextToSpeechManager.shared
//        manager.textToSpeech(text: text) { url, error in
//            if let url = url {
//                print("语音合成成功，文件已保存到：\(url.path)")
//                
//                // 播放音频文件
//                manager.playAudioFile(at: url) {
//                    print("播放完成")
//                    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//                }
//            } else {
//                print("语音合成失败：\(error?.localizedDescription ?? "未知错误")")
//            }
//        }
        
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        speechPlayer.speak(text: text) {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }

        
//        audioPlayer.ttsPlayWith(voiceText: text)
//        speechService.synthesizeText(text)
//        synthesizer.speakText(text)
//        ttsPlayer.playText(text) {
//            do {
//                print("345======== set active false")
//                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//            } catch {
//                print("345======== set active false 失败: \(error)")
//            }
//        }
        AVAudioSession.printAudioSessionProperties()
    }
}

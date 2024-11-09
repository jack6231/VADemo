import UIKit
import SnapKit
import AVFoundation
import AVFAudio
import CallKit

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
 
    private var audioEngine: AudioEngine?
    private var audioPlayer = AudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        AVAudioSession.printAudioSessionProperties()
    }
    
    private func setupUI() {
        view.addSubview(recordButton)
        view.addSubview(playButton)
        
        
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
    }
    
    @objc private func clickRecordButton() {
        AVAudioSession.printAudioSessionProperties()
        do {
            print("345======== set categor playAndRecord")
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default, options: [.interruptSpokenAudioAndMixWithOthers])
        } catch {
            print("345======== set categor playAndRecord error: \(error)")
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
    
    @objc private func clickPlayButton(sender: UIButton) {
        AVAudioSession.printAudioSessionProperties()
        audioEngine?.stop()
        audioEngine = nil
        do {
            print("345======== set active false")
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("345======== set active false 失败: \(error)")
        }
        do {
            print("345======== set categor playback")
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt)
        } catch {
            print("345======== set categor playback error: \(error)")
        }
        audioPlayer.ttsPlayWith(voiceText: "What separates the winners from the losers is how a person reacts to each new twist of fate.")
        AVAudioSession.printAudioSessionProperties()
    }
}

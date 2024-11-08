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
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setTitle("停止收音", for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickStopButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var setPlayStatusButton: UIButton = {
        let button = UIButton()
        button.setTitle("播放模式", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickSetPlayStatusButton), for: .touchUpInside)
        return button
    }()
    
    
    
    private lazy var setRecordButton: UIButton = {
        let button = UIButton()
        button.setTitle("收音模式", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickSetRecoreStatusButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var setDefualtStatusButton: UIButton = {
        let button = UIButton()
        button.setTitle("默认模式", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickSetDefualtStatusResumeButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var setActiveTrueButton: UIButton = {
        let button = UIButton()
        button.setTitle("获取焦点", for: .normal)
        button.backgroundColor = UIColor.systemPurple
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickSetActiveTrueButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var setActiveFalseButton: UIButton = {
        let button = UIButton()
        button.setTitle("释放焦点", for: .normal)
        button.backgroundColor = UIColor.systemPink
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickSetActiveFalseButton), for: .touchUpInside)
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
        view.addSubview(stopButton)
        view.addSubview(setPlayStatusButton)
        view.addSubview(setRecordButton)
        view.addSubview(setDefualtStatusButton)
        view.addSubview(setActiveTrueButton)
        view.addSubview(setActiveFalseButton)
        
        recordButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        stopButton.snp.makeConstraints { make in
            make.top.equalTo(playButton)
            make.left.equalTo(recordButton.snp.right).offset(20)
            make.width.height.equalTo(recordButton)
        }
        
        playButton.snp.makeConstraints { make in
            make.top.equalTo(recordButton)
            make.left.equalTo(stopButton.snp.right).offset(20)
            make.width.height.equalTo(recordButton)
        }
        
        setRecordButton.snp.makeConstraints { make in
            make.top.equalTo(playButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(recordButton)
        }
        
        setPlayStatusButton.snp.makeConstraints { make in
            make.top.equalTo(setRecordButton)
            make.left.equalTo(setRecordButton.snp.right).offset(20)
            make.width.height.equalTo(recordButton)
        }
        
        setDefualtStatusButton.snp.makeConstraints { make in
            make.top.equalTo(setRecordButton)
            make.left.equalTo(setPlayStatusButton.snp.right).offset(20)
            make.width.height.equalTo(recordButton)
        }
        
        setActiveTrueButton.snp.makeConstraints { make in
            make.top.equalTo(setRecordButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(recordButton)
        }
        
        setActiveFalseButton.snp.makeConstraints { make in
            make.top.equalTo(setActiveTrueButton)
            make.left.equalTo(setActiveTrueButton.snp.right).offset(20)
            make.width.height.equalTo(setActiveTrueButton)
        }
    }
    
    @objc private func clickRecordButton() {
        clickSetRecoreStatusButton()
        clickSetActiveTrueButton()
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
        clickStopButton()
        clickSetActiveFalseButton()
        clickSetPlayStatusButton()
        audioPlayer.ttsPlayWith(voiceText: "What separates the winners from the losers is how a person reacts to each new twist of fate.")
        AVAudioSession.printAudioSessionProperties()
    }
    
    @objc private func clickStopButton() {
        print("345======== 停止录音")
        AVAudioSession.printAudioSessionProperties()
        audioEngine?.stop()
        audioEngine = nil
        AVAudioSession.printAudioSessionProperties()
    }
    
    @objc private func clickSetRecoreStatusButton() {
        AVAudioSession.printAudioSessionProperties()
        do {
            print("345======== set categor playAndRecord")
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default, options: [.interruptSpokenAudioAndMixWithOthers])
        } catch {
            print("345======== set categor playAndRecord error: \(error)")
        }
        AVAudioSession.printAudioSessionProperties()
    }
    
    @objc private func clickSetPlayStatusButton() {
        AVAudioSession.printAudioSessionProperties()
        do {
            print("345======== set categor playback")
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt)
        } catch {
            print("345======== set categor playback error: \(error)")
        }
        AVAudioSession.printAudioSessionProperties()
    }
    
    
    
    @objc private func clickSetDefualtStatusResumeButton() {
        AVAudioSession.printAudioSessionProperties()
        do {
            print("345======== set categor soloAmbient")
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
        } catch {
            print("345======== set categor soloAmbient error: \(error)")
        }
        AVAudioSession.printAudioSessionProperties()
    }
    
    
    @objc private func clickSetActiveTrueButton() {
        AVAudioSession.printAudioSessionProperties()
        do {
            print("345======== set active true")
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("345======== set active true 失败: \(error)")
        }
        AVAudioSession.printAudioSessionProperties()
    }
    
    @objc private func clickSetActiveFalseButton() {
        AVAudioSession.printAudioSessionProperties()
        do {
            print("345======== set active false")
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("345======== set active false 失败: \(error)")
        }
        AVAudioSession.printAudioSessionProperties()
    }
}

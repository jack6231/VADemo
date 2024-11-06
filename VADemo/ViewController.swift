//
//  ViewController.swift
//  VADemo
//
//  Created by Jack on 2024/11/6.
//

import UIKit
import SnapKit
import AVFoundation
import CallKit

class ViewController: UIViewController {
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setTitle("录音", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickRecordButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setTitle("播放", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickPlayButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var audioEngine = AudioEngine()
    private lazy var audioPlayer = AudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    
    @objc private func clickRecordButton(sender: UIButton) {
        do {
            print("345======== set category playAndRecord")
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowAirPlay, .allowBluetoothA2DP])
        } catch {
            print("345======== set category playAndRecord 失败: \(error)")
        }
        do {
            print("345======== 开始录音")
            try audioEngine.start()
        } catch {
            print("345======== 开始录音 失败: \(error)")
        }
        
    }
    
    @objc private func clickPlayButton(sender: UIButton) {
        audioEngine.stop()
        do {
            print("345======== set category playback")
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
        } catch {
            print("345======== set category playback 失败: \(error)")
        }
        self.audioPlayer.ttsPlayWith(voiceText: "Thank you for your valuable time, see you next time!")
    }
    
}


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
    
    private lazy var activeButton: UIButton = {
        let button = UIButton()
        button.setTitle("获取焦点", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickActiveButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var deactiveButton: UIButton = {
        let button = UIButton()
        button.setTitle("释放焦点", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickDeactiveButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("设置分类", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickSettingButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var audioEngine = AudioEngine()
    private lazy var audioPlayer = AudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
        view.addSubview(settingButton)
        view.addSubview(activeButton)
        view.addSubview(deactiveButton)
        view.addSubview(recordButton)
        view.addSubview(playButton)
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(80)
            make.left.equalToSuperview().inset(20)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        activeButton.snp.makeConstraints { make in
            make.top.equalTo(settingButton)
            make.left.equalTo(settingButton.snp.right).offset(20)
            make.width.height.equalTo(settingButton)
        }
        deactiveButton.snp.makeConstraints { make in
            make.top.equalTo(settingButton)
            make.left.equalTo(activeButton.snp.right).offset(20)
            make.width.height.equalTo(settingButton)
        }
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(settingButton.snp.bottom).offset(20)
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
            print("345======== set category playAndRecord")
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt)
        } catch {
            print("345======== set category playAndRecord 失败: \(error)")
        }
        DispatchQueue.global().async {
            self.audioPlayer.ttsPlayWith(voiceText: "Thank you for your valuable time, see you next time!")
        }
    }
    
    @objc private func clickSettingButton(sender: UIButton) {
        
    }
    
    @objc private func clickActiveButton(sender: UIButton) {
        do {print("345======== set active true")
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("345======== set active true 失败: \(error)")
        }
    }
    
    @objc private func clickDeactiveButton(sender: UIButton) {
        do {print("345======== set active false")
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("345======== set active false 失败: \(error)")
        }
    }
    
}


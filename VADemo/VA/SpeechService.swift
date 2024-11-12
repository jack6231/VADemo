//
//  SpeechService.swift
//  VADemo
//
//  Created by Jack on 2024/11/11.
//

import UIKit
import MicrosoftCognitiveServicesSpeech
import AVFAudio

class SpeechService: NSObject {
    private var synthesizer: SPXSpeechSynthesizer?
    
    override init() {
        // 使用您的 Azure 语音服务订阅密钥和区域
        let subscriptionKey = "d827ec98ea5146749bec5067e71c2c38"
        let serviceRegion = "eastus"
        
        do {
            let speechConfig = try SPXSpeechConfiguration(subscription: subscriptionKey, region: serviceRegion)
            let audioConfig = SPXAudioConfiguration()
            
            synthesizer = try SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: audioConfig)
            
            
            // 添加播放完成的事件监听
            synthesizer?.addSynthesisCompletedEventHandler { (synthesizer, event) in
                print("345======== 播放完成")
                do {
                    print("345======== set active false")
                    try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                } catch {
                    print("345======== set active false 失败: \(error)")
                }
            }
            
            
        } catch {
            print("345======== 初始化失败: \(error.localizedDescription)")
        }
    }
    
    // 调用方法来合成文本
    func synthesizeText(_ text: String) {
        guard let synthesizer = synthesizer else {
            print("345======== 语音合成器未初始化")
            return
        }
        
        do {
            let result = try synthesizer.speakText(text)
            if result.reason == SPXResultReason.synthesizingAudioCompleted {
                print("345======== 语音合成成功")
            } else {
                print("345======== 语音合成失败，原因：\(result.reason)")
            }
        } catch {
            print("345======== 合成过程中发生错误: \(error.localizedDescription)")
        }
    }
}
